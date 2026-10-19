#!/usr/bin/env bash
# 수업 영상에서 쓸 장면만 잘라 글 폴더에 mp4/gif/jpg를 만든다.
# 원본 영상은 레포 밖 또는 notes/(gitignore)에만 둔다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MP4_WIDTH=720
GIF_WIDTH=480
GIF_FPS=12
MP4_CRF_START=28
MP4_CRF_MAX=34
MP4_CRF_STEP=2
MAX_BYTES=$((2 * 1024 * 1024))
BLUR_RADIUS=20

usage() {
  cat <<'EOF'
사용법:
  ./tools/clip.sh <원본> <시작 mm:ss> <길이(초)> <글 폴더> [이름] [옵션...]

  <원본>       원본 영상 파일 (레포 밖 또는 notes/ 안에 둔다)
  <시작>       자를 시작 시각. mm:ss 또는 h:mm:ss (예: 01:23, 0:05.5)
  <길이(초)>   자를 길이(초). 예: 4, 6.5
  <글 폴더>    결과물을 넣을 글 폴더 (예: content/posts/2026-10-24-week-02)
  [이름]       결과 파일 이름 (영문 소문자·숫자·-·_). 생략하면 원본 파일 이름으로 만든다.

옵션 (위치 인자 뒤 어디에나 둘 수 있다):
  --crop W:H:X:Y   원본에서 (X,Y)부터 가로 W, 세로 H 영역만 남긴다.
  --blur W:H:X:Y   (X,Y)부터 가로 W, 세로 H 사각형을 흐리게 한다. 여러 번 지정할 수 있다.
                   좌표는 --crop을 적용한 "뒤"의 화면 기준이다. (crop 영역의 왼쪽 위가 0:0)
  --preview        결과물을 만들지 않고, 시작 시점 한 프레임만 레포 밖 임시 폴더에 jpg로 저장한다.
                   crop/blur를 적용한 모습과 원본 크기를 보여 주므로 좌표를 잡을 때 쓴다.
  -h, --help       이 도움말

결과물 (글 폴더 안):
  <이름>.mp4   가로 720px, H.264, 소리 없음, faststart, 목표 2MB 이하
  <이름>.gif   가로 480px, 12fps (4초 이하 짧은 장면용)
  <이름>.jpg   첫 프레임 포스터 (메타데이터 제거)

필터 순서: crop → blur → 크기 조절. mp4, gif, jpg 모두 같은 필터를 쓴다.

예:
  ./tools/clip.sh "notes/1주차 수업.mp4" 01:05 6 content/posts/2026-10-24-week-02 app-demo
  ./tools/clip.sh ~/Movies/rec.mp4 0:10 4 content/posts/2026-10-24-week-02 quiz --preview --crop 1280:600:0:120
  ./tools/clip.sh ~/Movies/rec.mp4 0:10 4 content/posts/2026-10-24-week-02 quiz --crop 1280:600:0:120 --blur 200:200:40:20 --blur 160:60:900:500
EOF
}

die() {
  echo "오류: $*" >&2
  echo "도움말: ./tools/clip.sh --help" >&2
  exit 1
}

warn() {
  echo "경고: $*" >&2
}

# 파일 크기(byte). macOS/Linux 공통.
file_size() {
  wc -c <"$1" | tr -d ' '
}

human_size() {
  awk -v b="$1" 'BEGIN { if (b >= 1048576) printf "%.2fMB", b/1048576; else printf "%.0fKB", b/1024 }'
}

is_region() {
  echo "$1" | grep -Eq '^[0-9]+:[0-9]+:[0-9]+:[0-9]+$'
}

# ── 인자 해석 ──
POSITIONAL=()
CROP=""
BLURS=()
PREVIEW=0

while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    --crop)
      [ $# -ge 2 ] || die "--crop 뒤에 W:H:X:Y 값을 주세요."
      [ -z "$CROP" ] || die "--crop은 한 번만 쓸 수 있습니다."
      is_region "$2" || die "--crop 값 형식이 틀렸습니다: '$2' (W:H:X:Y, 숫자만)"
      CROP="$2"
      shift 2
      ;;
    --crop=*)
      [ -z "$CROP" ] || die "--crop은 한 번만 쓸 수 있습니다."
      CROP="${1#--crop=}"
      is_region "$CROP" || die "--crop 값 형식이 틀렸습니다: '$CROP' (W:H:X:Y, 숫자만)"
      shift
      ;;
    --blur)
      [ $# -ge 2 ] || die "--blur 뒤에 W:H:X:Y 값을 주세요."
      is_region "$2" || die "--blur 값 형식이 틀렸습니다: '$2' (W:H:X:Y, 숫자만)"
      BLURS+=("$2")
      shift 2
      ;;
    --blur=*)
      v="${1#--blur=}"
      is_region "$v" || die "--blur 값 형식이 틀렸습니다: '$v' (W:H:X:Y, 숫자만)"
      BLURS+=("$v")
      shift
      ;;
    --preview)
      PREVIEW=1
      shift
      ;;
    --)
      shift
      while [ $# -gt 0 ]; do
        POSITIONAL+=("$1")
        shift
      done
      ;;
    -*)
      die "알 수 없는 옵션입니다: $1"
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

NPOS=${#POSITIONAL[@]}
if [ "$NPOS" -lt 4 ] || [ "$NPOS" -gt 5 ]; then
  usage >&2
  echo >&2
  die "위치 인자는 4개 또는 5개여야 합니다. (지금 ${NPOS}개)"
fi

SRC="${POSITIONAL[0]}"
START="${POSITIONAL[1]}"
DURATION="${POSITIONAL[2]}"
POST_DIR="${POSITIONAL[3]}"
NAME=""
if [ "$NPOS" -eq 5 ]; then
  NAME="${POSITIONAL[4]}"
fi

# ── 입력 검사 ──
command -v ffmpeg >/dev/null 2>&1 || die "ffmpeg가 없습니다. 'brew install ffmpeg'로 설치하세요."
command -v ffprobe >/dev/null 2>&1 || die "ffprobe가 없습니다. 'brew install ffmpeg'로 설치하세요."

[ -f "$SRC" ] || die "원본 파일이 없습니다: $SRC"

echo "$START" | grep -Eq '^([0-9]+:)?[0-9]+:[0-5][0-9](\.[0-9]+)?$' ||
  die "시작 시각 형식이 틀렸습니다: '$START' (mm:ss 또는 h:mm:ss, 예: 01:23)"

echo "$DURATION" | grep -Eq '^([0-9]+(\.[0-9]*)?|\.[0-9]+)$' ||
  die "길이는 초 단위 숫자여야 합니다: '$DURATION' (예: 4, 6.5)"
awk -v d="$DURATION" 'BEGIN { exit !(d > 0) }' || die "길이는 0보다 커야 합니다: $DURATION"

if [ "$PREVIEW" -eq 0 ]; then
  [ -d "$POST_DIR" ] || die "글 폴더가 없습니다: $POST_DIR (먼저 README의 「새 글 쓰기」대로 hugo new content로 만드세요)"
fi

# 이름: 생략하면 원본 파일 이름을 소문자 슬러그로 바꾼다. (한글·공백 등은 '-'로)
slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' |
    LC_ALL=C sed -e 's/[^a-z0-9_-]/-/g' -e 's/--*/-/g' -e 's/^[-_]*//' -e 's/[-_]*$//'
}

if [ -z "$NAME" ]; then
  base="$(basename "$SRC")"
  base="${base%.*}"
  NAME="$(slugify "$base")"
  if [ -z "$NAME" ]; then
    NAME="clip"
    warn "원본 파일 이름으로 영문 이름을 만들 수 없어 'clip'을 씁니다. 다섯 번째 인자로 이름을 주세요."
  fi
else
  printf '%s' "$NAME" | LC_ALL=C grep -Eq '^[a-z0-9][a-z0-9_-]*$' ||
    die "이름은 영문 소문자·숫자·-·_만 쓸 수 있습니다: '$NAME' (예: app-demo)"
fi

# 원본이 레포 안에 있는데 notes/ 밖이면 커밋될 위험이 있다.
SRC_ABS="$(cd "$(dirname "$SRC")" && pwd)/$(basename "$SRC")"
case "$SRC_ABS" in
  "$REPO_ROOT"/notes/*) ;;
  "$REPO_ROOT"/*)
    warn "원본 영상이 레포 안(notes/ 밖)에 있습니다: $SRC"
    warn "원본은 커밋하면 안 됩니다. notes/ 또는 레포 밖으로 옮기세요."
    ;;
esac

# ── 원본 크기 (회전 메타데이터 반영) ──
probe() {
  ffprobe -v error -select_streams v:0 -show_entries "$1" -of default=noprint_wrappers=1:nokey=1 "$SRC" 2>/dev/null | head -n 1
}
SRC_W="$(probe stream=width)"
SRC_H="$(probe stream=height)"
[ -n "$SRC_W" ] && [ -n "$SRC_H" ] || die "영상 스트림을 읽을 수 없습니다: $SRC"
ROT="$(probe stream_side_data=rotation)"
[ -n "$ROT" ] || ROT="$(probe stream_tags=rotate)"
case "${ROT:-0}" in
  90 | -90 | 270 | -270)
    t="$SRC_W"
    SRC_W="$SRC_H"
    SRC_H="$t"
    ;;
esac

# ── 영역 검사 ──
region_part() { # region index(1~4)
  echo "$1" | cut -d: -f"$2"
}

FRAME_W="$SRC_W"
FRAME_H="$SRC_H"
if [ -n "$CROP" ]; then
  cw="$(region_part "$CROP" 1)"
  ch="$(region_part "$CROP" 2)"
  cx="$(region_part "$CROP" 3)"
  cy="$(region_part "$CROP" 4)"
  [ "$cw" -gt 0 ] && [ "$ch" -gt 0 ] || die "--crop 가로·세로는 0보다 커야 합니다: $CROP"
  if [ $((cx + cw)) -gt "$SRC_W" ] || [ $((cy + ch)) -gt "$SRC_H" ]; then
    die "--crop 영역($CROP)이 원본 화면(${SRC_W}x${SRC_H}) 밖으로 나갑니다."
  fi
  FRAME_W="$cw"
  FRAME_H="$ch"
fi

for b in ${BLURS[@]+"${BLURS[@]}"}; do
  bw="$(region_part "$b" 1)"
  bh="$(region_part "$b" 2)"
  bx="$(region_part "$b" 3)"
  by="$(region_part "$b" 4)"
  [ "$bw" -ge 2 ] && [ "$bh" -ge 2 ] || die "--blur 가로·세로는 2 이상이어야 합니다: $b"
  if [ $((bx + bw)) -gt "$FRAME_W" ] || [ $((by + bh)) -gt "$FRAME_H" ]; then
    die "--blur 영역($b)이 화면(${FRAME_W}x${FRAME_H}, crop 적용 후 기준) 밖으로 나갑니다."
  fi
done

# ── 필터 만들기: crop → blur(s) → (scale은 출력별로) ──
# 결과는 [base] 라벨로 끝나는 filtergraph 조각.
build_base_filter() {
  local cur="0:v" g="" i=0 b bw bh bx by
  if [ -n "$CROP" ]; then
    g="[${cur}]crop=${CROP}[c0]"
    cur="c0"
  fi
  for b in ${BLURS[@]+"${BLURS[@]}"}; do
    i=$((i + 1))
    bw="$(region_part "$b" 1)"
    bh="$(region_part "$b" 2)"
    bx="$(region_part "$b" 3)"
    by="$(region_part "$b" 4)"
    [ -z "$g" ] || g="${g};"
    # 작은 영역에서도 boxblur가 실패하지 않도록 반경을 영역 크기에 맞춰 줄인다.
    g="${g}[${cur}]split[m${i}][s${i}];[s${i}]crop=${bw}:${bh}:${bx}:${by},boxblur=luma_radius='max(0,min(${BLUR_RADIUS},floor(min(w,h)/2)-1))':chroma_radius='max(0,min(${BLUR_RADIUS},floor(min(cw,ch)/2)-1))':luma_power=2[b${i}];[m${i}][b${i}]overlay=${bx}:${by}[o${i}]"
    cur="o${i}"
  done
  [ -z "$g" ] || g="${g};"
  g="${g}[${cur}]null[base]"
  printf '%s' "$g"
}
BASE_FILTER="$(build_base_filter)"

if [ -n "$CROP" ] || [ ${#BLURS[@]} -gt 0 ]; then
  echo "주의: 고정 영역만 가려집니다. 움직이는 얼굴은 가려지지 않으니 결과를 끝까지 확인하세요" >&2
fi

FF=(ffmpeg -hide_banner -loglevel error -nostdin -y)
TMP_BASE="${TMPDIR:-/tmp}"
TMP_BASE="${TMP_BASE%/}"

# ── 미리보기 ──
if [ "$PREVIEW" -eq 1 ]; then
  PREVIEW_DIR="$(mktemp -d "${TMP_BASE}/clip-preview.XXXXXX")"
  PREVIEW_JPG="$PREVIEW_DIR/${NAME}-preview.jpg"
  "${FF[@]}" -ss "$START" -i "$SRC" -filter_complex "${BASE_FILTER}" -map "[base]" \
    -frames:v 1 -q:v 2 -map_metadata -1 "$PREVIEW_JPG"
  echo "원본 크기: ${SRC_W}x${SRC_H}"
  if [ -n "$CROP" ]; then
    echo "crop 후 크기: ${FRAME_W}x${FRAME_H} (--blur 좌표는 이 크기 기준)"
  fi
  echo "미리보기 프레임: $PREVIEW_JPG"
  echo "(글 폴더에는 아무것도 만들지 않았습니다. 확인 뒤 임시 폴더는 지워도 됩니다: rm -r \"$PREVIEW_DIR\")"
  exit 0
fi

WORK_DIR="$(mktemp -d "${TMP_BASE}/clip-work.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

OUT_MP4="$POST_DIR/$NAME.mp4"
OUT_GIF="$POST_DIR/$NAME.gif"
OUT_JPG="$POST_DIR/$NAME.jpg"
for f in "$OUT_MP4" "$OUT_GIF" "$OUT_JPG"; do
  [ ! -e "$f" ] || warn "기존 파일을 덮어씁니다: $f"
done

IN=(-ss "$START" -t "$DURATION" -i "$SRC")

# ── 1. mp4 ──
echo "mp4 만드는 중..."
crf=$MP4_CRF_START
while :; do
  "${FF[@]}" "${IN[@]}" \
    -filter_complex "${BASE_FILTER};[base]scale=${MP4_WIDTH}:-2[v]" -map "[v]" \
    -an -sn -dn -map_metadata -1 -map_chapters -1 \
    -c:v libx264 -preset slow -crf "$crf" -pix_fmt yuv420p -movflags +faststart \
    "$WORK_DIR/out.mp4"
  size="$(file_size "$WORK_DIR/out.mp4")"
  if [ "$size" -le "$MAX_BYTES" ] || [ "$crf" -ge "$MP4_CRF_MAX" ]; then
    break
  fi
  echo "  crf ${crf}: $(human_size "$size") > 2MB, 화질을 낮춰 다시 만듭니다."
  crf=$((crf + MP4_CRF_STEP))
done
mv "$WORK_DIR/out.mp4" "$OUT_MP4"
if [ "$size" -gt "$MAX_BYTES" ]; then
  warn "$OUT_MP4 이(가) $(human_size "$size")로 2MB를 넘습니다. 길이를 줄이거나 --crop으로 영역을 줄이세요."
fi

# ── 2. gif (2-pass) ──
echo "gif 만드는 중..."
GIF_SCALE="fps=${GIF_FPS},scale=${GIF_WIDTH}:-2:flags=lanczos"
"${FF[@]}" "${IN[@]}" \
  -filter_complex "${BASE_FILTER};[base]${GIF_SCALE},palettegen=stats_mode=diff[p]" -map "[p]" \
  -frames:v 1 -update 1 "$WORK_DIR/palette.png"
"${FF[@]}" "${IN[@]}" -i "$WORK_DIR/palette.png" \
  -filter_complex "${BASE_FILTER};[base]${GIF_SCALE}[g];[g][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle[v]" \
  -map "[v]" -map_metadata -1 -loop 0 "$WORK_DIR/out.gif"
mv "$WORK_DIR/out.gif" "$OUT_GIF"
gif_size="$(file_size "$OUT_GIF")"
if [ "$gif_size" -gt "$MAX_BYTES" ]; then
  warn "$OUT_GIF 이(가) $(human_size "$gif_size")입니다. gif는 4초 이하 짧은 장면에만 쓰고, 아니면 mp4를 쓰세요."
fi

# ── 3. jpg 포스터 (첫 프레임) ──
echo "포스터 jpg 만드는 중..."
"${FF[@]}" -ss "$START" -i "$SRC" \
  -filter_complex "${BASE_FILTER};[base]scale=${MP4_WIDTH}:-2[v]" -map "[v]" \
  -frames:v 1 -q:v 3 -map_metadata -1 "$WORK_DIR/out.jpg"
if command -v exiftool >/dev/null 2>&1; then
  exiftool -q -q -all= -overwrite_original "$WORK_DIR/out.jpg" >/dev/null || warn "exiftool로 메타데이터를 지우지 못했습니다."
fi
mv "$WORK_DIR/out.jpg" "$OUT_JPG"

echo
echo "완료:"
for f in "$OUT_MP4" "$OUT_GIF" "$OUT_JPG"; do
  echo "  $f ($(human_size "$(file_size "$f")"))"
done
echo "  (mp4 crf ${crf})"
if awk -v d="$DURATION" 'BEGIN { exit !(d > 4) }'; then
  echo "참고: ${DURATION}초는 4초보다 깁니다. 본문에는 mp4를 쓰고, 쓰지 않는 gif는 지우세요."
else
  echo "참고: 4초 이하 장면은 gif를 써도 됩니다. 쓰지 않는 파일은 지우세요."
fi
echo "본문 예: {{< clip src=\"$NAME.mp4\" alt=\"장면 설명\" >}}"
echo "결과물을 끝까지 재생해 얼굴·이름표·계정 이름·알림·반사가 없는지 확인하세요."

# ── 개인정보 검사 ──
PRIVACY_CHECK="$SCRIPT_DIR/privacy-check.sh"
if [ -x "$PRIVACY_CHECK" ]; then
  echo
  echo "privacy-check 실행: $POST_DIR"
  "$PRIVACY_CHECK" "$POST_DIR"
else
  echo
  echo "알림: tools/privacy-check.sh가 아직 없어 개인정보 검사를 건너뜁니다."
fi
