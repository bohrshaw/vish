package main

import (
	"fmt"
	"regexp"
	"testing"
)

func TestBundles(t *testing.T) {
	bundles := bundles("foo/bar/baz", "hello/world/you")
	if len(bundles) == 0 {
		t.Fatal("No bundles at all!")
	}
	if testing.Verbose() {
		fmt.Println(len(bundles), "Bundles:", bundles)
	}
	r := regexp.MustCompile(`^[[:word:]-.]+/[[:word:]-.]+$`)
	for _, b := range bundles {
		if !r.MatchString(b) {
			t.Fatal("Wrong bundle format:", b)
		}
	}
}
