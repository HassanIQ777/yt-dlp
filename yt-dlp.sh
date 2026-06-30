#!/bin/bash

TARGET_DIR="$HOME/YouTube"
ARCHIVE_FILE="$TARGET_DIR/archive.txt"
mkdir -p "$TARGET_DIR"

URL=$1

echo "Choose format for: $URL"
echo "---------------------------"
echo "1) Video (Best Quality)"
echo "2) Video (720p)"
echo "3) Video (480p)"
echo "4) Video (360p)"
echo "5) Audio Only (Best MP3)"
echo "---------------------------"
read -rp "Enter choice [1-5]: " choice

# Ask yt-dlp itself what the playlist title is, BEFORE downloading
# --flat-playlist is fast (no video fetching), -q silences noise
PLAYLIST_TITLE=$(yt-dlp --flat-playlist -q --print playlist_title "$URL" 2>/dev/null | head -1)

# If empty, "NA", or literally "None" — no subfolder for you
if [[ -z "$PLAYLIST_TITLE" || "$PLAYLIST_TITLE" == "NA" || "$PLAYLIST_TITLE" == "None" ]]; then
    OUT_PATH="$TARGET_DIR/%(title)s.%(ext)s"
else
    OUT_PATH="$TARGET_DIR/$PLAYLIST_TITLE/%(title)s.%(ext)s"
fi

COMMON_FLAGS=(
    --downloader aria2c
    --downloader-args "aria2c:-x 16 -s 16 -k 1M"
    --embed-metadata
    --embed-thumbnail
    --sponsorblock-remove sponsor
    --download-archive "$ARCHIVE_FILE"
    --ignore-errors
    --sleep-subtitles 2
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

VIDEO_FLAGS=(--merge-output-format mkv --embed-subs --write-auto-subs --sub-langs "en.*,ar.*")

case $choice in
    1) yt-dlp -f "bestvideo+bestaudio/best"                            "${COMMON_FLAGS[@]}" "${VIDEO_FLAGS[@]}" -o "$OUT_PATH" "$URL" ;;
    2) yt-dlp -f "bestvideo[height<=720]+bestaudio/best[height<=720]"  "${COMMON_FLAGS[@]}" "${VIDEO_FLAGS[@]}" -o "$OUT_PATH" "$URL" ;;
    3) yt-dlp -f "bestvideo[height<=480]+bestaudio/best[height<=480]"  "${COMMON_FLAGS[@]}" "${VIDEO_FLAGS[@]}" -o "$OUT_PATH" "$URL" ;;
    4) yt-dlp -f "bestvideo[height<=360]+bestaudio/best[height<=360]"  "${COMMON_FLAGS[@]}" "${VIDEO_FLAGS[@]}" -o "$OUT_PATH" "$URL" ;;
    *) yt-dlp -x --audio-format mp3 --audio-quality 0                 "${COMMON_FLAGS[@]}"                    -o "$OUT_PATH" "$URL" ;;
esac

echo "---------------------------"
echo "Process finished! Check: $TARGET_DIR"