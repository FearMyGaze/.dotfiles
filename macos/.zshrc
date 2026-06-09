# Homebrew zsh plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Options
setopt auto_cd
setopt extended_glob
setopt correct
setopt interactivecomments

# Greeting
print -P "%F{red}Be careful%f"
print -P "This machine has no brain use your own"

# Aliases
alias ls="lsd"
alias ll="lsd -ll"
alias la="lsd -a"
alias lt="lsd --tree"
alias zs="zoxide query -l"
alias cat="bat"

#OS commands
alias cls="clear"
alias del="rm -rf"
alias '??'=pwd
alias ..="cd .."
alias ...="cd ../.."
alias '....'="cd ../../.."
alias ver="which"
alias man="tldr"

alias buc='echo "Upgrading and cleaning packages with Brew" && brew upgrade && brew cleanup --prune=all'

#Git commands
alias lg="lazygit"
alias gf="git fetch"
alias gm="git merge"
alias gs="git status"
alias gd="gh dash"
alias gpu="git push"
alias gpl="git pull"
alias hunk="hunk diff --mode split"
alias api="posting"

#Emacs config
alias emacs="emacs -nw"
alias ds="doom sync"
alias du="doom upgrade"
alias dc="zed ~/.config/doom"

#Rands
alias n="yazi"
alias adbc="adb connect"

#Opencode
uwu() {
    opencode "$PWD"
}

#Shell config
alias sz="source ~/.zshrc"
alias zz="zed /Users/giorgos/Documents/Github/.dotfiles/macos/"

#Mac stuff
alias defaultKeyRepeat='defaults write -g InitialKeyRepeat -int 12 && defaults write -g KeyRepeat -int 1 && print -P "%F{red}Settings applied%f"'
alias showHiddenFiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias quarantine='sudo xattr -rd com.apple.quarantine'
alias vlc_wav='duti -s org.videolan.vlc com.microsoft.waveform-audio all'
alias vlc_mp3='duti -s org.videolan.vlc public.mp3 all'

# Init tools
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v fzf >/dev/null && eval "$(fzf --zsh)"

# Functions
function mdir {
  mkdir -p "$@" && cd "$@"
}

function downloadVideo {
  yt-dlp -f 'bv*+ba/b' "$@"
}

function downloadVideos {
  yt-dlp -f 'bv*+ba/b' -a "$@"
}

function downloadPlaylist {
  yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(playlist_index)03d - %(title)s.%(ext)s" --yes-playlist "$@"
}

function downloadPlaylistFrom {
  yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(playlist_index)03d - %(title)s.%(ext)s" --yes-playlist --playlist-start "$@"
}

function downloadSong {
  yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s" "$@"
}

function downloadSongs {
  yt-dlp -x --audio-format mp3 --audio-quality 0 -a "$@"
}

function mp4_to_mp3 {
  for file in *.mp4 *.mkv *.avi *.webm *.flv(N); do
    ffmpeg -i "$file" -vn -ab 192k "${file:r}.mp3"
  done
}

function mov_to_mp4 {
  if [[ $# -eq 0 ]]; then
    echo "Usage: mov_to_mp4 <file.mov>"
    return 1
  fi
  for file in "$@"; do
    if [[ -f "$file" ]]; then
      ffmpeg -i "$file" -vcodec libx264 -acodec aac "${file:r}.mp4"
    else
      echo "File not found: $file"
    fi
  done
}

function webm_to_mp4 {
  if [[ $# -eq 0 ]]; then
    echo "Usage: webm_to_mp4 <file.webm>"
    return 1
  fi
  for file in "$@"; do
    if [[ -f "$file" ]]; then
      ffmpeg -i "$file" -c:v libx264 -pix_fmt yuv420p -c:a aac "${file:r}.mp4"
    else
      echo "File not found: $file"
    fi
  done
}

function vcompress {
  local input="$1"
  if [[ -z "$input" ]]; then
    echo "Usage: vcompress input_file.mp4 [bitrate]"
    return 1
  fi
  local bitrate="${2:-2000k}"
  local output="${input:r}_compressed.mp4"
  ffmpeg -i "$input" -vcodec h264_videotoolbox -b:v "$bitrate" "$output"
}
