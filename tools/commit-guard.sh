#!/usr/bin/env bash
# 커밋 직전 차단 검사 (pre-commit / commit-msg hook에서 부른다)
#
# 사용법
#   tools/commit-guard.sh staged          스테이지된 내용(git add 한 그대로)을 검사한다
#   tools/commit-guard.sh message <파일>  커밋 메시지를 검사한다
#   종료 코드: 0 통과, 1 차단
#   환경 변수: PRIVACY_NAMES_FILE (기본값 .private/names.txt), PRIVACY_ROSTER_FILE (기본값 .private/roster.yaml)
#
# staged 검사 항목
#   1. 브랜치: main/master에서는 커밋하지 않는다
#   2. 금지 경로: notes/, .private/, _workspace/, .env, 원본 영상·음성, 압축 파일, 빌드 산출물 (git add -f로 넣은 것도 잡는다)
#   3. 실명: 금지어 파일·명단의 실명이 스테이지된 텍스트 파일 어디에든 있으면 차단 (확장자 무관)
#   4. 비밀 정보: API 키, 토큰, 개인 키, 접속 문자열
#   5. 미디어: tools/privacy-check.sh로 GPS·크기·오디오 검사, 그리고 사진 속 소유자·일련번호 메타데이터
#
# 일치한 실명이나 비밀 값은 절대 출력하지 않는다. 파일과 줄 번호만 알려 준다.
# macOS 기본 bash 3.2에서도 돌아가게 작성했다.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

NAMES_FILE="${PRIVACY_NAMES_FILE:-.private/names.txt}"
ROSTER_FILE="${PRIVACY_ROSTER_FILE:-.private/roster.yaml}"

FAIL_COUNT=0
TMP="$(mktemp -d "${TMPDIR:-/tmp}/commit-guard.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

fail() {
  # $1: 위치, $2: 이유, $3: 해결 방법
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '🚫 %s\n   이유: %s\n   해결: %s\n' "$1" "$2" "$3"
}

# 금지어 목록: names.txt + roster.yaml의 real 값. 주석·빈 줄 제외. 한 줄에 하나.
build_words() {
  : > "$TMP/words"
  if [ -f "$NAMES_FILE" ]; then
    awk '{ sub(/\r$/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); if ($0 != "" && substr($0, 1, 1) != "#") print }' \
      "$NAMES_FILE" >> "$TMP/words"
  fi
  if [ -f "$ROSTER_FILE" ]; then
    sed -n 's/^[[:space:]-]*real:[[:space:]]*//p' "$ROSTER_FILE" | sed 's/[[:space:]]*#.*$//; s/[[:space:]]*$//' \
      | grep -v '^$' >> "$TMP/words" || true
  fi
  sort -u -o "$TMP/words" "$TMP/words"
  [ -s "$TMP/words" ]
}

# 비밀 정보 패턴 (확장 정규식)
SECRET_PATTERNS='AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{40,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-(proj-)?[A-Za-z0-9]{32,}|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|(postgres|postgresql|mysql|mongodb(\+srv)?|redis|amqp)://[^[:space:]:/@]+:[^[:space:]@]+@|(api[_-]?key|secret|token|passwd|password)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'[:space:]]{12,}["'"'"']'

check_message() {
  msg="$1"
  # 주석 줄(#)은 git이 지우므로 빼고 본다.
  grep -v '^#' "$msg" > "$TMP/msg" || true
  if build_words; then
    while IFS= read -r word; do
      if grep -qiF -e "$word" "$TMP/msg"; then
        fail "커밋 메시지" "금지어(실명 등)가 들어 있음" "메시지에서 실명·학교·동네를 지우고 다시 커밋하기"
        break
      fi
    done < "$TMP/words"
  fi
  if grep -qE -e "$SECRET_PATTERNS" "$TMP/msg"; then
    fail "커밋 메시지" "비밀 정보(키·토큰)로 보이는 값이 있음" "메시지에서 지우고, 노출된 키는 폐기·재발급하기"
  fi
}

check_staged() {
  # ── 1. 브랜치 ──
  branch="$(git symbolic-ref --short -q HEAD || true)"
  case "$branch" in
    main | master)
      fail "브랜치 $branch" "main/master에 직접 커밋할 수 없음" "git switch -c <작업 브랜치> 로 브랜치를 만든 뒤 커밋하기"
      ;;
  esac

  git diff --cached --name-only -z --diff-filter=ACMR > "$TMP/files"
  [ -s "$TMP/files" ] || return 0

  mkdir -p "$TMP/staged"
  while IFS= read -r -d '' f; do
    # ── 2. 금지 경로 ──
    lower="$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')"
    case "$lower" in
      notes/* | */notes/*)
        fail "$f" "수업 메모·원본(notes/)은 커밋하지 않음" "git restore --staged \"$f\"" ;;
      .private/* | */.private/* | *roster.yaml | *names.txt)
        case "$lower" in
          .private.example/*) ;; # 가짜 예시는 허용
          *) fail "$f" "실명 목록·명단은 커밋하지 않음" "git restore --staged \"$f\"" ;;
        esac ;;
      _workspace/* | */_workspace/*)
        fail "$f" "humanize-korean 중간 산출물은 커밋하지 않음" "git restore --staged \"$f\"" ;;
      .env | .env.* | */.env | */.env.*)
        case "$lower" in
          *.example) ;;
          *) fail "$f" "환경 변수 파일(비밀 정보)은 커밋하지 않음" "git restore --staged \"$f\"" ;;
        esac ;;
      *.mov | *.mkv | *.avi | *.m4a | *.wav | *.mp3 | *.aac | *.heic | *.zip | *.7z | *.tar | *.tgz | *.gz)
        fail "$f" "원본 영상·음성·사진(HEIC)이나 압축 파일은 커밋하지 않음" \
          "git restore --staged \"$f\" 후 영상은 tools/clip.sh, 사진은 jpg로 바꾸고 tools/strip-metadata.sh" ;;
      public/* | resources/_gen/*)
        fail "$f" "빌드 산출물은 커밋하지 않음" "git restore --staged \"$f\"" ;;
    esac

    # 스테이지된 내용 그대로 꺼낸다. (작업본이 아니라 커밋될 내용을 검사한다)
    mkdir -p "$TMP/staged/$(dirname "$f")"
    git show ":$f" > "$TMP/staged/$f"
  done < "$TMP/files"

  # 텍스트 파일 목록 (git이 바이너리로 보지 않는 파일)
  : > "$TMP/text-files"
  while IFS= read -r -d '' f; do
    if git diff --cached --numstat -- "$f" | grep -qv '^-'; then
      printf '%s\n' "$f" >> "$TMP/text-files"
    fi
  done < "$TMP/files"

  # ── 3. 실명 ──
  if build_words; then
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      lines=""
      while IFS= read -r word; do
        hit="$(grep -niF -e "$word" -- "$TMP/staged/$f" 2>/dev/null | cut -d: -f1 | tr '\n' ' ' || true)"
        lines="$lines$hit"
      done < "$TMP/words"
      for ln in $(printf '%s\n' $lines | sort -n -u); do
        fail "$f:$ln" "금지어(실명·학교·동네 등)와 일치" \
          "글에서는 .private/roster.yaml의 가명으로 바꾸기. 문서·코드라면 해당 단어 지우기"
      done
    done < "$TMP/text-files"
  else
    printf 'ℹ️  금지어 파일(%s)과 명단(%s)이 없어 실명 검사를 건너뜁니다.\n' "$NAMES_FILE" "$ROSTER_FILE"
  fi

  # ── 4. 비밀 정보 (이번에 추가되는 줄만) ──
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    git diff --cached -U0 -- "$f" | awk '
      /^@@/ { split($3, a, ","); ln = substr(a[1], 2) + 0; next }
      /^\+\+\+/ { next }
      /^\+/ { print ln "\t" substr($0, 2); ln++ }
    ' > "$TMP/added"
    hit="$(grep -E -e "$SECRET_PATTERNS" "$TMP/added" | cut -f1 | tr '\n' ' ' || true)"
    for ln in $hit; do
      fail "$f:$ln" "비밀 정보(API 키·토큰·개인 키·접속 문자열)로 보이는 값" \
        "값을 지우고 환경 변수·AWS Secrets Manager·1Password로 옮기기. 이미 노출됐다면 키를 폐기·재발급하기"
    done
  done < "$TMP/text-files"

  # ── 5. 미디어 ──
  : > "$TMP/media"
  while IFS= read -r -d '' f; do
    case "$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')" in
      *.jpg | *.jpeg | *.png | *.webp | *.gif | *.mp4 | *.webm) printf '%s\n' "$f" >> "$TMP/media" ;;
    esac
  done < "$TMP/files"
  if [ -s "$TMP/media" ]; then
    # GPS·크기·오디오 (스테이지된 사본을 검사하고, 출력의 임시 경로를 원래 경로로 바꾼다)
    if ! PRIVACY_NAMES_FILE=/dev/null tools/privacy-check.sh "$TMP/staged" > "$TMP/pc-out" 2>&1; then
      sed "s#$TMP/staged/##g" "$TMP/pc-out" | grep -v '^ℹ️' || true
      FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    # 사진 속 소유자 이름·기기 일련번호
    if command -v exiftool > /dev/null 2>&1; then
      while IFS= read -r f; do
        case "$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')" in
          *.jpg | *.jpeg | *.png | *.webp)
            meta="$(exiftool -q -q -s -OwnerName -CameraOwnerName -Artist -SerialNumber -InternalSerialNumber \
              -BodySerialNumber -LensSerialNumber "$TMP/staged/$f" 2>/dev/null || true)"
            if [ -n "$meta" ]; then
              fail "$f" "사진에 소유자 이름이나 기기 일련번호 메타데이터가 남아 있음" \
                "tools/strip-metadata.sh \"$(dirname "$f")\" 실행 후 다시 git add"
            fi
            ;;
        esac
      done < "$TMP/media"
    fi
  fi
}

case "${1:-}" in
  staged) check_staged ;;
  message)
    [ -n "${2:-}" ] || { echo "사용법: tools/commit-guard.sh message <파일>" >&2; exit 2; }
    check_message "$2" ;;
  *)
    echo "사용법: tools/commit-guard.sh staged | message <파일>" >&2
    exit 2 ;;
esac

if [ "$FAIL_COUNT" -gt 0 ]; then
  printf '\n커밋 차단: %d건. 위 항목을 고친 뒤 다시 커밋하세요.\n' "$FAIL_COUNT"
  printf '이미 커밋하거나 push한 개인정보·비밀 정보가 있다면 추가 커밋으로 덮지 말고 작업을 멈추고 사람에게 알리세요.\n'
  exit 1
fi
exit 0
