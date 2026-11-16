#!/usr/bin/env bash
# 영상에서 일정 간격으로 프레임을 뽑고, 한눈에 보는 모음 이미지(sheet.jpg)를 만든다.
# 글에 쓸 영상 설명과 사실 검증은 글 폴더에 넣은 "자른 클립"의 프레임으로 한다. (원본 녹화가 아니다)
#
# 사용법: tools/frames.sh <영상> <출력 폴더> [간격(초), 기본 1]
#   예: tools/frames.sh content/posts/2026-11-15-week-05/doumy-3d.mp4 _workspace/frames/doumy5-clip 2
#   출력: <출력 폴더>/f001.jpg ... (f001 = 0초, 이후 간격마다), <출력 폴더>/sheet.jpg (4열)
#   출력 폴더는 레포 안이면 _workspace/ 아래에 둔다. (커밋하지 않는다)
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ] || [ ! -f "$1" ]; then
  sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 1
fi
command -v ffmpeg >/dev/null 2>&1 || { echo "❌ ffmpeg가 없습니다. 설치: brew install ffmpeg" >&2; exit 1; }

SRC="$1"; OUT="$2"; STEP="${3:-1}"
case "$OUT" in
  content/*|static/*|data/*) echo "❌ 프레임을 content/·static/·data/에 만들지 않습니다. _workspace/ 아래를 쓰세요." >&2; exit 1 ;;
esac
mkdir -p "$OUT"
find "$OUT" -maxdepth 1 -name 'f[0-9][0-9][0-9].jpg' -delete
rm -f "$OUT/sheet.jpg"

ffmpeg -loglevel error -i "$SRC" -vf "fps=1/${STEP},scale=480:-2" -q:v 4 "$OUT/f%03d.jpg"
n=$(find "$OUT" -maxdepth 1 -name 'f[0-9][0-9][0-9].jpg' | wc -l | tr -d ' ')
rows=$(( (n + 3) / 4 ))
ffmpeg -loglevel error -y -i "$OUT/f%03d.jpg" -filter_complex "tile=4x${rows}" -q:v 4 "$OUT/sheet.jpg"

dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$SRC" 2>/dev/null || echo "?")
echo "프레임 ${n}장 (${STEP}초 간격, f001 = 0초), 영상 길이 ${dur}초"
echo "모음: $OUT/sheet.jpg"
