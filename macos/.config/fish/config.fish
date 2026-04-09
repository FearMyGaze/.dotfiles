#######################################
## Path Variables
#######################################

# Editors
set -x EDITOR "zed"
set -x VISUAL "zed"

# Bun
set -x BUN_INSTALL "$HOME/.bun"

# PATH
set -x PATH \
    $HOME/.config/emacs/bin \
    $HOME/.cargo/bin \
    /opt/homebrew/opt/openjdk/bin \
    $HOME/go/bin \
    /opt/homebrew/opt/node@20/bin \
    /opt/homebrew/bin \
    /opt/homebrew/sbin \
    $HOME/.local/bin \
    $HOME/.orbstack/bin \
    $BUN_INSTALL/bin \
    $HOME/Library/Android/sdk/platform-tools \
    $PATH

# Compiler / linker flags
set -x CPPFLAGS "-I/opt/homebrew/opt/openjdk/include -I/opt/homebrew/opt/node@20/include"
set -x LDFLAGS "-L/opt/homebrew/opt/node@20/lib"

#######################################
## fish customization
#######################################

#This is from Adam Savages from Tested lathe
set --global fish_greeting (set_color red)"Be careful "\n(set_color normal)"This machine has no brain use your own"
set --global hydro_symbol_prompt \uea9c
set --global hydro_color_prompt "#FFB000"
set --global hydro_symbol_git_dirty \uf1d2


alias defaultKeyRepeat "defaults write -g InitialKeyRepeat -int 12 && defaults write -g KeyRepeat -int 1 && echo (set_color red)'Settings applied' "
alias showHiddenFiles  "defaults write com.apple.finder AppleShowAllFiles YES && killall Finder"


# alias quarantine "sudo xattr -rd com.apple.quarantine"
# alias vlc_wav "duti -s org.videolan.vlc com.microsoft.waveform-audio all"
# alias vlc_mp3 "duti -s org.videolan.vlc public.mp3 all"


zoxide init fish | source
