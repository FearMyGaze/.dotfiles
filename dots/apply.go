package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/giorgos/dots/mapping"
	"github.com/giorgos/dots/theme"
)

func cmdThemeList(repoDir string) {
	themesDir := filepath.Join(repoDir, "themes")

	themes, err := theme.List(themesDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	if len(themes) == 0 {
		fmt.Println("No themes found in themes/")
		return
	}

	currentName := theme.Current(themesDir, homeDir())

	fmt.Println("Available themes:")
	for _, th := range themes {
		mark := " "
		if th.Name == currentName {
			mark = "→"
		}
		fmt.Printf("  %s %s\n", mark, th.Name)
		for _, f := range th.Files {
			fmt.Printf("      %s\n", f)
		}
	}
}

func cmdThemeApply(repoDir, name string) {
	themeDir := filepath.Join(repoDir, "themes", name)

	if _, err := os.Stat(themeDir); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "Error: theme %q not found in themes/\n", name)
		os.Exit(1)
	}

	home := homeDir()
	fmt.Printf("Applying theme %q...\n", name)

	theme.Apply(themeDir, home)
	applyBaseDefaults(repoDir, home)
	fmt.Println("Done!")
}

func applyBaseDefaults(repoDir, home string) {
	for dir, entries := range mapping.BaseDir {
		srcDir := filepath.Join(repoDir, "defaults", dir)
		if _, err := os.Stat(srcDir); os.IsNotExist(err) {
			continue
		}
		for _, e := range entries {
			src := filepath.Join(srcDir, e.ThemeFile)
			if _, err := os.Stat(src); os.IsNotExist(err) {
				continue
			}
			targetFile := e.TargetFile
			if targetFile == "" {
				targetFile = e.ThemeFile
			}
			target := filepath.Join(home, e.TargetDir, targetFile)
			if err := symlink(src, target); err != nil {
				fmt.Fprintf(os.Stderr, "Warning: failed to symlink %s: %v\n", e.ThemeFile, err)
			} else {
				fmt.Printf("  ✓ %s → %s\n", e.ThemeFile, filepath.Join(e.TargetDir, targetFile))
			}
		}
	}
}

func cmdThemeCurrent() {
	repoDir := findRepoDir()
	themesDir := filepath.Join(repoDir, "themes")
	currentName := theme.Current(themesDir, homeDir())

	if currentName == "" {
		fmt.Println("No theme currently applied")
	} else {
		fmt.Println(currentName)
	}
}

func cmdThemeGenerate(repoDir, name string) {
	themeDir := filepath.Join(repoDir, "themes", name)
	palettePath := filepath.Join(themeDir, "colors.toml")

	if _, err := os.Stat(palettePath); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "Error: no colors.toml found in theme %q\n", name)
		fmt.Fprintf(os.Stderr, "Cannot generate missing configs without a color palette.\n")
		os.Exit(1)
	}

	palette, err := LoadPalette(palettePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading palette: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Generating missing configs for theme %q...\n", name)
	generated := 0

	for _, g := range mapping.Generated {
		targetPath := filepath.Join(themeDir, g.File)
		if _, err := os.Stat(targetPath); err == nil {
			continue // already exists
		}

		dir := filepath.Dir(targetPath)
		if err := os.MkdirAll(dir, 0755); err != nil {
			fmt.Fprintf(os.Stderr, "Error creating dir %s: %v\n", dir, err)
			continue
		}

		content, err := generateConfig(g.File, palette)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Warning: %v\n", err)
			continue
		}
		if err := os.WriteFile(targetPath, []byte(content), 0644); err != nil {
			fmt.Fprintf(os.Stderr, "Error writing %s: %v\n", g.File, err)
			continue
		}

		fmt.Printf("  ✓ %s (%s)\n", g.File, g.Label)
		generated++
	}

	if generated == 0 {
		fmt.Println("  All configs already exist!")
	} else {
		fmt.Printf("Generated %d config file(s)\n", generated)
	}
}

func cmdListTemplates(repoDir string) {
	templatesDir := filepath.Join(repoDir, "defaults", "themed")
	entries, err := os.ReadDir(templatesDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("Available themed templates:")
	for _, e := range entries {
		if !e.IsDir() {
			fmt.Printf("  %s\n", e.Name())
		}
	}
}

func cmdThemeRender(repoDir, name string) {
	themeDir := filepath.Join(repoDir, "themes", name)
	palettePath := filepath.Join(themeDir, "colors.toml")
	templatesDir := filepath.Join(repoDir, "defaults", "themed")

	if _, err := os.Stat(palettePath); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "Error: no colors.toml found in theme %q\n", name)
		os.Exit(1)
	}

	palette, err := LoadPalette(palettePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading palette: %v\n", err)
		os.Exit(1)
	}

	entries, err := os.ReadDir(templatesDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading templates: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Rendering templates for theme %q...\n", name)
	rendered := 0

	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".tpl") {
			continue
		}

		// Determine output file (strip .tpl suffix)
		outName := strings.TrimSuffix(e.Name(), ".tpl")
		outPath := filepath.Join(themeDir, outName)

		// Skip if file already exists (community themes provide full configs)
		if _, err := os.Stat(outPath); err == nil {
			continue
		}

		// Read template
		tplPath := filepath.Join(templatesDir, e.Name())
		tplData, err := os.ReadFile(tplPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Warning: reading %s: %v\n", e.Name(), err)
			continue
		}

		// Render template
		content := renderTemplate(string(tplData), palette)
		if err := os.WriteFile(outPath, []byte(content), 0644); err != nil {
			fmt.Fprintf(os.Stderr, "Warning: writing %s: %v\n", outName, err)
			continue
		}

		fmt.Printf("  ✓ %s\n", outName)
		rendered++
	}

	if rendered == 0 {
		fmt.Println("  No templates to render")
	} else {
		fmt.Printf("Rendered %d template(s) to %q\n", rendered, name)
	}
}

func renderTemplate(tpl string, p ColorPalette) string {
	r := strings.NewReplacer(
		"{{ background }}", p.Background,
		"{{ foreground }}", p.Foreground,
		"{{ accent }}", p.Accent,
		"{{ cursor }}", p.Cursor,
		"{{ selection_background }}", p.SelectionBackground,
		"{{ selection_foreground }}", p.SelectionForeground,
		"{{ color0 }}", p.Colors[0],
		"{{ color1 }}", p.Colors[1],
		"{{ color2 }}", p.Colors[2],
		"{{ color3 }}", p.Colors[3],
		"{{ color4 }}", p.Colors[4],
		"{{ color5 }}", p.Colors[5],
		"{{ color6 }}", p.Colors[6],
		"{{ color7 }}", p.Colors[7],
		"{{ color8 }}", p.Colors[8],
		"{{ color9 }}", p.Colors[9],
		"{{ color10 }}", p.Colors[10],
		"{{ color11 }}", p.Colors[11],
		"{{ color12 }}", p.Colors[12],
		"{{ color13 }}", p.Colors[13],
		"{{ color14 }}", p.Colors[14],
		"{{ color15 }}", p.Colors[15],
		"{{ background_strip }}", strings.TrimPrefix(p.Background, "#"),
		"{{ foreground_strip }}", strings.TrimPrefix(p.Foreground, "#"),
		"{{ accent_strip }}", strings.TrimPrefix(p.Accent, "#"),
		"{{ cursor_strip }}", strings.TrimPrefix(p.Cursor, "#"),
		"{{ selection_background_strip }}", strings.TrimPrefix(p.SelectionBackground, "#"),
		"{{ selection_foreground_strip }}", strings.TrimPrefix(p.SelectionForeground, "#"),
	)
	// Handle _strip variants for all colors
	result := r.Replace(tpl)
	for i := 0; i < 16; i++ {
		result = strings.ReplaceAll(result,
			fmt.Sprintf("{{ color%d_strip }}", i),
			strings.TrimPrefix(p.Colors[i], "#"))
	}

	// Handle _rgb variants
	bgR, bgG, bgB := HexToRGB(p.Background)
	fgR, fgG, fgB := HexToRGB(p.Foreground)
	acR, acG, acB := HexToRGB(p.Accent)
	result = strings.ReplaceAll(result, "{{ background_rgb }}",
		fmt.Sprintf("%d, %d, %d", bgR, bgG, bgB))
	result = strings.ReplaceAll(result, "{{ foreground_rgb }}",
		fmt.Sprintf("%d, %d, %d", fgR, fgG, fgB))
	result = strings.ReplaceAll(result, "{{ accent_rgb }}",
		fmt.Sprintf("%d, %d, %d", acR, acG, acB))

	return result
}

func generateConfig(file string, p ColorPalette) (string, error) {
	switch file {
	case "mako.ini":
		return generateMako(p), nil
	case "starship.toml":
		return generateStarship(p), nil
	case "rofi/config.rasi":
		return generateRofi(p), nil
	case "firefox/chrome/userChrome.css":
		return generateFirefox(p), nil
	default:
		return "", fmt.Errorf("unknown generated config type: %q", file)
	}
}

func generateMako(p ColorPalette) string {
	return fmt.Sprintf(`# Generated by dots — mako configuration
# Based on omarchy theme colors

background-color=%s
text-color=%s
border-color=%s
border-size=2
border-radius=6
default-timeout=10000
ignore-timeout=0
width=400
height=300
padding=12
horizontal-padding=12
font=JetBrainsMono Nerd Font 10
markup=1
format=<b>%%s</b>\n%%b
icons=1
max-icon-size=64
icon-path=/usr/share/icons/hicolor/48x48/status/:/usr/share/icons/hicolor/48x48/devices/
layer=overlay
anchor=top-right
margin=10,50
group-by=app-name
sort=+time

[urgency=low]
background-color=%s
text-color=%s
border-color=%s

[urgency=normal]
background-color=%s
text-color=%s
border-color=%s

[urgency=high]
background-color=%s
text-color=%s
border-color=%s
`,
		p.Background,       // default background
		p.Foreground,       // default text
		p.Colors[8],        // default border
		p.Background,       // low bg
		p.Foreground,       // low text
		p.Colors[3],        // low border
		p.Background,       // normal bg
		p.Foreground,       // normal text
		p.Accent,           // normal border
		p.Colors[1],        // high bg
		p.Foreground,       // high text
		p.Colors[1],        // high border
	)
}

func generateStarship(p ColorPalette) string {
	c := func(idx int) string { return p.Colors[idx] }

	return fmt.Sprintf(`# Generated by dots — starship prompt
# Based on omarchy theme colors

format = """\
[](fg:%[1]s)\
$os\
$username\
[](fg:%[1]s)\
$directory\
[](fg:%[2]s)\
$git_branch\
$git_status\
[](fg:%[5]s)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
$docker_context\
$fill\
$lua\
$aws\
$nix_shell\
$cmd_duration\
$line_break\
$character\
"""

[os]
disabled = false
style = "bg:%[1]s fg:%[8]s"

[os.style]
bg = "%[1]s"
fg = "%[8]s"

[username]
show_always = true
style_user = "bg:%[1]s fg:%[8]s"
style_root = "bg:%[3]s fg:%[8]s"
format = '[$user ]($style)'

[directory]
style = "fg:%[7]s bg:%[9]s"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = " "
style = "bg:%[1]s fg:%[8]s"
format = '[[ $symbol $branch ](bg:%[1]s fg:%[8]s)]($style)'

[git_status]
style = "fg:%[2]s"

[cmd_duration]
format = "⏱️ $duration "
style = "fg:%[9]s"

[character]
success_symbol = "[❯](%[2]s)"
error_symbol = "[❯](%[3]s)"
vimcmd_symbol = "[❮](%[1]s)"

[fill]
style = "%[9]s"

# Language modules
[c]
symbol = "C "
style = "fg:%[1]s"

[rust]
symbol = " "
style = "fg:%[2]s"

[golang]
symbol = "Go "
style = "fg:%[1]s"

[nodejs]
symbol = " "
style = "fg:%[4]s"

[python]
symbol = " "
style = "fg:%[5]s"

[java]
symbol = "Java "
style = "fg:%[1]s"

[docker_context]
symbol = "  "
style = "fg:%[1]s"

[nix_shell]
symbol = "❄️ "
style = "fg:%[2]s"

[lua]
symbol = "Lua "
style = "fg:%[1]s"

[aws]
symbol = "☁️ "
style = "fg:%[1]s"

[php]
symbol = "PHP "
style = "fg:%[5]s"

[kotlin]
symbol = "Kotlin "
style = "fg:%[1]s"

[haskell]
symbol = "λ "
style = "fg:%[2]s"
`, p.Accent, c(2), c(1), c(3), c(5), c(4), c(7), c(0), c(8))
}

func generateRofi(p ColorPalette) string {
	return fmt.Sprintf(`/* Generated by dots — rofi configuration */
/* Based on omarchy theme colors */

* {
    bg:     %[1]s;
    fg:     %[2]s;
    accent: %[3]s;
    urgent: %[4]s;
    surface:%[5]s;
}

window {
    background-color: @bg;
    border: 2px solid @accent;
    border-radius: 8px;
    width: 600px;
}

mainbox {
    background-color: @bg;
    padding: 12px;
    spacing: 8px;
}

inputbar {
    background-color: @surface;
    text-color: @fg;
    border-radius: 6px;
    padding: 8px;
    spacing: 6px;
    children: [ prompt, entry ];
}

entry {
    text-color: @fg;
    cursor-color: @accent;
}

prompt {
    text-color: @accent;
}

listview {
    background-color: @bg;
    spacing: 4px;
    padding: 4px;
    lines: 10;
}

element {
    background-color: @bg;
    text-color: @fg;
    padding: 6px;
    border-radius: 4px;
}

element selected {
    background-color: @accent;
    text-color: @bg;
}

element urgent {
    background-color: @urgent;
    text-color: @bg;
}

scrollbar {
    width: 6px;
    handle-color: @accent;
}

sidebar {
    background-color: @bg;
    border: 0px;
}
`,
		p.Background,
		p.Foreground,
		p.Accent,
		p.Colors[1], // urgent (red)
		p.Colors[8], // surface (bright black)
	)
}

func generateFirefox(p ColorPalette) string {
	return fmt.Sprintf(`/* Generated by dots — Firefox userChrome.css */
/* Based on omarchy theme colors */

:root {
  --uc-bg: %[1]s;
  --uc-fg: %[2]s;
  --uc-accent: %[3]s;
  --uc-border: %[4]s;
}

/* Url bar */
#urlbar,
#searchbar {
  background-color: var(--uc-bg) !important;
  color: var(--uc-fg) !important;
  border-color: var(--uc-border) !important;
}

#urlbar:focus-within,
#searchbar:focus-within {
  border-color: var(--uc-accent) !important;
}

/* Tab bar */
.tabbrowser-tab {
  background-color: var(--uc-bg) !important;
  color: var(--uc-fg) !important;
}

.tabbrowser-tab[selected] {
  border-bottom: 2px solid var(--uc-accent) !important;
}

/* Navigation toolbar */
#nav-bar {
  background-color: var(--uc-bg) !important;
  color: var(--uc-fg) !important;
}

/* Sidebar */
#sidebar-box {
  background-color: var(--uc-bg) !important;
  color: var(--uc-fg) !important;
}

/* General UI */
#main-window {
  background-color: var(--uc-bg) !important;
}

/* Menus */
menupopup,
popup {
  background-color: var(--uc-bg) !important;
  color: var(--uc-fg) !important;
}
`,
		p.Background,
		p.Foreground,
		p.Accent,
		p.Colors[8], // border
	)
}
