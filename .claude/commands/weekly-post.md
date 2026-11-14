---
description: 수업 메모로 이번 주 기록 글 초안을 쓰고 개인정보 검토를 거쳐 PR을 연다
argument-hint: "[수업 날짜 YYYY-MM-DD]"
allowed-tools: Read, Grep, Glob, Edit, Write, Skill, Agent, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git switch:*), Bash(git checkout:*), Bash(git fetch:*), Bash(git pull:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(hugo:*), Bash(ls:*), Bash(cp:*), Bash(mkdir:*), Bash(file:*), Bash(ffprobe:*), Bash(./tools/privacy-check.sh:*), Bash(./tools/strip-metadata.sh:*), Bash(./tools/clip.sh:*)
---

# /weekly-post — 주간 수업 기록 글쓰기

수업 메모를 바탕으로 한 주 기록 글(`draft: true`)과 네이버 요약본을 쓰고, 개인정보 검토를 거쳐 PR을 연다.
이 레포는 퍼블릭이다. 글, 커밋 메시지, PR 본문, 브랜치 이름 어디에도 학생 실명, 학교명, 반, 동네 이름을 쓰지 않는다.
시작하기 전에 `CLAUDE.md`를 읽고 그 규칙을 따른다.

인자: `$ARGUMENTS` (수업 날짜 `YYYY-MM-DD`. 비어 있으면 1단계에서 묻는다)

## 1. 수업 정보 확인

다음을 사람에게 확인한다. 추측해서 채우지 않는다.

- **수업 날짜**: `$ARGUMENTS`가 있으면 그 날짜를 쓰고, 없으면 묻는다. 형식은 `YYYY-MM-DD`.
- **참여한 팀**: `data/teams.yaml`에서 `active: true`인 팀의 `name`(별칭)과 `id`를 목록으로 보여 주고, 이번 주에 참여한 팀을 고르게 한다.
- **메모 위치**: `notes/YYYY-MM-DD/` 폴더다. 파일이 실제로 있는지 확인한다. (예시: `notes.example/2026-10-24/`)
  - `class.md`: 공통 — 강의 주제, 수업 흐름, 다음 주 예고
  - `<team-id>.md`: 팀마다 한 파일 (`team1.md` 등). 고른 참여 팀과 팀 파일 목록이 맞는지 확인하고, 다르면 묻는다.
  - `summary-<도구>.md`: 수업 녹음을 정리한 요약(회의 요약 도구 결과 등). 사람이 채팅에 붙여 넣으면 이 이름으로 `notes/YYYY-MM-DD/`에 먼저 저장한다. `class.md`·팀 파일이 없고 요약만 있으면 요약을 메모로 쓰되, 어느 팀 수업인지 사람에게 확인받아 파일 머리에 적는다.
- **미디어 위치**: 사진·영상 원본은 `notes/YYYY-MM-DD/media/`에 둔다. 파일 이름 앞에 팀 id(공통이면 `class-`)를 붙인다.
- **게임 영상**: 글에는 정리한 수업 내용과 그 주 게임 영상(게임 화면 녹화)이 함께 들어간다. 참여 팀마다 `media/`에 `<team-id>-game.*`(mp4/webm/mov) 같은 게임 화면 녹화가 있는지 직접 본다.
  - 없으면 「<팀 별칭>의 게임 화면 녹화가 `notes/YYYY-MM-DD/media/`에 없어요. 넣어 주실 수 있나요?」라고 묻는다. 「미디어가 있나요?」처럼 막연하게 묻지 않는다.
  - 사람이 그 주에 게임 영상이 정말 없다고 확인한 팀만 영상 없이 쓴다. 그 사실은 PR 본문 「사용한 미디어」에 적는다.
  - 녹음 앱의 소리 파일(`audio.mp4` 등)은 영상이 아니다. 소리는 쓰지 않으므로 글에 넣지 않는다.

주차는 팀별로 센다. `NN`은 `content/posts/*/index.md` 중 front matter `teams`에 그 팀이 들어간 글 수에 1을 더한 두 자리 번호다. (예: Doumy가 두 번 수업했으면 Doumy의 다음 글은 `03`) 한 글에 들어갈 팀들의 주차가 서로 다르면 멈추고 사람에게 묻는다. 지금까지는 팀별로 글·브랜치·PR을 나눴다. (예: 2026-11-07에 Bsil `week-01`과 Wanted `week-03`을 따로 냈다) 나누자고 하면 팀마다 2단계부터 따로 진행한다. 같은 날짜의 글 폴더가 이미 있으면 멈추고 사람에게 묻는다. 같은 날짜에 주차 번호까지 같아 폴더 이름이 겹치는 경우도 묻는다.

`notes/`와 `.private/`는 `.gitignore` 대상이다. 메모 내용을 레포의 다른 파일로 옮겨 적지 않는다.

## 2. 브랜치 만들기

```bash
git switch main
git pull --ff-only
git switch -c post/<팀 별칭 소문자>-week-NN   # 예: post/wanted-week-02
```

- 작업 트리에 커밋하지 않은 변경이 있으면 멈추고 사람에게 묻는다.
- `main`에서는 절대 커밋하지 않는다. 이후 모든 커밋은 이 브랜치에서 한다.

## 3. 글 폴더 만들기

```bash
hugo new content posts/YYYY-MM-DD-week-NN
```

- `content/posts/YYYY-MM-DD-week-NN/index.md`가 `draft: true`로 생긴다. 번들 아키타입이면 같은 폴더에 `naver.md`도 함께 생긴다.
- front matter `date`는 수업 날짜(`YYYY-MM-DDT10:00:00+09:00` 꼴)로 고친다.

## 4. 본문 쓰기 (`draft: true`) — `post-writer`

`Agent` 도구로 `post-writer` 서브 에이전트를 불러 `index.md` 초안을 맡긴다.

- 넘길 것: 수업 날짜, 주차 `NN`, 참여한 팀 `id` 목록, 메모 위치, 작업 `본문`, 글 폴더의 영상·사진 파일과 영상 프레임 위치(`_workspace/frames/` 등)
- 게임 영상이 있으면 함께 지시한다.
  - 팀 섹션의 게임 설명(어떻게 하는 게임인지, 화면에 나오는 문구)은 영상 프레임에서 확인한 것만 쓴다.
  - 세션이 수업 뒤 녹화한 영상이면 「아래 영상은 수업이 끝난 뒤 지금의 게임을 플레이해 녹화한 화면이에요.」처럼 밝힌다. 학생이 플레이한 화면처럼 쓰지 않는다. 녹화한 쪽이 고른 행동(무기 선택 등)을 수업 내용처럼 쓰지 않는다.
  - 제목(「N주차 · …」)과 `made`에는 게임 이름을 넣는다. (예: `Bsil: "게임 「등불 미로」"`)
  - `cover.image`는 영상 프레임 jpg로, `cover.alt`에는 장면을 자세히 쓴다.
- 에이전트는 메모의 실명을 `.private/roster.yaml`의 가명(「<가명>」)으로 바꾸고, 쉰 팀을 빼고, `summary`·`tags`를 채운다. 보고서에는 바꾼 종류와 개수만 온다.
- 실명과 가명의 대응은 `.private/roster.yaml`에만 둔다. 글, 주석, 커밋 메시지, PR 본문, scratchpad 등 **다른 파일에는 쓰지 않는다.** 명단에 없는 학생이 메모에 나오면 사람에게 가명을 받아 명단과 `.private/names.txt`에 넣는다.
- 보고서의 「확인이 필요한 점」(모호한 메모, 한마디가 없는 팀 등)은 사람에게 물어 정한 뒤 직접 고치거나 에이전트에 다시 맡긴다.
- 받은 뒤 글을 직접 읽고, 메모 속 실명이 남지 않았는지 `Grep`으로 한 번 더 확인한다. (검색어는 대화 안에서만 쓰고 파일로 남기지 않는다)

## 5. 문체 다듬기 (`/humanize-korean`)

`/humanize-korean` 스킬로 **본문만** 윤문해 AI 티를 없앤다.

- 바꾸지 않는 것: front matter, shortcode(`{{< clip ... >}}` 등), 이미지·영상 경로, 링크, 팀 별칭, 가명 호칭, 해요체 문체, 제목(`##`) 구조
- 윤문 뒤 `git diff`(새 파일이면 윤문 전 내용과 비교)로 위 항목이 그대로인지 확인하고, 깨졌으면 그 부분을 되돌린다.
- 스킬이 만드는 `_workspace/`는 커밋하지 않는다. (`.gitignore` 대상)

## 6. 사진·영상 넣기

참여 팀마다 게임 영상을 넣는다. 1단계에서 사람이 영상이 없다고 확인한 팀만 건너뛴다. 원본은 `notes/YYYY-MM-DD/media/`에만 두고 레포로 직접 옮기지 않는다.

- **사진**: 쓸 사진만 글 폴더에 복사한 뒤 메타데이터를 지운다.
  ```bash
  cp notes/YYYY-MM-DD/media/<사진> content/posts/YYYY-MM-DD-week-NN/<영문-이름>.jpg
  ./tools/strip-metadata.sh content/posts/YYYY-MM-DD-week-NN
  ```
  복사하기 전에 사진을 직접 열어 얼굴, 이름표, 교복·학교 로고, 화면 속 계정명·알림, 유리·모니터 반사가 없는지 본다. 있으면 쓰지 않는다.
- **게임 영상 녹화**: `media/`에 게임 화면 녹화가 없으면 세션이 직접 녹화할 수 있다. (2026-10-31, 11-01, 11-07 글이 이 방법으로 만들어졌다)
  1. 사람에게 그 주 수업 뒤 최신 게임의 AI 앱 링크(아티팩트 URL)나 HTML 파일을 받는다. 어느 버전인지(수업 끝난 시점인지) 확인한다.
  2. 로컬 사본을 `_workspace/game/<team-id>/index.html`에 둔다. 자동 조작에 게임 상태가 필요하면 사본(`bot.html`)에만 읽기용 훅(예: `window.__g`)을 더한다. 게임 로직은 바꾸지 않는다.
  3. `_workspace/rec/`의 녹화 스크립트(`rec.js` 참고, `playwright-core` — Apache-2.0, 이미 설치됨)로 headless Chrome에서 녹화한다. 외부 네트워크가 필요 없는 로컬 파일만 연다. 새 의존성은 설치하지 않는다. 15~25초 안에 게임의 핵심 흐름(시작 → 플레이 → 클리어나 결과 화면)이 보이게 한다.
  4. 녹화본을 `notes/YYYY-MM-DD/media/<team-id>-game.webm`으로 옮긴다.
  5. 팀 메모(`<team-id>.md`, 요약만 있으면 그 파일)에 녹화 경위를 적는다. 「영상: media/<team-id>-game.webm — 사람 지시로 수업 뒤 AI 앱에 있던 최신 게임을 실행해 화면 녹화」처럼 적고, 녹화한 쪽이 고른 행동(무기·경로 선택 등)은 「수업 내용 아님」으로 따로 적는다. fact-checker가 이 기록으로 영상과 수업을 구분한다.
  6. 프레임을 `_workspace/frames/`에 뽑아 직접 본다. 게임 속 얼굴이 사진인지 코드가 그린 캐릭터인지, 게임 파일에 사진이나 내장 이미지가 있는지 확인한다.
- **영상**: `tools/clip.sh`로 쓸 장면만 잘라 결과물(mp4/gif/jpg)만 글 폴더에 만든다. 소리는 항상 제거된다.
  ```bash
  # 얼굴·이름표가 나올 수 있으면 먼저 한 프레임을 보고 좌표를 잡는다
  ./tools/clip.sh notes/YYYY-MM-DD/media/<원본> <시작 mm:ss> <길이(초)> content/posts/YYYY-MM-DD-week-NN <이름> --preview
  # 필요하면 남길 영역만 자르거나 고정 영역을 흐린다
  ./tools/clip.sh notes/YYYY-MM-DD/media/<원본> <시작 mm:ss> <길이(초)> content/posts/YYYY-MM-DD-week-NN <이름> --crop W:H:X:Y --blur W:H:X:Y
  ```
  - 얼굴이 움직이며 나오는 장면은 blur로 가리지 말고 쓰지 않는다.
  - 4초 이하 장면은 GIF, 그보다 길면 MP4를 쓴다.
  - 화면 녹화는 `--crop`으로 게임 영역만 남긴다. 브라우저 UI, 계정 표시, 알림이 남지 않게 한다.
  - `clip.sh`가 만든 첫 프레임 jpg는 포스터다. 대표 이미지로 더 나은 장면이 있으면 그 프레임을 jpg로 따로 만들고(`strip-metadata.sh` 적용) `cover`에 쓴다.
- 본문에는 shortcode로 넣고, `alt`에는 장면을 설명하는 한국어 문장을 쓴다. (학생 이름 금지)
  ```
  {{< clip src="<이름>.mp4" alt="퀴즈 앱이 정답을 맞히면 점수가 올라가는 장면" >}}
  ```
- 대표 이미지가 있으면 front matter `cover.image`와 `cover.alt`를 채운다.

## 7. 자동 개인정보 검사

```bash
./tools/privacy-check.sh content/posts/YYYY-MM-DD-week-NN
```

실패하면 출력된 해결 방법대로 고치고 통과할 때까지 다시 돌린다. 윤문이나 수정 뒤에도 다시 돌린다.

## 8. 네이버 요약본 (`naver.md`)

> **지금은 중단.** CLAUDE.md에 따라 이 단계는 건너뛴다.

`post-writer`에 작업 `요약본`으로 `naver.md`를 맡긴다. (3단계에서 생기지 않았으면 에이전트가 만든다. 사이트 빌드에는 나오지 않는다)

- 제목: GitHub 글과 같다.
- 본문: 핵심 3~4줄(공통), 참여한 팀마다 「학생들의 한마디」 1개(메모에 있을 때만), 대표 이미지 1장 위치 표시(예: `[대표 이미지: <파일 이름>]`)
- 마지막 줄: `전체 기록 보기 → https://smartjy.github.io/future-ai-kids/posts/<slug>/`
- 전문을 복사하지 않는다. (유사 문서로 판단되면 네이버 노출이 줄어든다)
- 쓴 뒤 `/humanize-korean`으로 윤문하고, 5단계와 같은 방법으로 링크·호칭·별칭이 그대로인지 확인한다. 그다음 7단계 검사를 다시 돌린다.

## 9. `fact-checker`·`content-reviewer` 검토

먼저 `Agent` 도구로 `fact-checker` 서브 에이전트를 불러 글의 문장이 실제 수업과 맞는지 검증받는다. 문장마다 메모(`notes/YYYY-MM-DD/`)와 원본 사진·영상에서 근거를 찾아 「근거 있음 / 근거 없음 / 메모와 다름 / 부풀림」으로 판정한다.

- 넘길 것: 글 폴더 경로
- 결과가 **수정 필요**면 근거가 없는 문장은 빼거나 근거가 허용하는 만큼으로 줄인다. 사실이지만 메모에 없는 내용이면 사람에게 확인받아 메모에 먼저 적은 뒤 다시 검증받는다.
- 윤문(5단계)은 뜻을 바꿀 수 있으므로, 윤문 뒤에도 `fact-checker`를 거친다.

그다음 `content-reviewer` 서브 에이전트를 불러 커밋 전 글 내용을 검토받는다. 구조, front matter, 팀 별칭·호칭, 메모와의 사실 일치, 톤, 미디어 참조, `naver.md` 형식, 빌드를 본다.

- 넘길 것: 글 폴더 경로, 메모 위치, 단계(`초안` 또는 `발행`)
- 결과가 **수정 필요**면 필수 수정을 고친다. 권장 수정은 사람에게 보여 주고 정한다. 고친 뒤 7단계 검사를 돌리고 다시 검토를 맡긴다.
- 문장을 많이 고쳤으면 5단계 윤문을 다시 거친다.

## 10. `privacy-reviewer` 검토

`Agent` 도구로 `privacy-reviewer` 서브 에이전트를 부른다. 글을 쓴 이 세션과 분리된 눈으로 개인정보를 검토하게 하는 단계다.

- 검토 대상: 이 브랜치에서 바뀐 파일(`git diff main --name-only`와 아직 커밋하지 않은 파일)
- 실명 목록을 프롬프트로 넘기지 않는다. (에이전트가 `.private/`를 직접 읽는다)
- 결과가 **차단**이면 보고된 파일·이유대로 고치고, 7단계 검사 후 다시 검토를 맡긴다. **통과**가 나올 때까지 다음 단계로 가지 않는다.

## 11. 커밋하고 PR 열기

```bash
git add content/posts/YYYY-MM-DD-week-NN
git status   # notes/, .private/, _workspace/, 원본 영상이 섞이지 않았는지 확인
git commit -m "<팀 별칭> NN주차 수업 기록 초안"
```

- 커밋 메시지는 한국어로, 실명 없이 쓴다.
- push하기 전에 `/security-audit`를 가이드 모드로 실행해 이 브랜치의 변경(`main` 대비)을 보안 관점에서 검토받는다. 파일은 만들지 않는다. 취약점이 나오면 고치고 커밋한 뒤 다시 실행한다. 결과는 PR 본문 「검증」에 적는다.
- **push하기 전에 사람에게 확인을 받는다.** 확인을 받으면:
  ```bash
  git push -u origin post/<팀 별칭 소문자>-week-NN
  gh pr create --base main --head post/<팀 별칭 소문자>-week-NN --title "<팀 별칭> NN주차 수업 기록" --body-file <본문>
  ```
- PR 본문 템플릿 (본문 파일은 scratchpad에 만들고 커밋하지 않는다):
  ```markdown
  ## 요약
  - (이번 주 수업 한두 줄)

  ## 참여 팀
  - 🚀 팀1
  - ⭐ 팀2

  ## 사용한 미디어
  - (파일 이름 — 무엇을 보여 주는지, 길이(초), 처리 방법: strip-metadata / clip.sh --crop·--blur 여부. 없으면 「없음」과 이유)
  - (녹화 경위: 수업 뒤 세션이 로컬에서 녹화했는지, 녹화한 쪽이 고른 행동)
  - (확인: 브라우저 UI·계정 표시 없음, 소리 없음, 게임 속 얼굴이 사진이 아니라 코드가 그린 캐릭터인지)

  ## 개인정보 처리 내역
  - (예: 메모의 실명 3개를 명단의 가명으로 바꿈, 학교 이름 1곳 삭제)
  - privacy-check 통과, privacy-reviewer 통과

  ## 네이버 요약본
  - `content/posts/YYYY-MM-DD-week-NN/naver.md`
  ```
- 개인정보 처리 내역에는 **바꾼 개수와 방식만** 쓰고 실명은 절대 쓰지 않는다.

## 12. 사람의 로컬 확인

사람에게 다음을 안내하고 기다린다.

```bash
hugo server --buildDrafts
```

고칠 점이 나오면 같은 브랜치에서 고치고 7·9·10단계를 다시 거친 뒤 커밋·push한다.

## 13. 최종 발행

사람이 발행하자고 하면:

1. 본문과 `naver.md`에 `/humanize-korean`을 한 번 더 실행하고 `git diff`로 보호 항목을 확인한다.
2. `./tools/privacy-check.sh`를 다시 통과시킨다.
3. `fact-checker`, `content-reviewer`(단계 `발행`), `privacy-reviewer`로 다시 검토한다. 수정 필요·차단이면 고치고 다시 검토한다.
4. front matter를 `draft: false`로 바꾸고 `hugo --gc --minify --printPathWarnings`가 경고 없이 끝나는지 확인한다.
5. 커밋하고 사람의 확인을 받아 같은 브랜치에 push한다.
6. **머지는 리뷰어 승인을 받은 뒤 사람이 한다.** (회사 규칙: 리뷰어 승인을 받은 PR로만 반영) 머지 방식은 「Create a merge commit」. 여러 PR이 사슬로 쌓여 있으면 맨 위부터 아래로 머지하고, 다 끝날 때까지 브랜치를 지우지 않는다. `main`에 직접 push하지 않고, force push하지 않는다.

네이버 업로드는 GitHub 발행 뒤에 사람이 `naver.md`를 보고 직접 한다. 이미지는 네이버 에디터에서 따로 올린다.

## 멈춰야 할 때

- **개인정보(실명, 학교·반·동네, 얼굴이 나온 사진·영상, 메모 원본)가 커밋되거나 push된 것을 발견하면** 즉시 모든 작업을 멈추고 사람에게 알린다. 추가 커밋으로 지우거나 덮지 않는다. (퍼블릭 레포는 히스토리에 남으므로 사람이 히스토리 정리를 판단해야 한다)
- `main` 브랜치에 있는 상태에서 커밋해야 하는 상황이 되면 멈춘다.
- 메모가 없거나, 팀 구분이 불분명하거나, `data/teams.yaml`에 없는 팀이 메모에 나오면 추측하지 말고 묻는다.
- `tools/privacy-check.sh`, `tools/clip.sh`, `post-writer`, `fact-checker`, `content-reviewer`, `privacy-reviewer`가 없거나 실행되지 않으면 검사를 건너뛰지 말고 사람에게 알린다.
