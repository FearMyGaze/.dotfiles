#
#Current Project commands
#

function Voltix
    cd ~/Documents/Github/Voltix
end

function voltix
    Voltix
end

function DayChat
    cd ~/Documents/Github/DayChat
end

function dayChat
    DayChat
end

#
#LS commands
#

function ls
    lsd
end

function ll
    lsd -l
end

function la
    lsd -a
end

function lt
    lsd --tree
end

#
# OS Commands
#

function cls
    clear
end

function n
    yazi
end

function ??
    pwd
end

function del
    rm -rf "$argv"
end

function ver
    which
end

function ..
    cd ..
end

function ...
    cd ../..
end

function mdir
    mkdir -p $argv && cd $argv
end

function buc
    echo "Upgrading and cleaning packages with Brew" && brew upgrade && brew cleanup --prune=all
end

#
# Editor Commands
#

function emacs
    command emacs -nw "$argv"
end

function e
    emacs
end

function vim
    emacs
end

function nvim
    emacs
end

function ds
    doom sync
end

function doomConf
    zed ~/.config/doom
end

#
# Git Commands
#

function lg
    lazygit
end

function gf
    git fetch
end

function gp
    git push
end

function gc
    git checkout
end

function gm
    git merge
end

function gs
    git status
end

#
# Zoxide commands
#

alias l='zi'
alias zz='z -'
alias b='z ..'

#
# Config Commands
#

function zz
    zed ~/.config
end

function sz
    source ~/.config/fish/config.fish
    source ~/.config/fish/conf.d/aliases.fish
end

function ghosttyConf
    zed ~/.config/ghostty/config
end

function ghosttyVal
    ghostty +validate-config
end

#
# Random Commands
#

function adbc
    adb connect
end

#
#Download with yt-dlp
#

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

#Convert video files

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
