---
description: 수업 메모로 이번 주 기록 글 초안을 쓰고 개인정보 검토를 거쳐 PR을 연다
argument-hint: "[수업 날짜 YYYY-MM-DD]"
allowed-tools: Read, Grep, Glob, Edit, Write, Skill, Agent, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git switch:*), Bash(git checkout:*), Bash(git fetch:*), Bash(git pull:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(hugo:*), Bash(ls:*), Bash(cp:*), Bash(mkdir:*), Bash(file:*), Bash(ffprobe:*), Bash(./tools/privacy-check.sh:*), Bash(./tools/strip-metadata.sh:*), Bash(./tools/clip.sh:*)
---

# /weekly-post — 주간 수업 기록 글쓰기

수업 메모를 바탕으로 한 주 기록 글(`draft: true`)과 네이버 요약본을 쓰고, 개인정보 검토를 거쳐 PR을 연다.
이 레포는 퍼블릭이다. 글, 커밋 메시지, PR 본문, 브랜치 이름 어디에도 아이 실명, 학교명, 반, 동네 이름을 쓰지 않는다.
시작하기 전에 `CLAUDE.md`를 읽고 그 규칙을 따른다.

인자: `$ARGUMENTS` (수업 날짜 `YYYY-MM-DD`. 비어 있으면 1단계에서 묻는다)

## 1. 수업 정보 확인

다음을 사람에게 확인한다. 추측해서 채우지 않는다.

- **수업 날짜**: `$ARGUMENTS`가 있으면 그 날짜를 쓰고, 없으면 묻는다. 형식은 `YYYY-MM-DD`.
- **참여한 팀**: `data/teams.yaml`에서 `active: true`인 팀의 `name`(별칭)과 `id`를 목록으로 보여 주고, 이번 주에 참여한 팀을 고르게 한다.
- **메모 위치**: 둘 중 하나다. 파일이 실제로 있는지 확인한다.
  - `notes/YYYY-MM-DD.md` 한 파일 안에 팀별 제목(`## 팀1` 등)으로 나눠 쓴 경우
  - `notes/YYYY-MM-DD-<team-id>.md` 팀마다 따로 쓴 경우
- **미디어 위치**: 사진·영상 원본은 `notes/YYYY-MM-DD/`에 둔다. 없으면 글만 쓴다.

주차 번호 `NN`은 `content/posts/*-week-NN/` 중 가장 큰 번호에 1을 더해 두 자리(`02`, `03`, ...)로 정한다. 같은 날짜의 글 폴더가 이미 있으면 멈추고 사람에게 묻는다.

`notes/`와 `.private/`는 `.gitignore` 대상이다. 메모 내용을 레포의 다른 파일로 옮겨 적지 않는다.

## 2. 브랜치 만들기

```bash
git switch main
git pull --ff-only
git switch -c post/week-NN
```

- 작업 트리에 커밋하지 않은 변경이 있으면 멈추고 사람에게 묻는다.
- `main`에서는 절대 커밋하지 않는다. 이후 모든 커밋은 `post/week-NN`에서 한다.

## 3. 글 폴더 만들기

```bash
hugo new content posts/YYYY-MM-DD-week-NN
```

- `content/posts/YYYY-MM-DD-week-NN/index.md`가 `draft: true`로 생긴다. 번들 아키타입이면 같은 폴더에 `naver.md`도 함께 생긴다.
- front matter `date`는 수업 날짜(`YYYY-MM-DDT10:00:00+09:00` 꼴)로 고친다.

## 4. 본문 쓰기 (`draft: true`)

메모를 읽고 `CLAUDE.md`의 「글쓰기 규칙」에 맞춰 쓴다.

- 구조를 지킨다: 이번 주 주제 → 오늘의 수업 흐름 → 팀별 섹션(연구원들이 만든 것, 연구원들의 한마디) → 다음 주 예고
- 아이들 눈높이의 따뜻하고 담백한 톤. 과장하지 않는다. 메모에 없는 일을 지어내지 않는다.
- 팀 이름은 `data/teams.yaml`의 `name`(별칭)만 쓴다.
- **실명 바꾸기**: 메모의 아이 이름은 팀마다 처음 나온 순서대로 「<팀 별칭> 연구원 A」, 「… 연구원 B」, 「… 연구원 C」로 바꾼다.
  - 실명과 호칭의 대응표는 **이 대화 안에서만** 기억한다. 글, 주석, 커밋 메시지, PR 본문, scratchpad 등 **어떤 파일에도 쓰지 않는다.**
  - 성만, 별명만, 이니셜만 나와도 실명으로 본다. 학교명, 반, 동네, 선생님·보호자 이름도 지운다.
- **쉰 팀 빼기**: 이번 주에 참여하지 않은 팀은 본문 섹션과 front matter `teams` 목록에서 모두 지운다.
- `summary`에 한 줄 요약, `tags`에 이번 주 주제 낱말 2~3개를 넣는다.
- 쓴 뒤 메모 속 실명이 글에 남지 않았는지 `Grep`으로 확인한다. (검색어는 대화 안에서만 쓰고 파일로 남기지 않는다)

## 5. 문체 다듬기 (`/humanize-korean`)

`/humanize-korean` 스킬로 **본문만** 윤문해 AI 티를 없앤다.

- 바꾸지 않는 것: front matter, shortcode(`{{< clip ... >}}` 등), 이미지·영상 경로, 링크, 팀 별칭, 「<팀 별칭> 연구원 A」 호칭, 제목(`##`) 구조
- 윤문 뒤 `git diff`(새 파일이면 윤문 전 내용과 비교)로 위 항목이 그대로인지 확인하고, 깨졌으면 그 부분을 되돌린다.
- 스킬이 만드는 `_workspace/`는 커밋하지 않는다. (`.gitignore` 대상)

## 6. 사진·영상 넣기

미디어가 없으면 건너뛴다. 원본은 `notes/YYYY-MM-DD/`에만 두고 레포로 직접 옮기지 않는다.

- **사진**: 쓸 사진만 글 폴더에 복사한 뒤 메타데이터를 지운다.
  ```bash
  cp notes/YYYY-MM-DD/<사진> content/posts/YYYY-MM-DD-week-NN/<영문-이름>.jpg
  ./tools/strip-metadata.sh content/posts/YYYY-MM-DD-week-NN
  ```
  복사하기 전에 사진을 직접 열어 얼굴, 이름표, 교복·학교 로고, 화면 속 계정명·알림, 유리·모니터 반사가 없는지 본다. 있으면 쓰지 않는다.
- **영상**: `tools/clip.sh`로 쓸 장면만 잘라 결과물(mp4/gif/jpg)만 글 폴더에 만든다. 소리는 항상 제거된다.
  ```bash
  # 얼굴·이름표가 나올 수 있으면 먼저 한 프레임을 보고 좌표를 잡는다
  ./tools/clip.sh notes/YYYY-MM-DD/<원본> <시작 mm:ss> <길이(초)> content/posts/YYYY-MM-DD-week-NN <이름> --preview
  # 필요하면 남길 영역만 자르거나 고정 영역을 흐린다
  ./tools/clip.sh notes/YYYY-MM-DD/<원본> <시작 mm:ss> <길이(초)> content/posts/YYYY-MM-DD-week-NN <이름> --crop W:H:X:Y --blur W:H:X:Y
  ```
  - 얼굴이 움직이며 나오는 장면은 blur로 가리지 말고 쓰지 않는다.
  - 4초 이하 장면은 GIF, 그보다 길면 MP4를 쓴다.
- 본문에는 shortcode로 넣고, `alt`에는 장면을 설명하는 한국어 문장을 쓴다. (아이 이름 금지)
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

같은 글 폴더의 `naver.md`를 채운다. (3단계에서 생기지 않았으면 직접 만든다. 사이트 빌드에는 나오지 않는다)

- 제목: GitHub 글과 같다.
- 본문: 핵심 3~4줄(공통), 참여한 팀마다 「연구원들의 한마디」 1개, 대표 이미지 1장 위치 표시(예: `[대표 이미지: <파일 이름>]`)
- 마지막 줄: `전체 기록 보기 → https://smartjy.github.io/future-ai-kids/posts/<slug>/`
- 전문을 복사하지 않는다. (유사 문서로 판단되면 네이버 노출이 줄어든다)
- 쓴 뒤 `/humanize-korean`으로 윤문하고, 5단계와 같은 방법으로 링크·호칭·별칭이 그대로인지 확인한다. 그다음 7단계 검사를 다시 돌린다.

## 9. `privacy-reviewer` 검토

`Agent` 도구로 `privacy-reviewer` 서브 에이전트를 부른다. 글을 쓴 이 세션과 분리된 눈으로 개인정보를 검토하게 하는 단계다.

- 검토 대상: 이 브랜치에서 바뀐 파일(`git diff main --name-only`와 아직 커밋하지 않은 파일)
- 실명 대응표는 에이전트에 넘기지 않는다.
- 결과가 **차단**이면 보고된 파일·이유대로 고치고, 7단계 검사 후 다시 검토를 맡긴다. **통과**가 나올 때까지 다음 단계로 가지 않는다.

## 10. 커밋하고 PR 열기

```bash
git add content/posts/YYYY-MM-DD-week-NN
git status   # notes/, .private/, _workspace/, 원본 영상이 섞이지 않았는지 확인
git commit -m "NN주차 수업 기록 초안"
```

- 커밋 메시지는 한국어로, 실명 없이 쓴다.
- **push하기 전에 사람에게 확인을 받는다.** 확인을 받으면:
  ```bash
  git push -u origin post/week-NN
  gh pr create --base main --head post/week-NN --title "NN주차 수업 기록" --body-file <본문>
  ```
- PR 본문 템플릿 (본문 파일은 scratchpad에 만들고 커밋하지 않는다):
  ```markdown
  ## 요약
  - (이번 주 수업 한두 줄)

  ## 참여 팀
  - 🚀 팀1
  - ⭐ 팀2

  ## 사용한 미디어
  - (파일 이름 — 무엇을 보여 주는지, 처리 방법: strip-metadata / clip.sh --crop·--blur 여부. 없으면 「없음」)

  ## 개인정보 처리 내역
  - (예: 메모의 실명 3개를 「팀1 연구원 A~C」로 바꿈, 학교 이름 1곳 삭제)
  - privacy-check 통과, privacy-reviewer 통과

  ## 네이버 요약본
  - `content/posts/YYYY-MM-DD-week-NN/naver.md`
  ```
- 개인정보 처리 내역에는 **바꾼 개수와 방식만** 쓰고 실명은 절대 쓰지 않는다.

## 11. 사람의 로컬 확인

사람에게 다음을 안내하고 기다린다.

```bash
hugo server --buildDrafts
```

고칠 점이 나오면 같은 브랜치에서 고치고 7단계와 9단계를 다시 거친 뒤 커밋·push한다.

## 12. 최종 발행

사람이 발행하자고 하면:

1. 본문과 `naver.md`에 `/humanize-korean`을 한 번 더 실행하고 `git diff`로 보호 항목을 확인한다.
2. `./tools/privacy-check.sh`를 다시 통과시킨다.
3. `privacy-reviewer`로 다시 검토한다. 차단이면 고치고 다시 검토한다.
4. front matter를 `draft: false`로 바꾸고 `hugo --gc --minify --printPathWarnings`가 경고 없이 끝나는지 확인한다.
5. 커밋하고 사람의 확인을 받아 같은 브랜치에 push한다.
6. **머지는 사람이 한다.** `main`에 직접 push하지 않고, force push하지 않는다.

네이버 업로드는 GitHub 발행 뒤에 사람이 `naver.md`를 보고 직접 한다. 이미지는 네이버 에디터에서 따로 올린다.

## 멈춰야 할 때

- **개인정보(실명, 학교·반·동네, 얼굴이 나온 사진·영상, 메모 원본)가 커밋되거나 push된 것을 발견하면** 즉시 모든 작업을 멈추고 사람에게 알린다. 추가 커밋으로 지우거나 덮지 않는다. (퍼블릭 레포는 히스토리에 남으므로 사람이 히스토리 정리를 판단해야 한다)
- `main` 브랜치에 있는 상태에서 커밋해야 하는 상황이 되면 멈춘다.
- 메모가 없거나, 팀 구분이 불분명하거나, `data/teams.yaml`에 없는 팀이 메모에 나오면 추측하지 말고 묻는다.
- `tools/privacy-check.sh`, `tools/clip.sh`, `privacy-reviewer`가 없거나 실행되지 않으면 검사를 건너뛰지 말고 사람에게 알린다.
