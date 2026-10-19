# future-ai-kids — Claude Code 작업 규칙

초등학생 연구원들과 매주 진행하는 AI 수업(미래AI육성 캠프) 기록 블로그다. 전체 계획은 `PLAN.md`를 따른다.

## 이 레포는 퍼블릭이다
- 레포에 올라간 것은 전부 공개된다. 초안, PR 본문, 커밋 메시지, 히스토리, 지운 파일까지 포함한다.
- 수업 메모(`notes/`), 원본 영상, 실명 목록(`.private/`)은 **커밋하지 않는다.** 둘 다 `.gitignore` 대상이다.
- 아이들 실명, 학교명, 반, 동네 이름은 글, PR, 커밋 메시지 어디에도 쓰지 않는다.
- 개인정보가 커밋된 것을 발견하면 추가 커밋으로 덮지 않는다. 즉시 작업을 멈추고 사람에게 보고한다. (히스토리 정리가 필요하다)
- `main`에 직접 push하거나 force push하지 않는다. 모든 변경은 브랜치와 PR로 한다.

## 글쓰기 규칙
- 아이들 눈높이의 따뜻하고 담백한 톤으로 쓴다. 과장하지 않는다.
- `archetypes/posts.md` 구조를 유지한다: 이번 주 주제 → 오늘의 수업 흐름 → 팀별 섹션 → 다음 주 예고
- 한 주에 글 하나, 그 주에 참여한 팀을 모두 한 글에 담는다. 쉰 팀은 섹션과 front matter `teams`에서 뺀다.
- 팀 이름은 `data/teams.yaml`의 별칭(`name`)만 쓴다.
- 아이 호칭은 「<팀 별칭> 연구원 A/B/C」로 쓴다. 메모에 실명이 있으면 이렇게 바꾸고, 바꾼 사실은 PR 설명에만 남긴다. (실명 자체는 PR에도 쓰지 않는다)
- 새 글은 `hugo new content posts/YYYY-MM-DD-week-NN/index.md`로 만들고 `draft: true`로 시작한다.

## 문체 다듬기 (humanize-korean)
- 초안 작성 직후, 그리고 `draft: false`로 바꾸기 직전에 `/humanize-korean`을 실행해 AI 티를 없앤다. 네이버 요약본도 같다.
- front matter, shortcode, 이미지 경로, 링크, 팀 별칭, 「연구원 A」 호칭은 바꾸지 않는다. 윤문 뒤 `git diff`로 확인하고 깨졌으면 되돌린다.
- 스킬이 만드는 `_workspace/`는 커밋하지 않는다.

## 빌드 확인
- `hugo --gc --minify --printPathWarnings`가 경고 없이 끝나야 한다.
- 초안 확인: `hugo server --buildDrafts`
