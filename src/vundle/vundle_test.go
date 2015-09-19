package main

import (
	"fmt"
	"regexp"
	"testing"
)

func TestGetBundles(t *testing.T) {
	bspecs := []string{"foo/bar", "foo/bar/baz", "a/b:", "a/b:br", "a/b:br/dir/dir"}
	bundles := getBundles(bspecs...)
	if len(bundles) == 0 {
		t.Fatal("No bundles at all!")
	}
	if testing.Verbose() {
		fmt.Printf("%v Bundles(including %v test bundles): %v\n", len(bundles), len(bspecs), bundles)
	}
	r := regexp.MustCompile(`^[[:word:]-.]+/[[:word:]-.:]+$`)
	for _, b := range append(bundles) {
		if !r.MatchString(b) {
			t.Fatal("Wrong bundle format:", b)
		}
	}
}
