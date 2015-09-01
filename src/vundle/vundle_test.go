package main

import (
	"fmt"
	"regexp"
	"testing"
)

func TestGetBundles(t *testing.T) {
	bundles := GetBundles()
	if testing.Verbose() {
		fmt.Println("Bundles: ", bundles)
	}
	if len(bundles) == 0 {
		t.Fatal("No bundles at all!")
	}
	if !regexp.MustCompile(`\w+/\w+`).MatchString(bundles[0]) {
		t.Fatal("Wrong bundle format: bundles[0]")
	}
}
