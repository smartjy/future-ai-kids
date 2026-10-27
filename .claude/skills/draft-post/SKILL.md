---
name: draft-post
description: 수업 메모(notes/YYYY-MM-DD/)로 그 주 기록 글 초안(index.md, draft true)과 네이버 요약본(naver.md)을 쓰고, 윤문·사실 검증·내용 검토까지 마친 뒤 사람에게 보여 준다. 커밋·push·PR은 하지 않는다. 「초안 써 줘」, 「이번 주 글 초안」, 「글 다시 써 줘」, /draft-post에 사용한다.
argument-hint: "[수업 날짜 YYYY-MM-DD]"
allowed-tools: Read, Grep, Glob, Edit, Write, Skill, Agent, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(hugo:*), Bash(ls:*), Bash(./tools/privacy-check.sh:*)
---

# /draft-post — 기록 글 초안 쓰기

수업 메모로 한 주 기록 글 초안을 만들고, 사람이 읽어 볼 수 있는 상태까지 다듬는다.
브랜치를 만들거나 커밋·push·PR을 하지 않는다. 그 일은 `/weekly-post`가 한다. (`/weekly-post` 4~9단계를 이 스킬로 대신할 수 있다)
시작하기 전에 `CLAUDE.md`를 읽고 그 규칙을 따른다. 이 레포는 퍼블릭이다.

인자: `$ARGUMENTS` (수업 날짜 `YYYY-MM-DD`. 비어 있으면 `notes/`에서 가장 최근 날짜 폴더를 제안하고 확인받는다)

## 1. 준비

- **브랜치**: 지금 브랜치가 `main`이면 멈추고 사람에게 알린다. (`/weekly-post` 2단계로 `post/<팀 별칭 소문자>-week-NN` 브랜치를 먼저 만든다)
- **메모**: `notes/YYYY-MM-DD/`에 `class.md`(공통)와 팀 파일 `<team-id>.md`가 있는지 본다. 메모가 없으면 멈춘다.
- **참여 팀**: 팀 파일 이름을 `data/teams.yaml`의 `id`와 맞춰 참여 팀을 정하고 사람에게 확인받는다. (예: 「team1(Doumy)만 참여, team2는 쉼」) `teams.yaml`에 없는 파일이 있으면 묻는다.
- **명단**: `.private/roster.yaml`이 있는지 본다. 없으면 멈춘다. 내용은 출력하지 않는다.
- **빈 칸**: 메모의 `[[ ]]` 칸 수를 세어 알려 준다. 많으면 「채우고 진행할지, 빈 채로 진행할지」를 묻는다.
- **학생들 이야기**: 팀 메모에 학생별 이야기(누가 무엇을 했는지, 한 말, 있었던 일)가 있는지 본다. 없으면 「이대로 쓰면 학생들 이야기가 빠진 글이 된다」고 분명히 말하고, 채울지 묻는다. 채팅으로 받은 내용은 메모 파일에 먼저 적는다.
- **글 폴더**: `content/posts/YYYY-MM-DD-week-NN/`. 주차는 팀별로 센다. `NN`은 `content/posts/*/index.md` 중 front matter `teams`에 그 팀이 들어간 글 수에 1을 더한 두 자리 번호다. (예: Doumy가 두 번 수업했으면 Doumy의 다음 글은 `03`) 한 글에 들어갈 팀들의 주차가 서로 다르면 멈추고 사람에게 묻는다. 같은 날짜 폴더가 이미 있으면 그 폴더를 다시 쓸지 묻는다. 없으면 만든다.
  ```sh
  hugo new content posts/YYYY-MM-DD-week-NN
  ```

## 2. 초안 — `post-writer`

> 네이버 블로그는 지금 중단 상태다. 작업은 `본문`으로만 맡기고 `naver.md`는 다루지 않는다.

`Agent` 도구로 `post-writer`를 부른다. 작업은 `둘 다`(index.md + naver.md).

- 넘길 것: 수업 날짜, 주차, 글 폴더, 참여 팀 `id`, 메모 경로, 글 폴더에 있는 미디어 파일, 사람이 이번에 따로 말한 요청
- 실명 목록을 프롬프트에 넣지 않는다. (에이전트가 `.private/`를 직접 읽는다)
- 보고서의 「확인이 필요한 점」은 모아 두었다가 7단계에서 사람에게 보여 준다.

## 3. 윤문 — `/humanize-korean`

`Skill` 도구로 `humanize-korean`을 실행해 `index.md` 본문과 `naver.md`를 윤문한다.

- 바꾸지 않는 것: front matter, shortcode, 이미지·영상 경로, 링크, 팀 별칭, 가명 호칭, 해요체 문체, 제목(`##`) 구조, `naver.md` 마지막 링크 줄
- 윤문 전 내용과 비교해 위 항목이 깨졌으면 그 부분을 되돌린다.
- 윤문은 문체(register)를 보존한다. 문체를 바꾸고 싶으면 윤문이 아니라 초안(2단계)에서 바꾼다.
- `_workspace/`는 커밋하지 않는다.

## 4. 사실 검증 — `fact-checker`

`Agent` 도구로 `fact-checker`를 부른다. 넘길 것: 글 폴더 경로, 메모 경로, 원본 미디어 경로(`notes/YYYY-MM-DD/media/`)

- **수정 필요**면 보고된 문장을 근거가 허용하는 범위로 줄이거나 뺀다. 직접 고친다. (문장을 새로 지어 넣지 않는다)
- 사실인데 메모에 없는 내용이면 고치지 말고 7단계에서 사람에게 묻는다. 확인받으면 메모에 먼저 적고 다시 검증받는다.
- 고친 뒤 다시 검증받는다. 두 번 고쳐도 통과하지 않으면 남은 항목을 사람에게 보여 주고 판단을 받는다.

## 5. 내용 검토 — `content-reviewer`

`Agent` 도구로 `content-reviewer`를 부른다. 넘길 것: 글 폴더 경로, 메모 경로, 단계 `초안`

- 필수 수정은 고친다. 권장 수정은 7단계에서 사람에게 보여 준다.
- 메모가 비어서 빠진 섹션(학생들의 한마디, 숙제, 다음 주 예고)이나 사람이 빼라고 한 섹션에 대한 지적은 「메모 없음/사람 결정으로 뺌」으로 넘긴다.
- 문장을 많이 고쳤으면 4단계 사실 검증을 다시 거친다.

## 6. 자동 검사

```sh
./tools/privacy-check.sh content/posts/YYYY-MM-DD-week-NN
hugo --gc --minify --printPathWarnings --buildDrafts --destination "$(mktemp -d)"
```

실패하면 고치고 다시 돌린다. GPS·크기·오디오 실패는 고치지 말고 사람에게 알린다.

## 7. 사람에게 보여 주기

다음을 한 번에 보여 준다. 실명은 쓰지 않는다.

- **파일 위치**: `content/posts/YYYY-MM-DD-week-NN/index.md`(본문), `naver.md`(네이버 요약본), 쓴 미디어 파일
- **본문**: 섹션별 내용. 짧으면 전문, 길면 섹션마다 두세 줄 요약
- **naver.md 전문**
- **검증 결과**: fact-checker(판정 개수, 고친 문장 전·후), content-reviewer(고친 것, 남은 권장 수정), privacy-check, 빌드
- **사람이 정할 것**: 메모의 빈 칸, 메모에 없지만 사실일 수 있는 내용, 문체·섹션 선택 같은 결정
- **홈 화면**: 이 글이 홈의 주차별 기록판에서 어떻게 보이는지(주제 = 첫 `##` 제목, `made`, `summary`, 대표 사진)도 함께 확인한다.
- **미리 보기**: `hugo server --buildDrafts` → `http://localhost:1313/future-ai-kids/posts/YYYY-MM-DD-week-NN/`
- **다음 단계**: 사진·영상 추가(`/weekly-post` 6단계), `privacy-reviewer`, 커밋·PR(`/weekly-post` 10~11단계)

사람이 고칠 점을 말하면 같은 흐름으로 반영한다. 고친 범위에 따라 2단계(다시 쓰기) 또는 바로 수정 → 3~6단계를 다시 거친다.

## 멈춰야 할 때

- `main` 브랜치에 있을 때
- 메모, `.private/roster.yaml`, `post-writer`, `fact-checker`, `content-reviewer`가 없거나 실행되지 않을 때 (검증을 건너뛰지 않는다)
- 메모에 명단에 없는 학생 이름이 나올 때 (가명을 짓지 않고 사람에게 받는다)
- 개인정보가 이미 커밋되거나 push된 것을 발견했을 때. 추가 커밋으로 덮지 않고 즉시 사람에게 알린다.
