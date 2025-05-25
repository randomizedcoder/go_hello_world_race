package main

import (
	"testing"
)

var shared int

func TestRace(t *testing.T) {
	done := make(chan bool)
	go func() {
		shared++
		done <- true
	}()
	shared++
	<-done
}
