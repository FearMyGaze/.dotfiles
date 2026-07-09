package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

const version = "0.1.0"

func main() {
	if len(os.Args) < 2 {
		printUsage()
		return
	}

	repoDir := findRepoDir()

	switch os.Args[1] {
	case "theme":
		if len(os.Args) < 3 {
			fmt.Println("Usage: dots theme <list|apply|current|generate>")
			return
		}
		switch os.Args[2] {
		case "list":
			cmdThemeList(repoDir)
		case "apply":
			if len(os.Args) < 4 {
				fmt.Println("Usage: dots theme apply <theme-name>")
				return
			}
			cmdThemeApply(repoDir, os.Args[3])
		case "current":
			cmdThemeCurrent()
		case "generate":
			if len(os.Args) < 4 {
				fmt.Println("Usage: dots theme generate <theme-name>")
				return
			}
			cmdThemeGenerate(repoDir, os.Args[3])
		case "render":
			if len(os.Args) < 4 {
				fmt.Println("Usage: dots theme render <theme-name>")
				return
			}
			cmdThemeRender(repoDir, os.Args[3])
		case "templates":
			cmdListTemplates(repoDir)
		default:
			fmt.Printf("Unknown theme command: %s\n", os.Args[2])
		}

	case "stow":
		cmdStow(repoDir)

	case "unstow":
		cmdUnstow(repoDir)

	case "doom":
		if len(os.Args) < 3 {
			fmt.Println("Usage: dots doom <install|sync>")
			return
		}
		switch os.Args[2] {
		case "install":
			cmdDoomInstall(repoDir)
		case "sync":
			cmdDoomSync()
		default:
			fmt.Printf("Unknown doom command: %s\n", os.Args[2])
		}

	case "help", "--help", "-h":
		printUsage()

	case "version", "--version", "-v":
		fmt.Printf("dots version %s\n", version)

	default:
		fmt.Printf("Unknown command: %s\n", os.Args[1])
		printUsage()
	}
}

func printUsage() {
	fmt.Println(`dots — Dotfile & Theme Manager

Usage:
  dots theme list              List available themes
  dots theme apply <name>      Apply a theme (symlink configs)
  dots theme current           Show currently applied theme
  dots theme generate <name>   Generate missing config files for a theme
  dots theme render <name>     Render themed templates into theme directory
  dots theme templates         List available themed templates
  dots stow                    Stow all dotfiles to $HOME
  dots unstow                  Unstow all dotfiles from $HOME
  dots doom install            Install Doom Emacs config
  dots doom sync               Run 'doom sync'
  dots help                    Show this help
  dots version                 Show version`)
}

func findRepoDir() string {
	for _, start := range []string{
		func() string { e, err := os.Executable(); if err != nil { return "" }; return filepath.Dir(e) }(),
		func() string { c, err := os.Getwd(); if err != nil { return "" }; return c }(),
	} {
		if start == "" {
			continue
		}
		dir := start
		for {
			if _, err := os.Stat(filepath.Join(dir, "themes")); err == nil {
				return dir
			}
			parent := filepath.Dir(dir)
			if parent == dir {
				break
			}
			dir = parent
		}
	}
	return "."
}

func homeDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: cannot find home directory: %v\n", err)
		os.Exit(1)
	}
	return home
}

func ensureDir(dir string) {
	if err := os.MkdirAll(dir, 0755); err != nil {
		fmt.Fprintf(os.Stderr, "Error creating directory %s: %v\n", dir, err)
		os.Exit(1)
	}
}

func symlink(source, target string) error {
	// Remove existing file/symlink if it exists
	if _, err := os.Lstat(target); err == nil {
		os.Remove(target)
	} else if !os.IsNotExist(err) {
		return fmt.Errorf("checking %s: %w", target, err)
	}

	ensureDir(filepath.Dir(target))
	return os.Symlink(source, target)
}

func detectPlatform() string {
	if _, err := os.Stat("/etc/nixos"); err == nil {
		return "nixos"
	}
	return "macos"
}

// dirName returns the platform-specific dotfiles directory name.
func dirName() string {
	// Match the convention from save-dotfiles.sh
	switch detectPlatform() {
	case "nixos":
		return "linux-nixos"
	default:
		return "macos"
	}
}

// ColorPalette represents the 16-color terminal palette + UI colors.
type ColorPalette struct {
	Accent             string
	Cursor             string
	Foreground         string
	Background         string
	SelectionForeground string
	SelectionBackground string
	Colors             [16]string
}

// LoadPalette parses a colors.toml file and returns a ColorPalette.
func LoadPalette(path string) (ColorPalette, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return ColorPalette{}, fmt.Errorf("reading %s: %w", path, err)
	}

	p := ColorPalette{}
	lines := strings.Split(string(data), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}

		key := strings.TrimSpace(parts[0])

		// Extract the quoted value properly, handling TOML inline comments
		rawVal := strings.TrimSpace(parts[1])
		val := ""
		if start := strings.Index(rawVal, "\""); start >= 0 {
			// Find the closing quote
			end := strings.Index(rawVal[start+1:], "\"")
			if end >= 0 {
				val = rawVal[start+1 : start+1+end]
			} else {
				val = strings.Trim(rawVal, "\"")
			}
		} else {
			val = strings.Trim(rawVal, "\"")
		}

		switch key {
		case "accent":
			p.Accent = val
		case "cursor":
			p.Cursor = val
		case "foreground":
			p.Foreground = val
		case "background":
			p.Background = val
		case "selection_foreground":
			p.SelectionForeground = val
		case "selection_background":
			p.SelectionBackground = val
		default:
			if n, ok := parseColorKey(key); ok && n >= 0 && n < 16 {
				p.Colors[n] = val
			}
		}
	}

	return p, nil
}

func parseColorKey(key string) (int, bool) {
	var n int
	if _, err := fmt.Sscanf(key, "color%d", &n); err == nil {
		return n, true
	}
	return 0, false
}

// HexToRGB converts "#rrggbb" to (r, g, b) ints.
func HexToRGB(hex string) (int, int, int) {
	hex = strings.TrimPrefix(hex, "#")
	if len(hex) != 6 {
		return 0, 0, 0
	}
	r, g, b := 0, 0, 0
	fmt.Sscanf(hex, "%02x%02x%02x", &r, &g, &b)
	return r, g, b
}

// HexToRGBA converts "#rrggbb" to an rgba() string with given alpha.
func HexToRGBA(hex string, alpha float64) string {
	r, g, b := HexToRGB(hex)
	return fmt.Sprintf("rgba(%d, %d, %d, %.1f)", r, g, b, alpha)
}
