#!/usr/bin/env bash
# 개인정보 자동 검사 (로컬 pre-commit, CI 공용)
#
# 사용법: tools/privacy-check.sh [경로 ...]
#   경로는 레포 루트 기준이다. 경로를 주지 않으면 content/ 를 검사한다. 금지어 검사는 data/ 도 항상 함께 본다.
#   종료 코드: 0 통과, 1 실패
#   환경 변수: PRIVACY_NAMES_FILE (기본값 .private/names.txt)
#
# 검사 항목
#   1. 금지어: 금지어 파일의 단어가 글(md/html/yaml/yml/txt)에 들어 있으면 실패
#      (금지어 파일은 로컬 전용이라 CI에서는 건너뛴다. 일치한 단어는 절대 출력하지 않는다)
#   2. GPS: jpg/jpeg/png/heic/webp에 GPS 정보가 남아 있으면 실패
#   3. 크기: 이미지 2MB, mp4/webm 3MB, gif 3MB 초과 시 실패
#   4. 오디오: mp4/webm에 오디오 트랙이 있으면 실패
#
# macOS 기본 bash 3.2에서도 돌아가게 작성했다. (mapfile, 연관 배열 사용 안 함)
set -euo pipefail

# 레포 루트에서 실행한다.
cd "$(dirname "$0")/.."

NAMES_FILE="${PRIVACY_NAMES_FILE:-.private/names.txt}"
IMAGE_LIMIT=$((2 * 1024 * 1024))
VIDEO_LIMIT=$((3 * 1024 * 1024))
GIF_LIMIT=$((3 * 1024 * 1024))

if [ "$#" -gt 0 ]; then
  PATHS=("$@")
else
  PATHS=("content")
fi

FAIL_COUNT=0
TMPDIR_CHECK="$(mktemp -d "${TMPDIR:-/tmp}/privacy-check.XXXXXX")"
trap 'rm -rf "$TMPDIR_CHECK"' EXIT

fail() {
  # $1: 파일, $2: 이유, $3: 해결 방법
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '❌ %s\n   이유: %s\n   해결: %s\n' "$1" "$2" "$3"
}

# 존재하는 경로만 남긴다.
EXISTING=()
for p in "${PATHS[@]}"; do
  if [ -e "$p" ]; then
    EXISTING+=("$p")
  else
    printf 'ℹ️  %s 경로가 없어 건너뜁니다.\n' "$p"
  fi
done

# 금지어 검사 대상 경로: 지정한 경로 + data/
TEXT_PATHS=()
if [ "${#EXISTING[@]}" -gt 0 ]; then
  TEXT_PATHS=("${EXISTING[@]}")
fi
HAS_DATA=0
for p in "${EXISTING[@]+"${EXISTING[@]}"}"; do
  case "${p%/}" in
    data | ./data) HAS_DATA=1 ;;
  esac
done
if [ "$HAS_DATA" -eq 0 ] && [ -d data ]; then
  TEXT_PATHS+=("data")
fi

# ── 1. 금지어 ──
if [ ! -f "$NAMES_FILE" ]; then
  printf 'ℹ️  금지어 파일(%s)이 없어 금지어 검사를 건너뜁니다. (CI에서는 정상)\n' "$NAMES_FILE"
  printf '   로컬에서는 README의 「개인정보」 절차대로 금지어 파일을 만들어 주세요.\n'
elif [ "${#TEXT_PATHS[@]}" -gt 0 ]; then
  WORDS_FILE="$TMPDIR_CHECK/words"
  # 주석(#)과 빈 줄을 빼고, 앞뒤 공백과 CR을 지운다. 원래 줄 번호를 같이 남긴다.
  awk '{ sub(/\r$/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); if ($0 != "" && substr($0, 1, 1) != "#") print NR "\t" $0 }' \
    "$NAMES_FILE" > "$WORDS_FILE"

  TEXT_FILES="$TMPDIR_CHECK/text-files"
  find "${TEXT_PATHS[@]}" -type f \( -iname '*.md' -o -iname '*.markdown' -o -iname '*.html' \
    -o -iname '*.htm' -o -iname '*.yaml' -o -iname '*.yml' -o -iname '*.txt' \) -print0 > "$TEXT_FILES"

  while IFS="$(printf '\t')" read -r word_line word; do
    [ -n "$word" ] || continue
    while IFS= read -r -d '' f; do
      # 줄 번호만 뽑는다. 일치한 줄 내용(=금지어)은 출력하지 않는다.
      lines="$(grep -niF -e "$word" -- "$f" 2>/dev/null | cut -d: -f1 | tr '\n' ' ' || true)"
      for ln in $lines; do
        fail "$f:$ln" "금지어 파일 ${word_line}번째 줄과 일치" \
          "해당 줄의 실명·학교·동네를 지우거나 「팀 별칭 + 연구원 A/B/C」로 바꿔 쓰기"
      done
    done < "$TEXT_FILES"
  done < "$WORDS_FILE"
fi

# ── 2~4. 이미지·영상 ──
MEDIA_FILES="$TMPDIR_CHECK/media-files"
if [ "${#EXISTING[@]}" -gt 0 ]; then
  find "${EXISTING[@]}" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.heic' \
    -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.mp4' -o -iname '*.webm' \) -print0 > "$MEDIA_FILES"
else
  : > "$MEDIA_FILES"
fi

if [ -s "$MEDIA_FILES" ]; then
  MISSING=0
  if ! command -v exiftool > /dev/null 2>&1; then
    printf '❌ exiftool이 없습니다. 설치: brew install exiftool  (Ubuntu: sudo apt-get install -y libimage-exiftool-perl)\n'
    MISSING=1
  fi
  if ! command -v ffprobe > /dev/null 2>&1; then
    printf '❌ ffprobe가 없습니다. 설치: brew install ffmpeg  (Ubuntu: sudo apt-get install -y ffmpeg)\n'
    MISSING=1
  fi
  if [ "$MISSING" -ne 0 ]; then
    printf '\n개인정보 검사를 끝까지 할 수 없어 실패로 처리합니다.\n'
    exit 1
  fi

  while IFS= read -r -d '' f; do
    size="$(wc -c < "$f" | tr -d ' ')"
    dir="$(dirname "$f")"
    ext="$(printf '%s' "${f##*.}" | tr '[:upper:]' '[:lower:]')"
    case "$ext" in
      jpg | jpeg | png | heic | webp)
        gps="$(exiftool -q -q -n -s -GPS:all -GPSLatitude -GPSLongitude -GPSPosition "$f" 2>/dev/null || true)"
        if [ -n "$gps" ]; then
          fail "$f" "사진에 GPS(위치) 정보가 남아 있음" "tools/strip-metadata.sh \"$dir\" 실행"
        fi
        if [ "$size" -gt "$IMAGE_LIMIT" ]; then
          fail "$f" "이미지가 2MB를 넘음 ($((size / 1024))KB)" \
            "가로 1600px 이하로 줄이거나 JPG 품질을 낮춰 다시 저장 (예: sips -Z 1600 \"$f\")"
        fi
        ;;
      gif)
        if [ "$size" -gt "$GIF_LIMIT" ]; then
          fail "$f" "GIF가 3MB를 넘음 ($((size / 1024))KB)" \
            "tools/clip.sh로 더 짧게 다시 변환하거나 mp4로 바꾸기"
        fi
        ;;
      mp4 | webm)
        if [ "$size" -gt "$VIDEO_LIMIT" ]; then
          fail "$f" "영상이 3MB를 넘음 ($((size / 1024))KB)" \
            "tools/clip.sh로 더 짧게 다시 변환"
        fi
        if ! audio="$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$f" 2>/dev/null)"; then
          fail "$f" "영상을 읽을 수 없음 (파일이 깨졌을 수 있음)" "tools/clip.sh로 다시 변환"
        elif [ -n "$audio" ]; then
          fail "$f" "영상에 오디오(소리) 트랙이 있음 — 아이들 목소리가 공개될 수 있음" \
            "tools/clip.sh로 다시 변환 (오디오 제거)"
        fi
        ;;
    esac
  done < "$MEDIA_FILES"
fi

echo
if [ "$FAIL_COUNT" -gt 0 ]; then
  printf '개인정보 검사 실패: %d건. 위 항목을 고친 뒤 다시 실행하세요. (tools/privacy-check.sh)\n' "$FAIL_COUNT"
  exit 1
fi
printf '✅ 개인정보 검사 통과\n'
exit 0
