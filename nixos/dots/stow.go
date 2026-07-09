package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// Stowable config entries.
var stowEntries = []struct {
	Src  string // relative to platform dir
	Dest string // relative to $HOME
	IsDir bool  // is a directory (copy contents)
}{
	{Src: ".gitconfig", Dest: ".gitconfig", IsDir: false},
	{Src: ".zshenv", Dest: ".zshenv", IsDir: false},
	{Src: ".zprofile", Dest: ".zprofile", IsDir: false},
	{Src: ".zshrc", Dest: ".zshrc", IsDir: false},
	{Src: ".config/ghostty", Dest: ".config/ghostty", IsDir: true},
	{Src: ".config/zed", Dest: ".config/zed", IsDir: true},
	{Src: ".config/doom", Dest: ".config/doom", IsDir: true},
	{Src: ".config/yazi", Dest: ".config/yazi", IsDir: true},
}

func cmdStow(repoDir string) {
	platform := dirName()
	platformDir := filepath.Join(repoDir, platform)

	if _, err := os.Stat(platformDir); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "Error: platform directory %q not found\n", platformDir)
		os.Exit(1)
	}

	home := homeDir()
	fmt.Printf("Stowing dotfiles for %s platform...\n", platform)
	count := 0

	for _, e := range stowEntries {
		src := filepath.Join(platformDir, e.Src)
		if _, err := os.Stat(src); os.IsNotExist(err) {
			continue
		}
		dst := filepath.Join(home, e.Dest)

		if e.IsDir {
			// Copy directory contents, merging with existing
			entries, err := os.ReadDir(src)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Warning: reading %s: %v\n", src, err)
				continue
			}
			for _, entry := range entries {
				entrySrc := filepath.Join(src, entry.Name())
				entryDst := filepath.Join(dst, entry.Name())
				if err := symlink(entrySrc, entryDst); err != nil {
					fmt.Fprintf(os.Stderr, "Warning: %s: %v\n", entry.Name(), err)
				}
				fmt.Printf("  ✓ %s/%s\n", e.Dest, entry.Name())
				count++
			}
		} else {
			if err := symlink(src, dst); err != nil {
				fmt.Fprintf(os.Stderr, "Warning: %s: %v\n", e.Src, err)
			}
			fmt.Printf("  ✓ %s\n", e.Src)
			count++
		}
	}

	if count == 0 {
		fmt.Println("  No dotfiles to stow (run 'make save' first)")
	} else {
		fmt.Printf("Stowed %d item(s)\n", count)
	}
}

func cmdUnstow(repoDir string) {
	home := homeDir()
	fmt.Println("Removing dotfile symlinks...")
	count := 0

	for _, e := range stowEntries {
		dst := filepath.Join(home, e.Dest)

		if e.IsDir {
			entries, err := os.ReadDir(dst)
			if err != nil {
				continue
			}
			for _, entry := range entries {
				entryPath := filepath.Join(dst, entry.Name())
				link, err := os.Readlink(entryPath)
				if err != nil {
					continue
				}
				if strings.Contains(link, repoDir) {
					os.Remove(entryPath)
					fmt.Printf("  ✗ %s/%s\n", e.Dest, entry.Name())
					count++
				}
			}
		} else {
			link, err := os.Readlink(dst)
			if err != nil {
				continue
			}
			if strings.Contains(link, repoDir) {
				os.Remove(dst)
				fmt.Printf("  ✗ %s\n", e.Src)
				count++
			}
		}
	}

	if count == 0 {
		fmt.Println("  No managed symlinks found")
	} else {
		fmt.Printf("Removed %d symlink(s)\n", count)
	}
}
