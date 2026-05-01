#######################################
## Path Variables
#######################################

set -l path_dirs $HOME/.config/emacs/bin
test -d $HOME/.cargo/bin; and set path_dirs $path_dirs $HOME/.cargo/bin
test -d /opt/homebrew/opt/openjdk/bin; and set path_dirs $path_dirs /opt/homebrew/opt/openjdk/bin
test -d $HOME/go/bin; and set path_dirs $path_dirs $HOME/go/bin
test -d /opt/homebrew/opt/node@20/bin; and set path_dirs $path_dirs /opt/homebrew/opt/node@20/bin
test -d /opt/homebrew/bin; and set path_dirs $path_dirs /opt/homebrew/bin
test -d /opt/homebrew/sbin; and set path_dirs $path_dirs /opt/homebrew/sbin
test -d $HOME/.local/bin; and set path_dirs $path_dirs $HOME/.local/bin
test -d $HOME/.orbstack/bin; and set path_dirs $path_dirs $HOME/.orbstack/bin
test -d $BUN_INSTALL/bin; and set path_dirs $path_dirs $BUN_INSTALL/bin
test -d $HOME/Library/Android/sdk/platform-tools; and set path_dirs $path_dirs $HOME/Library/Android/sdk/platform-tools
set -x PATH $path_dirs $PATH

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

# Editors
set -x EDITOR "zed"
set -x VISUAL "zed"

#LS commands
alias ls="lsd"
alias ll="lsd -ll"
alias la="lsd -a"
alias lt="lsd --tree"
alias zs="zi" #Zoxide show listings

#OS commands
alias cls="clear"
alias del="rm -rf"
alias ??="pwd"
alias ..="cd .."
alias ...="cd ../.."
alias ...="cd ../../.."
alias ver="which"

alias buc="echo Upgrading and cleaning packages with Brew && brew upgrade && brew cleanup --prune=all"

#Git commands
alias lg="lazygit"
alias gf="git fetch"
alias gm="git merge"
alias gs="git status"
alias gd="gh dash"
alias gpu="git push"
alias gpl="git pull"

#Doom commands
alias emacs="emacs -nw"
alias ds="doom sync"
alias dc="zed ~/.config/doom"

#Random commands
alias n="yazi"
alias adbc="adb connect"
alias sz="source ~/.config/fish/config.fish"
alias zz="zed /Users/giorgos/Documents/Github/.dotfiles/macos/.config"
alias defaultKeyRepeat="defaults write -g InitialKeyRepeat -int 12 && defaults write -g KeyRepeat -int 1 && echo (set_color red)'Settings applied' "
alias showHiddenFiles="defaults write com.apple.finder AppleShowAllFiles YES && killall Finder"
alias quarantine="sudo xattr -rd com.apple.quarantine"
alias vlc_wav="duti -s org.videolan.vlc com.microsoft.waveform-audio all"
alias vlc_mp3="duti -s org.videolan.vlc public.mp3 all"

#Initilization of stuff
zoxide init fish | source
starship init fish | source
fzf --fish | source

#Functions
function mdir --description 'Create directory and cd into it'
    mkdir -p $argv; and cd $argv
end

function downloadVideo
    yt-dlp -f 'bv*+ba/b' $argv
end

function downloadVideos
    yt-dlp -f 'bv*+ba/b' -a $argv
end

function downloadPlaylist
    yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(playlist_index)03d - %(title)s.%(ext)s" --yes-playlist $argv
end

function downloadPlaylistFrom
    yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(playlist_index)03d - %(title)s.%(ext)s" --yes-playlist --playlist-start $argv
end

function downloadSong
    yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s" $argv
end

function downloadSongs
    yt-dlp -x --audio-format mp3 --audio-quality 0 -a $argv
end

function mp4_to_mp3
    for file in *.mp4 *.mkv *.avi *.webm *.flv
        ffmpeg -i "$file" -vn -ab 192k (string replace -r '\.[^.]*$' '.mp3' -- "$file")
    end
end

function mov_to_mp4
    if test (count $argv) -eq 0
        echo "Usage: mov_to_mp4 <file.mov>"
        return 1
    end

    for file in $argv
        if test -f $file
            set base (basename $file .mov)
            ffmpeg -i $file -vcodec libx264 -acodec aac "$base.mp4"
        else
            echo "File not found: $file"
        end
    end
end


function webm_to_mp4
    if test (count $argv) -eq 0
        echo "Usage: webm_to_mp4 <file.webm>"
        return 1
    end

    for file in $argv
        if test -f $file
            set base (basename $file .webm)
            ffmpeg -i $file \
                -c:v libx264 -pix_fmt yuv420p \
                -c:a aac \
                "$base.mp4"
        else
            echo "File not found: $file"
        end
    end
end

function vcompress --argument input
    if test -z "$input"
        echo "Usage: vcompress input_file.mp4 [bitrate]"
        return 1
    end

    # Set bitrate to 2000k if the second argument is missing
    set -l bitrate $argv[2]
    if test -z "$bitrate"
        set bitrate "2000k"
    end

    # Generate output filename (filename_compressed.mp4)
    set -l output (string replace -r '\.[^.]+$' '_compressed.mp4' $input)

    ffmpeg -i $input -vcodec h264_videotoolbox -b:v $bitrate $output
end
