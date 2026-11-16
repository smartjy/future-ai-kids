---
description: 수업 메모로 이번 주 기록 글을 쓰고(/draft-post), 미리 보기 확인 뒤 draft false로 PR을 한 번 열고, 머지 뒤 발행을 확인한다
argument-hint: "[수업 날짜 YYYY-MM-DD]"
allowed-tools: Read, Grep, Glob, Edit, Write, Skill, Agent, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git switch:*), Bash(git checkout:*), Bash(git fetch:*), Bash(git pull:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(hugo:*), Bash(ls:*), Bash(cp:*), Bash(mkdir:*), Bash(file:*), Bash(ffprobe:*), Bash(./tools/privacy-check.sh:*), Bash(./tools/strip-metadata.sh:*), Bash(./tools/clip.sh:*), Bash(./tools/frames.sh:*), Bash(./tools/humanize-body.sh:*), Bash(gh run list:*)
---

# /weekly-post — 주간 수업 기록 글쓰기

수업 메모를 바탕으로 한 주 기록 글을 쓰고, 검토와 사람의 미리 보기 확인을 거쳐 `draft: false`로 PR을 한 번 연다. 머지하면 바로 발행된다.
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
  - AI 앱 대화 정리: 학생들이 AI 앱에 보낸 요청을 정리한 글을 사람이 붙여 넣으면, 한 팀 것이면 `<team-id>.md`로 저장하고 머리에 출처(「사람이 붙여 넣은 AI 앱 대화 정리」)를 적는다. 세션은 AI 앱의 대화 기록을 직접 읽을 수 없다. 사람에게 붙여 달라고 하고, 앱의 로컬 저장소(`~/Library/Application Support/` 등)를 뒤지지 않는다. 정리에 「아이들과 해 보기」처럼 누가 한 일인지 모호한 문장이 있으면 수업에서 학생들이 한 일인지 먼저 묻는다.
  - `class.md`가 없으면 첫 섹션 제목(그 주 주제)은 메모의 흐름으로 짓고, 사람에게 보여 줄 때 「사람이 정할 것」에 넣는다.
- **미디어 위치**: 사진·영상 원본은 `notes/YYYY-MM-DD/media/`에 둔다. 파일 이름 앞에 팀 id(공통이면 `class-`)를 붙인다.
- **게임 영상**: 글에는 정리한 수업 내용과 그 주 게임 영상(게임 화면 녹화)이 함께 들어간다. 참여 팀마다 `media/`에 `<team-id>-game.*`(mp4/webm/mov) 같은 게임 화면 녹화가 있는지 직접 본다.
  - 없으면 「<팀 별칭>의 게임 화면 녹화가 `notes/YYYY-MM-DD/media/`에 없어요. 넣어 주실 수 있나요?」라고 묻는다. 「미디어가 있나요?」처럼 막연하게 묻지 않는다.
  - 사람이 그 주에 게임 영상이 정말 없다고 확인한 팀만 영상 없이 쓴다. 그 사실은 PR 본문 「사용한 미디어」에 적는다.
  - 녹음 앱의 소리 파일(`audio.mp4` 등)은 영상이 아니다. 소리는 쓰지 않으므로 글에 넣지 않는다.

주차는 팀별로 센다. `NN`은 `content/posts/*/index.md` 중 front matter `teams`에 그 팀이 들어간 글 수에 1을 더한 두 자리 번호다. (예: Doumy가 두 번 수업했으면 Doumy의 다음 글은 `03`) 한 글에 들어갈 팀들의 주차가 서로 다르면 멈추고 사람에게 묻는다. 지금까지는 팀별로 글·브랜치·PR을 나눴다. (예: 2026-11-07에 Bsil `week-01`과 Wanted `week-03`을 따로 냈다) 나누자고 하면 팀마다 2단계부터 따로 진행한다. 같은 날짜의 글 폴더가 이미 있으면 멈추고 사람에게 묻는다. 나눈 글은 같은 작업 폴더에서 하나씩 브랜치를 만들어 커밋한다. 아직 커밋하지 않은 다른 팀 글 폴더가 섞이지 않게 `git add`에는 그 글 폴더만 지정한다. 같은 날짜에 주차 번호까지 같아 폴더 이름이 겹치는 경우도 묻는다.

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

- `content/posts/YYYY-MM-DD-week-NN/index.md`가 `draft: true`로 생긴다. 미리 보기를 확인받을 때까지 `true`로 두고, 확인받으면 5단계에서 `false`로 바꾼다. 번들 아키타입이면 같은 폴더에 `naver.md`도 함께 생긴다.
- front matter `date`는 수업 날짜(`YYYY-MM-DDT10:00:00+09:00` 꼴)로 고친다.

## 4. 초안부터 검토까지 — `/draft-post`

`Skill` 도구로 `/draft-post YYYY-MM-DD`를 실행한다. 글을 쓰고 검토하는 규칙은 그 스킬에 한 곳으로 모여 있다.

- 사진·영상(게임 영상이 없으면 `/record-game`으로 녹화), `post-writer` 초안, `/humanize-korean` 윤문(`tools/humanize-body.sh`), `tools/privacy-check.sh`, `fact-checker`, `content-reviewer`, `privacy-reviewer`를 차례로 거친다.
- 네이버 요약본(`naver.md`)은 지금 중단 상태라 건너뛴다. 다시 운영하면 `post-writer`에 작업 `요약본`을 맡기고 `CLAUDE.md` 「네이버 블로그 요약본」 규칙을 따른다.
- `/draft-post`가 사람에게 미리 보기를 보여 주면 5단계로 간다.

## 5. 사람의 미리 보기 확인

사람에게 미리 보기 주소를 알려 주고 기다린다. (세션이 서버를 띄워도 된다)

```bash
hugo server --buildDrafts
# http://localhost:1313/future-ai-kids/posts/YYYY-MM-DD-week-NN/
```

- 고칠 점이 나오면 고치고, `/draft-post` 9단계 끝의 기준대로 고친 범위만큼 다시 검토받는다. (문장 → `fact-checker`, 많이 고치면 윤문·`content-reviewer`까지, 사진·영상 → `privacy-reviewer`) 그 뒤 다시 미리 보기를 확인받는다.
- 사람이 확인하면 front matter를 `draft: false`로 바꾸고 `hugo --gc --minify --printPathWarnings`가 경고 없이 끝나는지 본다. **초안 PR과 발행 PR을 따로 두지 않는다.** PR은 한 번만 열고, 머지하면 바로 발행된다.

## 6. 커밋하고 PR 열기

```bash
git add content/posts/YYYY-MM-DD-week-NN
git status   # notes/, .private/, _workspace/, 원본 영상, 다른 팀의 커밋하지 않은 글 폴더가 섞이지 않았는지 확인
git commit -m "<팀 별칭> NN주차 수업 기록"
```

- 커밋 메시지는 한국어로, 실명 없이 쓴다.
- push하기 전에 `/security-audit`를 가이드 모드로 실행해 이 브랜치의 변경(`main` 대비)을 보안 관점에서 검토받는다. 파일은 만들지 않는다. 취약점이 나오면 고치고 커밋한 뒤 다시 실행한다. 결과는 PR 본문 「검증」에 적는다.
- 미리 보기를 확인한 사람이 올리라고 했으면 push하고 PR을 연다:
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

## 7. 머지와 발행 확인

1. **머지는 리뷰어 승인을 받은 뒤 사람이 한다.** (회사 규칙: 리뷰어 승인을 받은 PR로만 반영) 머지 방식은 「Create a merge commit」. `main`에 직접 push하지 않고, force push하지 않는다. 머지하면 `draft: false`인 글이 바로 발행된다.
2. PR을 연 뒤에 고칠 것이 생기면 **push하기 전에 `gh pr view <번호> --json state`로 PR이 아직 열려 있는지 본다.** 이미 머지됐으면 그 브랜치에 push해도 `main`에 반영되지 않는다. `main`에서 새 브랜치를 만들어 고친 커밋을 옮기고(`git cherry-pick`) 새 PR을 연다. push한 뒤에는 `gh pr view <번호> --json commits`로 커밋이 PR에 들어갔는지 확인하고 나서 사람에게 머지를 부탁한다.
3. 머지된 뒤 `gh run list`로 배포가 성공했는지, 글 주소가 열리는지(HTTP 200) 확인해 알린다.

네이버 업로드는 GitHub 발행 뒤에 사람이 `naver.md`를 보고 직접 한다. 이미지는 네이버 에디터에서 따로 올린다.

## 멈춰야 할 때

- **개인정보(실명, 학교·반·동네, 얼굴이 나온 사진·영상, 메모 원본)가 커밋되거나 push된 것을 발견하면** 즉시 모든 작업을 멈추고 사람에게 알린다. 추가 커밋으로 지우거나 덮지 않는다. (퍼블릭 레포는 히스토리에 남으므로 사람이 히스토리 정리를 판단해야 한다)
- `main` 브랜치에 있는 상태에서 커밋해야 하는 상황이 되면 멈춘다.
- 메모가 없거나, 팀 구분이 불분명하거나, `data/teams.yaml`에 없는 팀이 메모에 나오면 추측하지 말고 묻는다.
- `tools/privacy-check.sh`, `tools/clip.sh`, `post-writer`, `fact-checker`, `content-reviewer`, `privacy-reviewer`가 없거나 실행되지 않으면 검사를 건너뛰지 말고 사람에게 알린다.
