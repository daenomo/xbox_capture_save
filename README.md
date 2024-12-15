# xbox_capture_save
* One Driveに転送されたXboxの動画ファイルを別のディレクトリに移動する
  * 移動した動画ファイルをX向けに分割する
* One Driveに転送されたXboxの静止画ファイルを別のディレクトリに移動する
* 古いファイルを削除する

## 事前準備
* ffmpegをインストールする
* windowshomedirのnameを書き換える
* workdirを作成する
  
```
#!/usr/bin/bash

# 動画ファイルの移動とファイル分割
windowshomedir="/mnt/c/Users/name/"
onedirvedir="${windowshomedir}OneDrive/動画/Xbox Game DVR/"
workdir="${windowshomedir}Videos/xbox/"
forxdir="${workdir}/tmp/"
for src in "${onedirvedir}"*.mp4 # ディレクトリ名にスペースが入ってるため " でくくる
do 
  namewithext=${src#${onedirvedir}}
  name=${namewithext%.mp4}
  mv "${src}" $workdir
  ffmpeg \
    -i "${workdir}${namewithext}" \
    -c copy \
    -f segment \
    -flags +global_header \
    -segment_format_options movflags=+faststart \
    -reset_timestamps 1 \
    -segment_time 137 \
    "${forxdir}${name}_%02d.mp4"
done

# スクリーンショットを移動
mv "${windowshomedir}OneDrive/Pictures/Xbox Screenshots/"*.* ${windowshomedir}Videos/xbox/
# 古いファイルを削除
find ${windowshomedir}Videos/xbox/ -mtime +3 -type f -exec rm {} \;
```
