#!/usr/bin/env bash
# 글 폴더 사진의 메타데이터(GPS, 촬영 기기, 시각 등)를 모두 지운다.
#
# 사용법: tools/strip-metadata.sh <폴더>
#   폴더 안(하위 폴더 포함)의 jpg/jpeg/png/heic/webp에 exiftool -all= -overwrite_original을 실행한다.
#   사진이 돌아가 보이지 않도록 방향(Orientation) 값만 다시 넣는다. (개인정보 아님)
#   원본은 남기지 않으므로, 필요한 원본은 레포 밖에 따로 보관한다.
set -euo pipefail

if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
  echo "사용법: tools/strip-metadata.sh <폴더>" >&2
  echo "예: tools/strip-metadata.sh content/posts/2026-10-24-week-02" >&2
  exit 1
fi

if ! command -v exiftool > /dev/null 2>&1; then
  echo "❌ exiftool이 없습니다. 설치: brew install exiftool  (Ubuntu: sudo apt-get install -y libimage-exiftool-perl)" >&2
  exit 1
fi

DIR="$1"
count=0
failed=0

while IFS= read -r -d '' f; do
  if exiftool -q -q -all= -tagsFromFile @ -Orientation -overwrite_original "$f" > /dev/null 2>&1; then
    count=$((count + 1))
    printf '✔ %s\n' "$f"
  else
    failed=$((failed + 1))
    printf '❌ %s — 메타데이터를 지우지 못했습니다. 다른 프로그램으로 JPG로 다시 저장한 뒤 재실행하세요.\n' "$f"
  fi
done < <(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
  -o -iname '*.heic' -o -iname '*.webp' \) -print0)

echo
if [ "$count" -eq 0 ] && [ "$failed" -eq 0 ]; then
  printf 'ℹ️  %s 안에 사진이 없습니다.\n' "$DIR"
else
  printf '메타데이터 제거: %d개 완료, %d개 실패\n' "$count" "$failed"
fi
echo "확인: tools/privacy-check.sh \"$DIR\""

[ "$failed" -eq 0 ]
