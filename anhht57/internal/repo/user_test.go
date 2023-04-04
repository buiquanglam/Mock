package repo

import (
	"testing"
)

func TestBeingtestfunc(t *testing.T) {
	result := beingtestfunc("mặc kệ em")
	if result != "mặc kệ em" {
		t.Errorf("err")
	}
}
