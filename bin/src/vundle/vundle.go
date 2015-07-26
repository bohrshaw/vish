package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
)

var (
	update   = flag.Bool("u", false, "update bundles")
	clear    = flag.Bool("c", false, "clear bundles")
	routines = flag.Int("r", 12, "number of routines")
	_user, _ = user.Current()
	root     = _user.HomeDir + "/.vim/bundle"
)

// References:
// https://github.com/gpmgo/gopm/blob/master/cmd/get.go
// https://github.com/sourcegraph/go-vcs
func main() {
	// Parse the command line into the defined flags
	flag.Parse()

	var (
		bundles = getBundles()
		ch      = make(chan string, 9)
	)
	var wg sync.WaitGroup // count of goroutines

	// Spawn some worker goroutines
	for i := 0; i < *routines; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for bundle := range ch {
				syncBundle(&bundle)
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
			clearBundle(&bundles)
			wg.Done()
		}()
	}

	wg.Wait()

	helptags()
}

// Sync a bundle
func syncBundle(bundle *string) {
	path := root + "/" + strings.Split(*bundle, "/")[1]
	_, err := os.Stat(path)
	path_exist := !os.IsNotExist(err)

	if path_exist && !*update {
		return
	}

	url := "git://github.com/" + *bundle
	urlHTTP := "http://github.com/" + *bundle

	cmdpath, _ := exec.LookPath("git")
	cmd := &exec.Cmd{Path: cmdpath}

	if !path_exist {
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

// Remove disabled bundles
func clearBundle(bundles *[]string) {
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

// Get the bundle list
func getBundles() []string {
	args := []string{
		"-Nesc",
		"set rtp+=~/.vim | let g:_vim_with_all_features = 1 |" +
			"runtime vimrc.bundle | put =dundles | 2,p | q!",
	}

	bundles, _ := exec.Command("vim", args...).Output()

	// Extract the partial URL if a bundle includes additional directories
	extract := func(items []string) []string {
		matcher := regexp.MustCompile(`/.+?/`)
		extractor := regexp.MustCompile(`[^/]+?/[^/]+`)
		for i, v := range items {
			if matcher.MatchString(v) {
				items[i] = extractor.FindString(v)
			}
		}
		return items
	}

	return extract(strings.Fields(string(bundles)))
}

// Generate help tags
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
