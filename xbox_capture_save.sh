#!/usr/bin/bash

windowshomedir="${HOME}/"
onedirvedir="${windowshomedir}OneDrive/動画/Xbox Game DVR/"
workdir="${windowshomedir}Videos/xbox/"
forxdir="${workdir}/tmp/"
forbsdir="${workdir}/tmp/"
ffmpegcmd="ffmpeg.exe"

while true; do sleep 1s

  # 動画を移動してエンコードする
  while IFS= read -r -d '' -u ${FD} file; do
    namewithext="${file#"${onedirvedir}"}"
    name=${namewithext%.mp4}

    # OneDriveの動機が遅いとmvに失敗するためエラー出力抑制
    mv "$file" "${workdir}" 2> /dev/null
    if [ ! -e "${workdir}${namewithext}" ]; then
      continue
    fi

    # Bluesky用
    ${ffmpegcmd} \
      -nostdin \
      -i "${workdir}${namewithext}" \
      -vf "scale=-1:720" -c:v h264_amf -maxrate 7000k -c:a copy -b 7000k \
      -f segment \
      -flags +global_header \
      -segment_format_options movflags=+faststart \
      -reset_timestamps 1 \
      -segment_time 55 \
      "${forbsdir}${name}_bs_%02d.mp4"
    
    # 元の動画も残しておく
    mv "${workdir}${namewithext}" "${forxdir}"

  done {FD}< <(find "${onedirvedir}" -name "*.mp4" -print0)

  # スクリーンショットを移動
  while IFS= read -r -d '' -u ${FD} file; do
    mv "$file" "${workdir}" 2> /dev/null
  done {FD}< <(find "${windowshomedir}OneDrive/Pictures/Xbox Screenshots/" -name "*.*" -print0)

  # 古いファイルを削除
  while IFS= read -r -d '' -u ${FD} file; do
    rm "$file"
  done {FD}< <(find "${workdir}" -mtime +2 -type f -print0)

done
