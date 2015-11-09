// Author: Bohr Shaw <pubohr@gmail.com>

// Vundle manages Vim bundles(plugins).
// It downloads, updates bundles, clean disabled bundles.
package main

import (
	"bytes"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
)

type manager struct{}
type bundle struct {
	repo, branch, dest string
	ifclone            bool
}

var (
	update           = flag.Bool("u", false, "update bundles")
	clean            = flag.Bool("c", false, "clean bundles")
	dry              = flag.Bool("n", false, "dry run")
	maxRoutines      = flag.Int("r", 12, "max number of routines")
	routines         = 0
	ch               = make(chan bundle, 9)
	wg               = sync.WaitGroup{} // goroutines count
	vundle           = &manager{}
	bundles          = getBundles()
	_user, _         = user.Current()
	root             = _user.HomeDir + "/.vim/bundle"
	git, gitNotExist = exec.LookPath("git")
	sep              = "============ "
)

func init() {
	flag.Parse()
	if gitNotExist != nil {
		log.Fatal(gitNotExist)
	}
}

func main() {
	for _, b := range bundles {
		vundle.synca(b)
	}
	close(ch)

	wg.Wait()
	helptags()

	if *clean {
		vundle.clean(bundles)
	}
}

// synca install or update a bundle.
func (*manager) synca(bdl string) {
	b := bundle{repo: bdl}
	if bindex := strings.Index(bdl, ":"); bindex >= 0 {
		b.repo = (bdl)[:bindex]
		if len(bdl) == bindex+1 {
			b.branch = runtime.GOOS + "_" + runtime.GOARCH
		} else {
			b.branch = (bdl)[bindex+1:]
		}
	}

	b.dest = root + "/" + strings.Split(b.repo, "/")[1]
	_, err := os.Stat(b.dest)
	b.ifclone = os.IsNotExist(err)
	if !b.ifclone && !*update {
		return
	}

	// Dispatch the time-consuming work to a goroutine.
	ch <- b
	if routines <= *maxRoutines {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for b := range ch {
				cmd := &exec.Cmd{Path: git}
				url := "https://github.com/" + b.repo
				var output bytes.Buffer
				if b.ifclone { // clone
					args := make([]string, 0, 10)
					args = append(args, git, "clone", "--depth", "1", "--recursive", "--quiet")
					if b.branch != "" {
						args = append(args, "--branch", b.branch)
					}
					cmd.Args = append(args, url, b.dest)

					output.WriteString(sep + url + " ")
					err := cmd.Run()
					if err != nil {
						// Assume the branch doesn't exist and try to clone the default branch
						if b.branch != "" {
							// As of go1.5.1 linux/386, a Cmd struct can't be reused after calling its Run, Output or CombinedOutput methods.
							err := exec.Command(git, append(args[:len(args)-2], url, b.dest)[1:]...).Run()
							if err != nil {
								output.WriteString("can't be cloned!")
							} else {
								output.WriteString("cloned, but the branch " + b.branch + " doesn't exist.")
							}
						} else {
							output.WriteString("can't be cloned!")
						}
					} else {
						output.WriteString("cloned.")
					}
				} else { // update
					cmd.Dir = b.dest
					cmd.Args = strings.Fields("git pull")
					out, err := cmd.Output()
					if err != nil {
						output.WriteString(sep + url + " pull failed: " + err.Error())
					} else if len(out) != 0 && out[0] != 'A' { // out isn't "Already up-to-date"
						output.WriteString(sep + url + " updated.\n")
						log, _ := exec.Command(git, "-C", b.dest, "log", "--no-merges", "--oneline", "ORIG_HEAD..HEAD").Output()
						output.Write(bytes.TrimSpace(log))
						// Update submodules
						if _, err := os.Stat(b.dest + "/.gitmodules"); !os.IsNotExist(err) {
							exec.Command(git, "-C", b.dest, "submodule", "sync").Run()
							err := exec.Command(git, "-C", b.dest, "submodule", "update", "--init", "--recursive").Run()
							if err != nil {
								output.WriteString("\n------------ Submodule update failed: " + err.Error())
							}
						}
					}
				}
				if o := output.String(); len(o) != 0 {
					fmt.Println(o)
				}
			}
		}()
		routines++
	}
}

// clean removes disabled bundles from the file system
func (*manager) clean(bundles []string) {
	dirs, _ := filepath.Glob(root + "/*")
	var match bool
	for _, d := range dirs {
		match = false
		for _, b := range bundles {
			if i := strings.Index(b, ":"); i >= 0 {
				b = b[:i]
			}
			if d[strings.LastIndexAny(d, "/\\")+1:] == strings.Split(b, "/")[1] {
				match = true
				break
			}
		}
		if !match {
			fmt.Print(sep)
			if *dry {
				fmt.Println(d, "would be removed.")
				return
			}
			var err error
			// Note: on Windows, read-only files woundn't be removed
			if runtime.GOOS == "windows" {
				err = exec.Command("cmd.exe", "/C", "rmdir", "/S", "/Q", d).Run()
			} else {
				err = os.RemoveAll(d)
			}
			if err != nil {
				fmt.Printf("Fail removing %v: %v\n", d, err)
			} else {
				fmt.Println(d, "removed.")
			}
		}
	}
}

// bundles returns the bundle list obtained from Vim.
// The format of a bundle is "author/repo[:branch][/sub/directory]", with
// "/sub/directory" cut off.
func getBundles(bs ...string) []string {
	args := []string{
		"-Nesc", // vimrc won't be sourced
		"set rtp+=~/.vim | let g:_vundle = 1 |" +
			"runtime vimrc.bundle | put =dundles | 2,p | q!",
	}
	out, err := exec.Command("vim", args...).Output()
	if err != nil {
		// log.Fatal(err)
	}
	bundles := append(strings.Fields(string(out)), bs...)

	for i, v := range bundles {
		if strings.Count(v, "/") > 1 {
			var slash1 bool
			idx := strings.IndexFunc(v,
				func(r rune) (t bool) {
					if r == '/' {
						if slash1 == true {
							t = true
						}
						slash1 = true
					}
					return
				})
			bundles[i] = v[:idx]
		}
	}
	return bundles
}

// helptags generates Vim HELP tags for all bundles
func helptags() {
	args := []string{
		"-Nesu",
		"NONE",
		"--cmd",
		`if &rtp !~# '\v[\/]\.vim[,|$]' | set rtp^=~/.vim | endif` +
			"| call rtp#inject() | Helptags" +
			func() string {
				if *update {
					return "!"
				}
				return ""
			}() + "| qall",
	}
	if exec.Command("vim", args...).Run() != nil {
		log.Printf("Fail generating HELP tags.")
	}
}

// vim:fdm=syntax:
