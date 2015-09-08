// Vundle manages Vim bundles(plugins).
// Related:
// https://github.com/gpmgo/gopm/blob/master/cmd/get.go
// https://github.com/sourcegraph/go-vcs
package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"
	"sync"
)

type manager struct{}

var (
	update   = flag.Bool("u", false, "update bundles")
	clear    = flag.Bool("c", false, "clear bundles")
	routines = flag.Int("r", 12, "number of routines")
	_user, _ = user.Current()
	root     = _user.HomeDir + "/.vim/bundle"
	vundle   = &manager{}
)

func main() {
	// Parse the command line into the defined flags
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

// synca install or update a bundle
func (*manager) synca(bundle *string) {
	path := root + "/" + strings.Split(*bundle, "/")[1]
	_, err := os.Stat(path)
	pathExist := !os.IsNotExist(err)

	if pathExist && !*update {
		return
	}

	url := "git://github.com/" + *bundle
	urlHTTP := "http://github.com/" + *bundle

	cmdpath, _ := exec.LookPath("git")
	cmd := &exec.Cmd{Path: cmdpath}

	if !pathExist {
		// Clone the repository
		cmd.Args = []string{"git", "clone", "--depth", "1", "--recursive", "--quiet", url, path}
		cmd.Run()
		fmt.Println(urlHTTP, "cloned")
	} else if *update {
		cmd.Dir = path

		// Update the repository
		cmd.Args = strings.Fields("git pull")
		out, _ := cmd.Output()

		// Update submodules
		if _, err := os.Stat(path + "/.gitmodules"); !os.IsNotExist(err) {
			cmd.Args = strings.Fields("git submodule sync")
			cmd.Run()
			cmd.Args = strings.Fields("git submodule update --init --recursive")
			cmd.Run()
		}

		if len(out) != 0 && out[0] != 'A' {
			fmt.Println(urlHTTP, "updated")
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
			if string(d[strings.LastIndexAny(d, "/\\")+1:]) == strings.Split(b, "/")[1] {
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

// bundles returns the bundle list in which each item contains the partial URL
// like "foo/bar" extracted from "github.com/foo/bar[/baz]".
func bundles(bs ...string) []string {
	bundles := append(bundlesRaw(), bs...)
	for i, v := range bundles {
		// Extract "foo/bar" from "foo/bar/baz/..."
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

// bundlesRaw returns the bundle list obtained from Vim
func bundlesRaw() []string {
	args := []string{
		"-Nesc",
		"set rtp+=~/.vim | let g:_vim_with_all_features = 1 |" +
			"runtime vimrc.bundle | put =dundles | 2,p | q!",
	}

	out, _ := exec.Command("vim", args...).Output()
	bundles := strings.Fields(string(out))

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
