package main

import (
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"

	ffmpeg_go "github.com/u2takey/ffmpeg-go"
)

func main() {
	windowshomedir := os.Getenv("HOME") + "/"
	onedirvedir := filepath.Join(windowshomedir, "OneDrive/動画/Xbox Game DVR/")
	workdir := filepath.Join(windowshomedir, "Videos/xbox/")
	forxdir := filepath.Join(workdir, "tmp/")
	forbsdir := filepath.Join(workdir, "tmp/")

	for {
		time.Sleep(1 * time.Second)

		// 動画を移動してエンコードする
		filepath.Walk(onedirvedir, func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if strings.HasSuffix(info.Name(), ".mp4") {
				namewithext := strings.TrimPrefix(path, onedirvedir)
				name := strings.TrimSuffix(namewithext, ".mp4")

				// OneDriveの同期が遅いとmvに失敗するためエラー出力抑制
				newpath := filepath.Join(workdir, namewithext)
				os.Rename(path, newpath)
				if _, err := os.Stat(newpath); os.IsNotExist(err) {
					return nil
				}

				// Bluesky用
				err = ffmpeg_go.Input(newpath).
					Filter("scale", ffmpeg_go.Args{"-1:720"}).
					Output(filepath.Join(forbsdir, name+"_bs_%02d.mp4"),
						ffmpeg_go.KwArgs{
							"c:v":                    "h264_amf",
							"maxrate":                "7000k",
							"c:a":                    "copy",
							"b":                      "7000k",
							"f":                      "segment",
							"flags":                  "+global_header",
							"segment_format_options": "movflags=+faststart",
							"reset_timestamps":       "1",
							"segment_time":           "55",
						}).
					OverWriteOutput().
					Run()

				if err != nil {
					log.Printf("Error processing video: %v", err)
				}

				// 元の動画も残しておく
				os.Rename(newpath, filepath.Join(forxdir, namewithext))
			}
			return nil
		})

		// スクリーンショットを移動
		filepath.Walk(filepath.Join(windowshomedir, "OneDrive/Pictures/Xbox Screenshots/"), func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if !info.IsDir() {
				newpath := filepath.Join(workdir, info.Name())
				os.Rename(path, newpath)
			}
			return nil
		})

		// 古いファイルを削除
		filepath.Walk(workdir, func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if time.Since(info.ModTime()).Hours() > 48 {
				os.Remove(path)
			}
			return nil
		})
	}
}
