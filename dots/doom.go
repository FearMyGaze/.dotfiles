package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

func cmdDoomInstall(repoDir string) {
	platform := dirName()
	srcDir := filepath.Join(repoDir, platform, ".config", "doom")

	if _, err := os.Stat(srcDir); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "Error: Doom Emacs config not found at %s\n", srcDir)
		fmt.Fprintf(os.Stderr, "Run 'make save' or create it manually.\n")
		os.Exit(1)
	}

	home := homeDir()
	dstDir := filepath.Join(home, ".config", "doom")

	fmt.Println("Installing Doom Emacs configuration...")

	// Symlink each file in the doom directory
	entries, err := os.ReadDir(srcDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading doom dir: %v\n", err)
		os.Exit(1)
	}

	count := 0
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		src := filepath.Join(srcDir, e.Name())
		dst := filepath.Join(dstDir, e.Name())

		if err := symlink(src, dst); err != nil {
			fmt.Fprintf(os.Stderr, "Warning: %s: %v\n", e.Name(), err)
			continue
		}
		fmt.Printf("  ✓ %s\n", e.Name())
		count++
	}

	if count == 0 {
		fmt.Println("  No files found in doom config directory")
	} else {
		fmt.Printf("Installed %d Doom config file(s)\n", count)
		fmt.Println("\nRun 'dots doom sync' to activate.")
	}
}

func cmdDoomSync() {
	fmt.Println("Running 'doom sync'...")

	cmd := exec.Command("doom", "sync")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error running doom sync: %v\n", err)
		fmt.Fprintf(os.Stderr, "Make sure Doom Emacs is installed.\n")
		os.Exit(1)
	}

	fmt.Println("Doom Emacs is now in sync!")
}
