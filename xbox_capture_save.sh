#!/bin/bash

home="$HOME"
onedrive="$home/OneDrive/動画/Xbox Game DVR"
workdir="$home/Videos/xbox"
tmpdir="$workdir/tmp"
videodir="$home/Videos/games"
ffmpeg="ffmpeg"

while true; do
    sleep 5

    for file in "$onedrive"/*.mp4; do
        [ -e "$file" ] || continue
        name="${file##*/}"
        base="${name%.mp4}"
        
        # OneDriveの同期が遅いとmvに失敗するためエラー出力抑制
        mv "$file" "$workdir" 2> /dev/null
        if [ ! -e "$workdir/$name" ]; then
            continue
        fi
        
        $ffmpeg -nostdin -i "$workdir/$name" -vf scale=-1:720 -c:v h264_amf -maxrate 7000k \
                -c:a copy -b:v 7000k -f segment -flags +global_header \
                -segment_format_options movflags=+faststart -reset_timestamps 1 \
                -segment_time 55 "$tmpdir/${base}_bs_%02d.mp4"
        mv "$workdir/$name" "$videodir"
    done

    for file in "$home/OneDrive/Pictures/Xbox Screenshots"/*.*; do
        [ -e "$file" ] || continue
        mv "$file" "$workdir"
    done

    find "$workdir" -type f -mtime +2 -delete
done
