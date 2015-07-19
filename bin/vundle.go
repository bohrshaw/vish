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
	cuser, _ = user.Current()
	sep      = string(os.PathSeparator)
	root     = cuser.HomeDir + sep + ".vim" + sep + "bundle"
)

// References:
// https://github.com/gpmgo/gopm/blob/master/cmd/get.go
// https://github.com/sourcegraph/go-vcs
func main() {
	// Parse the command line into the defined flags
	flag.Parse()

	bundles := getBundles()

	c := make(chan string, 99)

	// For counting goroutines
	var wg sync.WaitGroup

	// Spawn some worker goroutines
	for i := 0; i < *routines; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for bundle := range c {
				syncBundle(&bundle)
			}
		}()
	}

	// Fill the channel with bundles
	for _, bundle := range bundles {
		c <- bundle
	}
	// Close the channel (after the last sent value is received) to notify
	// receivers stop waiting
	close(c)

	if *clear {
		wg.Add(1)
		go func() {
			clearBundle(&bundles)
			wg.Done()
		}()
	}

	// Wait for all the workers to finish
	wg.Wait()

	helptags()
}

// Sync a bundle
func syncBundle(bundle *string) {
	path := root + sep + strings.Split(*bundle, "/")[1]
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
		if _, err := os.Stat(path + sep + ".gitmodules"); !os.IsNotExist(err) {
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
	dirs, _ := filepath.Glob(root + sep + "*")
	var match bool
	for _, d := range dirs {
		match = false
		for _, b := range *bundles {
			if string(d[strings.LastIndex(d, sep)+1:]) == strings.Split(b, "/")[1] {
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
		"set rtp+=~/.vim | runtime vimrc.bundle | put =dundles | 2,p | q!",
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
		"-Nesu", "NONE",
		"--cmd", `if &rtp !~# '\v[\/]\.vim[,|$]' | set rtp^=~/.vim | endif |` +
			"call rtp#inject() | Helptags | qa",
	}
	if exec.Command("vim", args...).Run() != nil {
		log.Printf("Fail to generate help tags.")
	}
}

// vim:fdm=syntax:
