package theme

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/giorgos/dots/mapping"
)

// Info holds metadata about a theme.
type Info struct {
	Name     string
	Dir      string
	HasBtop  bool
	HasDunst bool
	HasStarship bool
	HasRofi  bool
	Files    []string
}

// List returns all themes found in the given themesDir.
func List(themesDir string) ([]Info, error) {
	entries, err := os.ReadDir(themesDir)
	if err != nil {
		return nil, fmt.Errorf("reading themes dir %s: %w", themesDir, err)
	}

	var themes []Info
	for _, e := range entries {
		if !e.IsDir() || strings.HasPrefix(e.Name(), ".") {
			continue
		}
		th, err := load(themesDir, e.Name())
		if err != nil {
			fmt.Fprintf(os.Stderr, "Warning: skipping %s: %v\n", e.Name(), err)
			continue
		}
		themes = append(themes, th)
	}
	return themes, nil
}

func load(themesDir, name string) (Info, error) {
	dir := filepath.Join(themesDir, name)

	info := Info{
		Name: name,
		Dir:  dir,
	}

	entries, err := os.ReadDir(dir)
	if err != nil {
		return info, err
	}

	for _, e := range entries {
		if e.IsDir() {
			if e.Name() == "background" || e.Name() == "backgrounds" {
				info.Files = append(info.Files, e.Name()+"/")
			}
			continue
		}
		info.Files = append(info.Files, e.Name())

		switch e.Name() {
		case "btop.theme":
			info.HasBtop = true
		case "dunstrc":
			info.HasDunst = true
		case "starship.toml":
			info.HasStarship = true
		case "rofi":
			info.HasRofi = true
		}
	}

	return info, nil
}

// Apply symlinks all theme files to their target locations under $HOME.
func Apply(themeDir, homeDir string) error {
	for _, m := range mapping.All {
		src := filepath.Join(themeDir, m.ThemeFile)
		if _, err := os.Stat(src); os.IsNotExist(err) {
			continue // skip missing files
		}

		targetFile := m.TargetFile
		if targetFile == "" {
			targetFile = m.ThemeFile
		}

		// For btop themes, keep the theme name
		if m.ThemeFile == "btop.theme" {
			themeName := filepath.Base(themeDir)
			targetFile = themeName + ".theme"
		}

		target := filepath.Join(homeDir, m.TargetDir, targetFile)

		if err := symlink(src, target); err != nil {
			fmt.Fprintf(os.Stderr, "Warning: failed to symlink %s: %v\n", m.ThemeFile, err)
		} else {
			fmt.Printf("  ✓ %s → %s\n", m.ThemeFile, filepath.Join(m.TargetDir, targetFile))
		}
	}
	return nil
}

// Current checks which theme is currently applied by following symlinks.
func Current(themesDir, homeDir string) string {
	// Check a few key files to determine current theme
	checkFiles := []string{
		".config/hypr/hyprland.conf",
		".config/waybar/style.css",
		".config/ghostty/config",
	}

	for _, rel := range checkFiles {
		target := filepath.Join(homeDir, rel)
		link, err := os.Readlink(target)
		if err != nil {
			continue
		}
		// Walk up from link to find the theme directory
		link = filepath.Clean(link)
		if strings.Contains(link, themesDir) {
			parts := strings.Split(strings.TrimPrefix(link, themesDir+string(filepath.Separator)), string(filepath.Separator))
			if len(parts) > 0 {
				return parts[0]
			}
		}
	}
	return ""
}

func symlink(source, target string) error {
	if _, err := os.Lstat(target); err == nil {
		os.Remove(target)
	} else if !os.IsNotExist(err) {
		return fmt.Errorf("checking %s: %w", target, err)
	}

	if err := os.MkdirAll(filepath.Dir(target), 0755); err != nil {
		return err
	}
	return os.Symlink(source, target)
}
