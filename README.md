# xbox_capture_save
* Xboxではキャプチャした動画や静止画をOneDriveに保存できる
* しかしOneDriveは5GBしかないのですぐに溜まって消すのが面倒
* WindowsではOneDriveと同期する設定がありWindows側の通常のファイル操作でOneDriveからファイルをコピーしたり消すことができる
* そこで同期したOneDriveからWindows側の通常のディレクトリに移動することでOneDriveのファイルを消す
* さらにXにアップロードしたいのでついでに自動で140秒未満のファイルに分割する
* この操作にはおそらくWindowsだけで完結できるが、慣れているためWSLを使用する前提とした

## 概要
* One Driveに転送されたXboxの動画ファイルを別のディレクトリに移動する
  * 移動した動画ファイルをX向けに分割する
* One Driveに転送されたXboxの静止画ファイルを別のディレクトリに移動する
* 古いファイルを削除する

## 事前準備
* Windows上のWSLで動作するが書き換えればWSLでなくても動くと思う
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

find "${onedirvedir}" -name "*.mp4" -print0 | xargs -0 -I {} sh -c '
  src="{}"
  namewithext="${src#"'"${onedirvedir}"'"}"
  echo $namewithext
  name=${namewithext%.mp4}
  mv "$src" "'"${workdir}"'"
  ffmpeg \
    -i "'"${workdir}"'${namewithext}" \
    -c copy \
    -f segment \
    -flags +global_header \
    -segment_format_options movflags=+faststart \
    -reset_timestamps 1 \
    -segment_time 137 \
    "'"${forxdir}${name}_%02d.mp4"'"
'

# スクリーンショットを移動
find "${windowshomedir}OneDrive/Pictures/Xbox Screenshots/" -name "*.*" -print0 | xargs -0 -I {} \
  mv "{}" ${windowshomedir}Videos/xbox/

# 古いファイルを削除
find ${windowshomedir}Videos/xbox/ -mtime +3 -type f -exec rm {} \;
```
## 参考にしたサイト
* [ffmpegでフォルダ内の動画を一括変換する \#Mac \- Qiita](https://qiita.com/hosota9/items/29f845854db2e4eeebc0)
* [ffmpeg:指定時間毎にファイルを自動分割 \[Design Workshop\]](https://ws.tetsuakibaba.jp/doku.php?id=ffmpeg:%E6%8C%87%E5%AE%9A%E6%99%82%E9%96%93%E6%AF%8E%E3%81%AB%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%82%92%E8%87%AA%E5%8B%95%E5%88%86%E5%89%B2)
* [とほほのBash入門 \- とほほのWWW入門](https://www.tohoho-web.com/ex/shell.html#shell-script)
