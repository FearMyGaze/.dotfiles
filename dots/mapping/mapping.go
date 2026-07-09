package mapping

// Entry maps a theme file to its target config location.
type Entry struct {
	ThemeFile string // filename inside the theme directory
	TargetDir string // relative to $HOME (e.g. ".config/hypr")
	TargetFile string // target filename (empty = use ThemeFile)
}

// ThemeTargetDir is where symlinks are placed when applying.
const ThemeTargetDir = ".config"

// Mappings for all supported apps.
var All = []Entry{
	{ThemeFile: "hyprland.conf", TargetDir: ".config/hypr"},
	{ThemeFile: "hyprland.lua", TargetDir: ".config/hypr"},
	{ThemeFile: "hyprlock.conf", TargetDir: ".config/hypr"},
	{ThemeFile: "waybar.css", TargetDir: ".config/waybar", TargetFile: "style.css"},
	{ThemeFile: "ghostty.conf", TargetDir: ".config/ghostty", TargetFile: "config"},
	{ThemeFile: "kitty.conf", TargetDir: ".config/kitty"},
	{ThemeFile: "btop.theme", TargetDir: ".config/btop/themes"},
	{ThemeFile: "colors.toml", TargetDir: ".config/omarchy"},
	{ThemeFile: "wofi.css", TargetDir: ".config/wofi", TargetFile: "style.css"},
	{ThemeFile: "gtk.css", TargetDir: ".config/gtk-3.0"},
	{ThemeFile: "gtk.css", TargetDir: ".config/gtk-4.0"},
	{ThemeFile: "superfile.toml", TargetDir: ".config/superfile", TargetFile: "config.toml"},
	{ThemeFile: "mako.ini", TargetDir: ".config/mako"},
	{ThemeFile: "starship.toml", TargetDir: ".config"},
	{ThemeFile: "vencord.theme.css", TargetDir: ".config/Vencord/themes"},
	{ThemeFile: "neovim.lua", TargetDir: ".config/nvim/lua", TargetFile: "theme.lua"},
	{ThemeFile: "alacritty.toml", TargetDir: ".config/alacritty"},
	{ThemeFile: "chromium.theme", TargetDir: ".config/chromium/Default"},
	{ThemeFile: "swayosd.css", TargetDir: ".config/swayosd"},
	{ThemeFile: "walker.css", TargetDir: ".config/walker"},
	{ThemeFile: "rofi/config.rasi", TargetDir: ".config/rofi"},
	{ThemeFile: "firefox/chrome/userChrome.css", TargetDir: ".config/firefox-devedition/chrome"},
}

// BaseFiles are always symlinked from defaults/dirname regardless of theme.
var BaseDir = map[string][]Entry{
	"hypr": {
		{ThemeFile: "autostart.conf", TargetDir: ".config/hypr"},
		{ThemeFile: "input.conf", TargetDir: ".config/hypr"},
	},
}

// GeneratedFiles lists configs we can generate from the color palette.
var Generated = []struct {
	File  string
	Label string
}{
	{File: "mako.ini", Label: "mako notification daemon"},
	{File: "starship.toml", Label: "starship prompt"},
	{File: "rofi/config.rasi", Label: "rofi launcher"},
	{File: "firefox/chrome/userChrome.css", Label: "firefox userchrome"},
}
