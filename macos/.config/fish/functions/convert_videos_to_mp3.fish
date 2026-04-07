function convert_videos_to_mp3
    for file in *.mp4 *.mkv *.avi *.webm *.flv
        ffmpeg -i "$file" -vn -ab 192k (string replace -r '\.[^.]*$' '.mp3' -- "$file")
    end
end
