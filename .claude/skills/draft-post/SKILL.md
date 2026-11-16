---
name: draft-post
description: 수업 메모(notes/YYYY-MM-DD/)로 그 주 기록 글 초안(index.md, draft true)을 쓰고, 게임 영상·윤문·사실 검증·내용 검토·개인정보 검토까지 마친 뒤 사람에게 미리 보기로 보여 준다. 커밋·push·PR은 하지 않는다. /weekly-post 4단계에서 부르고, 「초안 써 줘」, 「이번 주 글 초안」, 「글 다시 써 줘」, /draft-post에도 쓴다.
argument-hint: "[수업 날짜 YYYY-MM-DD]"
allowed-tools: Read, Grep, Glob, Edit, Write, Skill, Agent, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(hugo:*), Bash(ls:*), Bash(cp:*), Bash(mkdir:*), Bash(python3:*), Bash(./tools/privacy-check.sh:*), Bash(./tools/strip-metadata.sh:*), Bash(./tools/clip.sh:*), Bash(./tools/frames.sh:*), Bash(./tools/humanize-body.sh:*)
---

# /draft-post — 기록 글 초안부터 검토까지

수업 메모로 한 주 기록 글을 쓰고, 사람이 미리 보기로 확인할 수 있는 상태까지 만든다.
글을 쓰고 검토하는 규칙은 **이 스킬이 한 곳에서** 정한다. `/weekly-post`는 브랜치·글 폴더·PR·발행 확인만 맡고 이 단계를 이 스킬에 맡긴다.
브랜치를 만들거나 커밋·push·PR을 하지 않는다. 시작하기 전에 `CLAUDE.md`를 읽고 그 규칙을 따른다. 이 레포는 퍼블릭이다.

인자: `$ARGUMENTS` (수업 날짜 `YYYY-MM-DD`. 비어 있으면 `notes/`에서 가장 최근 날짜 폴더를 제안하고 확인받는다)

## 1. 준비

- **브랜치**: 지금 브랜치가 `main`이면 멈추고 사람에게 알린다. (`/weekly-post` 2단계로 `post/<팀 별칭 소문자>-week-NN` 브랜치를 먼저 만든다)
- **메모**: `notes/YYYY-MM-DD/`의 `class.md`(공통), 팀 파일 `<team-id>.md`, 수업 정리 요약 `summary-<도구>.md`를 본다. 사람이 채팅에 붙여 넣은 정리는 먼저 메모 파일로 저장한다. (`/weekly-post` 1단계 「메모 위치」의 규칙대로: AI 앱 대화 정리는 `<team-id>.md`에 출처와 함께) 메모가 없으면 멈춘다.
- **참여 팀**: 팀 파일 이름을 `data/teams.yaml`의 `id`와 맞춰 참여 팀을 정하고 사람에게 확인받는다. `teams.yaml`에 없는 파일이 있으면 묻는다.
- **명단**: `.private/roster.yaml`이 있는지 본다. 없으면 멈춘다. 내용은 출력하지 않는다.
- **빈 칸**: 메모의 `[[ ]]` 칸 수를 세어 알려 준다. 많으면 「채우고 진행할지, 빈 채로 진행할지」를 묻는다.
- **학생들 이야기**: 팀 메모에 학생별 이야기(누가 무엇을 했는지, 한 말, 있었던 일)가 있는지 본다. 없으면 「이대로 쓰면 학생들 이야기가 빠진 글이 된다」고 분명히 말하고, 채울지 묻는다. 정리에 누가 한 일인지 모호한 문장이 있으면 수업에서 학생들이 한 일인지 묻는다. 채팅으로 받은 내용은 메모 파일에 먼저 적는다.
- **`class.md`가 없으면**: 첫 섹션 제목(그 주 주제)은 메모의 흐름으로 짓고 9단계 「사람이 정할 것」에 넣는다.
- **글 폴더**: `content/posts/YYYY-MM-DD-week-NN/`가 있는지 본다. 없으면 `/weekly-post` 3단계대로 만든다. (`hugo new content posts/YYYY-MM-DD-week-NN`, 끝에 `/index.md`를 붙이지 않는다) 주차 계산과 팀별 주차가 다를 때의 처리도 `/weekly-post` 1단계를 따른다.

## 2. 사진·영상

참여 팀마다 게임 영상을 넣는다. 사람이 그 주에 영상이 없다고 확인한 팀만 건너뛴다. 원본은 `notes/YYYY-MM-DD/media/`에만 둔다.

- **게임 영상**: 팀마다 `media/<team-id>-game.*`(mp4/webm/mov)가 있는지 직접 본다.
  - 없으면 `/record-game`으로 AI 앱의 게임을 녹화한다. 녹화도 못 하면 「<팀 별칭>의 게임 화면 녹화가 없어요. 넣어 주실 수 있나요?」라고 구체적으로 묻는다. 녹음 앱의 소리 파일은 영상이 아니다.
  - 녹화본이 있으면 `/record-game` 4~5단계대로 클립·대표 이미지를 만들고 **클립 프레임**을 뽑는다. (`./tools/frames.sh <클립.mp4> _workspace/frames/<team-id>-clip 1`)
  - 영상 설명·`alt`·사실 검증은 원본 녹화가 아니라 클립 프레임으로 한다.
- **사진**: 쓸 사진만 글 폴더에 복사하고 `./tools/strip-metadata.sh <글 폴더>`를 돌린다. 복사하기 전에 사진을 직접 열어 얼굴, 이름표, 교복·학교 로고, 화면 속 계정명·알림, 유리·모니터 반사가 없는지 본다. 있으면 쓰지 않는다.
- 영상 규칙(얼굴, 소리, 4초 이하 GIF, `--crop`)은 `CLAUDE.md` 「영상 규칙」을 따른다.

## 3. 초안 — `post-writer`

`Agent` 도구로 `post-writer`를 부른다. 작업은 `본문`(index.md). 네이버 운영을 다시 하면 `둘 다`로 맡긴다.

- 넘길 것: 수업 날짜, 주차, 글 폴더, 참여 팀 `id`, 메모 경로, 글 폴더의 미디어 파일과 **클립 프레임 폴더**·장면별 시간, 사람이 이번에 따로 말한 요청
- 게임 영상이 있으면 함께 지시한다.
  - 게임 설명(어떻게 하는 게임인지, 화면 문구)은 클립 프레임에서 확인한 것만 쓴다.
  - 세션이 수업 뒤 녹화한 영상이면 「아래 영상은 수업이 끝난 뒤 지금의 게임을 플레이해 녹화한 화면이에요.」처럼 밝힌다. 녹화한 쪽이 고른 행동(맵·무기·닉네임 등)을 수업 내용처럼 쓰지 않는다.
  - 제목(「N주차 · …」)과 `made`에는 게임 이름을 넣는다. `cover.image`는 대표 이미지 jpg, `cover.alt`는 장면을 자세히.
- 실명 목록을 프롬프트에 넣지 않는다. (에이전트가 `.private/`를 직접 읽는다) 명단에 없는 학생이 나오면 사람에게 가명을 받는다.
- 받은 뒤 글을 직접 읽고, 메모 속 실명이 남지 않았는지 `Grep`으로 확인한다. (검색어는 대화 안에서만 쓴다)
- 보고서의 「확인이 필요한 점」은 모아 두었다가 9단계에서 사람에게 보여 준다.

## 4. 윤문 — `/humanize-korean`

본문만 윤문한다. front matter는 스킬에 넘기지 않는다.

```sh
./tools/humanize-body.sh extract content/posts/YYYY-MM-DD-week-NN/index.md _workspace/<run_id>
# /humanize-korean 실행 (입력: _workspace/<run_id>/01_input.txt, 결과: final.md)
./tools/humanize-body.sh apply content/posts/YYYY-MM-DD-week-NN/index.md _workspace/<run_id>/final.md
```

- `apply`는 `HUMANIZE-SUMMARY` 주석을 버리고, shortcode·이미지·제목이 한 글자라도 바뀌면 붙이지 않고 실패한다. 실패하면 윤문 결과에서 그 부분을 원문대로 되돌린 뒤 다시 붙인다.
- 그 밖에 바꾸지 않는 것: 링크, 팀 별칭, 가명 호칭, 해요체 문체, 「」 안 게임 이름과 화면 문구, 수치. `git diff`(새 파일이면 윤문 전 `01_input.txt`와 비교)로 확인한다.
- 윤문은 문체를 보존한다. 문체를 바꾸고 싶으면 3단계 초안에서 바꾼다.
- `_workspace/`는 커밋하지 않는다.

## 5. 자동 검사

```sh
./tools/privacy-check.sh content/posts/YYYY-MM-DD-week-NN
hugo --gc --minify --printPathWarnings --buildDrafts --destination "$(mktemp -d)"
```

실패하면 고치고 다시 돌린다. GPS·크기·오디오 실패는 고치지 말고 사람에게 알린다. 고칠 때마다 다시 돌린다.

## 6. 사실 검증 — `fact-checker`

넘길 것: 글 폴더 경로, 메모 경로, 원본 미디어 경로(`notes/YYYY-MM-DD/media/`), 클립 프레임 폴더, 녹화 경위

- **수정 필요**면 보고된 문장을 근거가 허용하는 범위로 줄이거나 뺀다. 문장을 새로 지어 넣지 않는다. 영상과 순서가 다르면 문장을 고치거나 클립 구간을 다시 잡는다. (클립을 바꾸면 클립 프레임도 다시 뽑는다)
- 사실인데 메모에 없는 내용이면 고치지 말고 9단계에서 사람에게 묻는다. 확인받으면 메모에 먼저 적고 다시 검증받는다.
- 고친 뒤 다시 검증받는다. 두 번 고쳐도 통과하지 않으면 남은 항목을 사람에게 보여 주고 판단을 받는다.

## 7. 내용 검토 — `content-reviewer`

넘길 것: 글 폴더 경로, 메모 경로, 지금 `draft` 값(`true`)

- 필수 수정은 고친다. 권장 수정은 9단계에서 사람에게 보여 준다.
- 메모가 비어서 빠진 섹션(학생들의 한마디, 숙제, 다음 주 예고)이나 사람이 빼라고 한 섹션에 대한 지적은 「메모 없음/사람 결정으로 뺌」으로 넘긴다.
- 문장을 많이 고쳤으면 4단계 윤문과 6단계 사실 검증을 다시 거친다.

## 8. 개인정보 검토 — `privacy-reviewer`

넘길 것: 검토할 파일(이 브랜치에서 바뀐 파일과 아직 커밋하지 않은 글 폴더), 녹화 경위(세션이 넣은 닉네임 등). 실명 목록은 넘기지 않는다.

- **차단**이면 보고된 파일·이유대로 고치고 5단계 검사 후 다시 맡긴다. **통과**가 나올 때까지 다음 단계로 가지 않는다.
- 같은 작업 폴더에 다른 팀의 커밋하지 않은 글 폴더가 있으면 검토 범위를 이 글 폴더로 한정한다고 밝힌다.

## 9. 사람에게 미리 보기로 보여 주기

다음을 한 번에 보여 준다. 실명은 쓰지 않는다.

- **미리 보기**: `hugo server --buildDrafts` → `http://localhost:1313/future-ai-kids/posts/YYYY-MM-DD-week-NN/` (세션이 서버를 띄워도 된다)
- **파일 위치**: `index.md`와 쓴 미디어 파일
- **본문**: 섹션마다 두세 줄 요약 (짧으면 전문)
- **검증 결과**: fact-checker(고친 문장 전·후), content-reviewer(고친 것, 남은 권장 수정), privacy-reviewer, privacy-check, 빌드
- **사람이 정할 것**: `class.md`가 없어 지은 첫 섹션 제목, 메모의 빈 칸, 메모에 없지만 사실일 수 있는 내용, 영상에 보이는 녹화용 값(닉네임 등), 뺀 내용
- **홈 화면**: 홈의 팀 카드·주차별 기록판에 어떻게 보이는지(첫 `##` 제목, `made`, `summary`, 대표 사진)
- **다음 단계**: 사람이 확인하면 `/weekly-post` 5단계대로 `draft: false`로 바꿔 커밋·PR을 한 번 연다. 머지하면 바로 발행된다.

사람이 고칠 점을 말하면 고친 범위만큼 다시 거친다. 문장을 고치면 6단계, 많이 고치면 4·6·7단계, 사진·영상을 바꾸면 2·8단계.

## 멈춰야 할 때

- `main` 브랜치에 있을 때
- 메모, `.private/roster.yaml`, `post-writer`, `fact-checker`, `content-reviewer`, `privacy-reviewer`가 없거나 실행되지 않을 때 (검증을 건너뛰지 않는다)
- 메모에 명단에 없는 학생 이름이 나올 때 (가명을 짓지 않고 사람에게 받는다)
- 개인정보가 이미 커밋되거나 push된 것을 발견했을 때. 추가 커밋으로 덮지 않고 즉시 사람에게 알린다.
