#!/usr/bin/env bash
# 기록 글(index.md)의 본문만 /humanize-korean에 넘기고, 윤문 결과를 다시 붙인다.
# front matter는 건드리지 않고, 보호 항목(shortcode·이미지·제목)이 바뀌면 붙이지 않는다.
#
# 사용법:
#   tools/humanize-body.sh extract <index.md> <run 폴더>
#       front matter를 뺀 본문을 <run 폴더>/01_input.txt로 저장한다. (스킬의 run 폴더: _workspace/YYYY-MM-DD-NNN-TAG)
#   tools/humanize-body.sh apply <index.md> <final.md>
#       final.md의 본문(끝의 <!-- HUMANIZE-SUMMARY ... --> 블록은 버림)을 index.md의 front matter 뒤에 붙인다.
#       붙이기 전에 shortcode({{< ... >}}), 이미지(![...](...)), 제목(#으로 시작하는 줄)이
#       윤문 전과 한 글자도 다르지 않은지 확인하고, 다르면 index.md를 고치지 않고 종료 코드 1로 끝낸다.
#       붙인 뒤 본문에 HTML 주석(<!--)이 남으면 경고한다.
set -euo pipefail

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 1
}

[ "$#" -eq 3 ] || usage
cmd="$1"; post="$2"; arg="$3"
[ -f "$post" ] || { echo "❌ 글 파일이 없습니다: $post" >&2; exit 1; }

case "$cmd" in
  extract)
    mkdir -p "$arg"
    python3 - "$post" "$arg/01_input.txt" <<'PY'
import sys
src, out = sys.argv[1], sys.argv[2]
s = open(src, encoding="utf-8").read()
parts = s.split("---\n", 2)
if len(parts) < 3 or parts[0] != "":
    sys.exit("❌ front matter(---)를 찾지 못했습니다: " + src)
open(out, "w", encoding="utf-8").write(parts[2].lstrip("\n"))
print("본문을 저장했습니다:", out)
PY
    ;;
  apply)
    [ -f "$arg" ] || { echo "❌ 윤문 결과가 없습니다: $arg" >&2; exit 1; }
    python3 - "$post" "$arg" <<'PY'
import re, sys
post, final = sys.argv[1], sys.argv[2]
s = open(post, encoding="utf-8").read()
parts = s.split("---\n", 2)
if len(parts) < 3 or parts[0] != "":
    sys.exit("❌ front matter(---)를 찾지 못했습니다: " + post)
front, old_body = "---\n" + parts[1] + "---\n", parts[2]
new_body = open(final, encoding="utf-8").read()
new_body = re.split(r"<!--\s*HUMANIZE-SUMMARY", new_body)[0].rstrip() + "\n"

def protected(body):
    items = re.findall(r"\{\{<.*?>\}\}", body, re.S)
    items += re.findall(r"!\[[^\]]*\]\([^)]*\)", body)
    items += [l for l in body.splitlines() if l.startswith("#")]
    return items

a, b = protected(old_body), protected(new_body)
if a != b:
    print("❌ 보호 항목이 바뀌어 붙이지 않았습니다. (shortcode·이미지·제목)", file=sys.stderr)
    for x in a:
        if x not in b: print("  - 사라짐:", x[:100], file=sys.stderr)
    for x in b:
        if x not in a: print("  + 새로 생김:", x[:100], file=sys.stderr)
    if len(a) == len(b) and set(a) == set(b):
        print("  (순서가 바뀜)", file=sys.stderr)
    sys.exit(1)

open(post, "w", encoding="utf-8").write(front + "\n" + new_body)
print("본문을 붙였습니다:", post)
if "<!--" in new_body:
    print("⚠️ 본문에 HTML 주석(<!--)이 남아 있습니다. 확인해서 지우세요.", file=sys.stderr)
PY
    ;;
  *)
    usage
    ;;
esac
