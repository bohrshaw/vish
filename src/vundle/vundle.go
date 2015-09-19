// Author: Bohr Shaw <pubohr@gmail.com>

// Vundle manages Vim bundles(plugins).
// It downloads, updates bundles, clean disabled bundles.
package main

import (
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

var (
	update      = flag.Bool("u", false, "update bundles")
	clear       = flag.Bool("c", false, "clear bundles")
	routines    = flag.Int("r", 12, "number of routines")
	_user, _    = user.Current()
	root        = _user.HomeDir + "/.vim/bundle"
	vundle      = &manager{}
	git, giterr = exec.LookPath("git")
)

func init() {
	if giterr != nil {
		log.Fatal(giterr)
	}
}

func main() {
	flag.Parse()

	var (
		bundles = bundles()
		ch      = make(chan string, 9)
	)
	var wg sync.WaitGroup // count of goroutines

	// Spawn some worker goroutines
	for i := 0; i < *routines; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for bundle := range ch {
				vundle.synca(&bundle)
			}
		}()
	}

	// Send bundles to the channel
	for _, bundle := range bundles {
		ch <- bundle
	}
	close(ch)

	// Spawn another goroutine to do clean-up
	if *clear {
		wg.Add(1)
		go func() {
			vundle.clean(&bundles)
			wg.Done()
		}()
	}

	wg.Wait()

	helptags()
}

// synca install or update a bundle.
func (*manager) synca(bundle *string) {
	var (
		repo   = *bundle
		branch = ""
		bindex = strings.Index(*bundle, ":")
	)
	if bindex >= 0 {
		repo = (*bundle)[:bindex]
		if len(*bundle) == bindex+1 {
			branch = runtime.GOOS + "_" + runtime.GOARCH
		} else {
			branch = (*bundle)[bindex+1:]
		}
	}

	path := root + "/" + strings.Split(repo, "/")[1]
	_, err := os.Stat(path)
	pathExist := !os.IsNotExist(err)
	if pathExist && !*update {
		return
	}

	cmd := &exec.Cmd{Path: git}
	url := "https://github.com/" + repo

	// Clone or update the repository
	if !pathExist {
		args := make([]string, 0, 10)
		args = append(args, git, "clone", "--depth", "1", "--recursive", "--quiet")
		if branch != "" {
			args = append(args, "--branch", branch)
		}
		cmd.Args = append(args, url, path)

		err := cmd.Run()
		if err != nil {
			// Assume the branch doesn't exist and try to clone the default branch
			if branch != "" {
				// As of go1.5.1 linux/386, a Cmd struct can't be reused after calling its Run, Output or CombinedOutput methods.
				err := exec.Command(git, append(args[:len(args)-2], url, path)[1:]...).Run()
				if err != nil {
					fmt.Println(url, "can't be cloned!")
				} else {
					fmt.Printf("%v cloned, but the branch %v doesn't exist\n", url, branch)
				}
			} else {
				fmt.Println(url, "can't be cloned!")
			}
		} else {
			fmt.Println(url, "cloned")
		}
	} else {
		cmd.Dir = path
		cmd.Args = strings.Fields("git pull")
		out, err := cmd.Output()
		if err != nil {
			fmt.Println("git pull error:", err)
		}

		// Update submodules
		if _, err := os.Stat(path + "/.gitmodules"); !os.IsNotExist(err) {
			exec.Command(git, "submodule", "sync").Run()
			err := exec.Command(git, "submodule", "update", "--init", "--recursive").Run()
			if err != nil {
				fmt.Println("git submodule update error:", err)
			}
		}

		// The output could be "Already up-to-date."
		if len(out) != 0 && out[0] != 'A' {
			fmt.Println(url, "updated")
		}
	}
}

// clean removes disabled bundles from the disk
func (*manager) clean(bundles *[]string) {
	dirs, _ := filepath.Glob(root + "/*")
	var match bool
	for _, d := range dirs {
		match = false
		for _, b := range *bundles {
			if d[strings.LastIndexAny(d, "/\\")+1:] == strings.Split(b, "/")[1] {
				match = true
				break
			}
		}
		if !match {
			os.RemoveAll(d)
			fmt.Println(d, "removed")
		}
	}
}

// bundles returns the bundle list obtained from Vim.
// The format of a bundle is "author/repo[:branch][/sub/directory]", with
// "/sub/directory" cut off.
func bundles(bs ...string) []string {
	args := []string{
		"-Nesc",
		"set rtp+=~/.vim | let g:_vim_with_all_features = 1 |" +
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
		log.Printf("Fail to generate help tags.")
	}
}

// vim:fdm=syntax:
