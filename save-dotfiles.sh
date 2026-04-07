#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

case "$OS" in
    Darwin) TARGET_DIR="macos" ;;
    Linux)  TARGET_DIR="linux" ;;
    *) echo "Unknown OS: $OS"; exit 1 ;;
esac

echo "Detected OS: $OS → $TARGET_DIR"

save_item() {
    local item="$1"
    local full_path="$HOME/$item"
    local basename="$(basename "$item")"
    local first_part="$(echo "$item" | cut -d'/' -f1)"
    
    if [[ -e "$full_path" ]]; then
        if [[ "$item" == .* && $(echo "$item" | tr -cd '/' | wc -c) -eq 0 ]]; then
            cp "$full_path" "$REPO_DIR/$TARGET_DIR/$basename"
        elif [[ "$item" == .* ]]; then
            mkdir -p "$REPO_DIR/$TARGET_DIR/$first_part"
            cp -r "$full_path" "$REPO_DIR/$TARGET_DIR/$first_part/"
        else
            mkdir -p "$REPO_DIR/$TARGET_DIR/$first_part"
            cp -r "$full_path"/* "$REPO_DIR/$TARGET_DIR/$first_part/" 2>/dev/null || cp -r "$full_path" "$REPO_DIR/$TARGET_DIR/$first_part/"
        fi
        echo "✓ Saved: $item"
    else
        echo "✗ Not found: $item"
    fi
}

items=(
    ".gitconfig"
    ".bashrc"
    ".bash_profile"
    ".config/doom"
    ".config/ghostty"
    ".config/fish"
    ".config/fish/completions"
    ".config/fish/conf.d"
    ".config/fish/functions"
)

echo ""
echo "Saving to $TARGET_DIR/..."
for item in "${items[@]}"; do
    save_item "$item"
done

echo ""
echo "Done! Run 'make deploy' to symlink them."