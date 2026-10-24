# future-ai-kids — Claude Code 작업 규칙

초등학생 아이들과 매주 진행하는 AI 수업(미래AI육성 캠프) 기록 블로그다. 전체 계획은 `PLAN.md`를 따른다.

## 이 레포는 퍼블릭이다
- 레포에 올라간 것은 전부 공개된다. 초안, PR 본문, 커밋 메시지, 히스토리, 지운 파일까지 포함한다.
- 수업 메모(`notes/`), 원본 영상, 실명 목록·명단(`.private/`)은 **커밋하지 않는다.** 둘 다 `.gitignore` 대상이다.
- 아이들 실명, 학교명, 반, 동네 이름은 글, PR, 커밋 메시지 어디에도 쓰지 않는다.
- 개인정보가 커밋된 것을 발견하면 추가 커밋으로 덮지 않는다. 즉시 작업을 멈추고 사람에게 보고한다. (히스토리 정리가 필요하다)
- `main`에 직접 push하거나 force push하지 않는다. 모든 변경은 브랜치와 PR로 한다.
- push하기 전에 항상 `/security-review`로 그 브랜치의 변경을 보안 관점에서 검토받는다. 글만 바꾼 브랜치도 같다. 취약점이 나오면 고치고 커밋한 뒤 다시 실행하고, 결과(발견 없음 또는 고친 것)는 PR 본문 「검증」에 적는다. 보고서에 실명이나 비밀 정보를 옮기지 않는다.

## 개인정보 검사
- 커밋 전에 반드시 `tools/privacy-check.sh`를 실행한다. (pre-commit hook이 `content/`, `data/`를 자동 검사한다. hook은 `git config core.hooksPath .githooks`로 켠다)
  - `tools/privacy-check.sh [경로 ...]` — 기본 `content/`, 금지어는 `data/`도 함께 본다. 종료 코드 0 통과, 1 실패
  - 검사: 금지어(`.private/names.txt`, 로컬 전용), 사진 GPS, 크기(이미지 2MB, mp4/webm·GIF 3MB), 영상 오디오 트랙
  - GPS가 걸리면 `tools/strip-metadata.sh <글 폴더>`로 메타데이터를 지운다. 영상 크기·오디오는 `tools/clip.sh`로 다시 만든다.
  - hook을 `--no-verify`로 건너뛰지 않는다.
- 메모에 실명이 있으면 글에는 `.private/roster.yaml`의 가명으로 바꿔 쓰고, 바꾼 사실은 PR 설명에만 남긴다. 실명과 가명의 대응은 PR에도 쓰지 않는다.
- PR을 열기 전, 그리고 `draft: false`로 바꾸기 전에 `privacy-reviewer` 서브 에이전트를 호출해 독립 검토를 받는다. (얼굴, 이름표, 교복·로고, 화면 속 계정명, 영상 프레임까지 본다) 「차단」이면 고친 뒤 다시 검토받는다.
- 개인정보 커밋을 발견하면 추가 커밋으로 덮지 말고 즉시 멈추고 사람에게 보고한다.
- 검사 테스트에는 가짜 데이터만 쓴다. 테스트 파일과 테스트용 `.private/`는 커밋하지 않고 지운다.

## 글쓰기 규칙
- 아이와 부모가 함께 읽는다. 해요체(「~했어요」)로, 따뜻하고 담백하게 쓴다. 과장하지 않는다.
- 글의 중심은 아이들이 한 일이다. 강의 내용(이번 주 주제)은 2~4개 짧은 단락으로 큰 흐름만 쓰고, 슬라이드 예시(옛날 물건, 인물, 연도 등)를 늘어놓지 않는다. 아이와 어른이 함께 공감할 수 있는 말로 쓴다.
- 메모에 아이별 이야기(누가 무엇을 했는지, 한 말, 있었던 일)가 없으면 초안을 쓰기 전에 사람에게 알린다. 없는 채로 쓰면 아이들 이야기가 빠진 글이 된다.
- `archetypes/posts/index.md` 구조를 유지한다: 이번 주 주제 → 오늘의 수업 흐름 → 팀별 섹션 → 숙제 → 다음 주 예고
- 「아이들의 한마디」, 「숙제」, 「다음 주 예고」는 메모에 내용이 있을 때만 넣는다. 비어 있으면 섹션째 뺀다. (지어내지 않는다)
- 첫 섹션 제목은 「이번 주 주제」라는 문구가 아니라 그 주 주제 자체로 쓴다. (예: `## AI 시대, 나는 어떤 일을 하게 될까?`) 글 제목(`title`)은 「N주차 · <그 주에 만든 것>」으로 두어 섹션 제목과 겹치지 않게 한다.
- 수업 날짜 하나에 글 하나, 그날 참여한 팀을 모두 한 글에 담는다. 쉰 팀은 섹션과 front matter `teams`에서 뺀다.
- 주차는 팀별로 센다. `NN`은 `content/posts/*/index.md` 중 front matter `teams`에 그 팀이 들어간 글 수에 1을 더한 두 자리 번호다. (예: TeamA가 두 번 수업했으면 TeamA의 다음 글은 `03`) 한 글에 들어갈 팀들의 주차가 서로 다르면 멈추고 사람에게 묻는다. 제목의 「N주차」와 폴더의 `week-NN`도 이 번호를 쓴다. 날짜가 달라 폴더 이름은 겹치지 않는다.
- 팀 이름은 `data/teams.yaml`의 별칭(`name`)만 쓴다.
- front matter `made`에 참여한 팀마다 그 주에 만든 것을 짧게 쓴다. (예: `TeamA: "게임 DOUMY"`) 홈 화면의 팀 카드와 주차별 기록판에 나온다. 메모에 근거가 있어야 하고, 쉰 팀은 넣지 않는다. 아이 이름(가명 포함)·학교·장소는 넣지 않는다.
- 글에서는 Claude 같은 AI 제품·서비스 이름을 쓰지 않고 「AI」라고 쓴다. 태그에도 넣지 않는다.
- 글 초안과 `naver.md`는 `post-writer` 서브 에이전트에 맡긴다. 브랜치·커밋·윤문은 메인 세션이 한다.
- 커밋하기 전에 `fact-checker` 서브 에이전트로 글의 문장이 메모·원본 사진·영상과 맞는지 검증받는다. 근거 없는 문장, 메모와 다른 사실, 부풀린 표현은 고치거나 뺀다. 윤문 뒤에도 다시 검증받는다.
- 그다음 `content-reviewer` 서브 에이전트로 글 내용(구조, front matter, 호칭, 메모와의 사실 일치, 톤, 미디어, 요약본, 빌드)을 검토받는다. 「수정 필요」면 고친 뒤 다시 검토받는다.
- 아이는 「<가명>」으로 부른다. 「연구원」을 붙이지 않고, 여럿을 가리킬 때는 「아이들」이라고 쓴다. 가명은 성은 실명 그대로, 이름은 초성이 같은 다른 이름이고 `.private/roster.yaml`(로컬 전용, 팀 `id`별 `real`·`pseudonym`·`role`)에만 있다. 명단에 없는 아이가 나오면 가명을 지어 쓰지 말고 사람에게 묻는다.
- 새 아이가 생기면 `.private/roster.yaml`에 실명·가명을 넣고, 실명(성+이름, 두 글자 이상 이름)을 `.private/names.txt`에도 넣는다. 가명이 금지어에 걸리지 않는지 확인한다.
- 새 글은 `hugo new content posts/YYYY-MM-DD-week-NN`(끝에 `/index.md`를 붙이지 않는다)로 만들고 `draft: true`로 시작한다. 글 폴더에 `index.md`와 `naver.md`가 함께 생긴다. `/index.md`까지 쓰면 번들 아키타입이 적용되지 않아 제목이 틀리고 `naver.md`도 생기지 않는다.

## 네이버 블로그 요약본
> **지금은 중단.** 네이버 블로그는 운영하지 않는다. 사람이 다시 운영하자고 하기 전까지 `naver.md`를 쓰거나 고치지 않고, 네이버 관련 단계는 모두 건너뛴다. (`hugo new`가 만드는 빈 `naver.md`는 그대로 둔다)

- 글 폴더의 `naver.md`가 네이버 블로그용 요약본이다. 글 폴더(페이지 번들) 안의 리소스라 사이트에 따로 게시되지 않는다. PR check가 빌드 결과에 요약본이 없는지 확인한다. (`ignoreFiles`로 빼면 `hugo new content`가 오류로 끝나서 쓰지 않는다)
- 네이버에는 전문을 복사하지 않는다. 유사 문서로 판단되면 노출이 줄어든다. 제목(GitHub 글과 같게), 핵심 3~4줄, 팀마다 「아이들의 한마디」 1개(메모에 있을 때만), 대표 이미지 1장 위치만 담는다.
- 마지막 줄은 `전체 기록 보기 → https://smartjy.github.io/future-ai-kids/posts/<slug>/`로 둔다. 링크는 바꾸지 않는다.
- GitHub에 먼저 발행한 뒤 네이버에 올린다. (링크가 살아 있어야 한다)
- 이미지는 네이버 에디터에서 직접 업로드한다. `naver.md`에는 `[대표 이미지: 파일명 — 네이버 에디터에서 직접 업로드]` 표시만 남긴다.
- `naver.md`도 작성 직후와 네이버 업로드 직전에 `/humanize-korean`을 실행한다.

## 주간 글쓰기 (/weekly-post)
- 매주 글은 `/weekly-post [YYYY-MM-DD]`로 쓴다. 자세한 단계는 `.claude/commands/weekly-post.md`에 있다.
- 흐름: 날짜·참여 팀·메모 확인 → `main`에서 `post/<팀 별칭 소문자>-week-NN` 브랜치(예: `post/teamb-week-01`) → `hugo new content` → 본문 초안(`post-writer`) → `/humanize-korean` → 사진(`tools/strip-metadata.sh`)·영상(`tools/clip.sh`) → `tools/privacy-check.sh` → `naver.md`(`post-writer`) → `fact-checker` → `content-reviewer` → `privacy-reviewer` → `/security-review` → 사람 확인 후 push·PR
- 메모는 `notes/YYYY-MM-DD/` 폴더에 `class.md`(공통: 강의 주제, 수업 흐름, 다음 주 예고)와 팀마다 `<team-id>.md`(예: `team1.md`)로 둔다. 쉰 팀은 파일을 만들지 않는다. 미디어 원본은 `notes/YYYY-MM-DD/media/`에 두고 파일 이름 앞에 팀 id(공통이면 `class-`)를 붙인다. 메모 예시는 `notes.example/2026-10-24/`에 있다.
- 실명과 가명의 대응은 `.private/roster.yaml`에만 둔다. 다른 파일(글, 주석, scratchpad, 커밋 메시지, PR 본문)에는 남기지 않는다.
- 발행은 사람이 `hugo server --buildDrafts`로 확인한 뒤, 윤문과 `fact-checker`·`content-reviewer`·`privacy-reviewer`를 한 번 더 거쳐 `draft: false`로 바꾸고 사람이 머지한다.

## 문체 다듬기 (humanize-korean)
- 초안 작성 직후, 그리고 `draft: false`로 바꾸기 직전에 `/humanize-korean`을 실행해 AI 티를 없앤다. 네이버 요약본도 같다.
- front matter, shortcode, 이미지 경로, 링크, 팀 별칭, 가명 호칭은 바꾸지 않는다. 문체(해요체)도 바꾸지 않는다. (윤문은 문체를 그대로 두므로 초안부터 해요체로 쓴다) 윤문 뒤 `git diff`로 확인하고 깨졌으면 되돌린다.
- 스킬이 만드는 `_workspace/`는 커밋하지 않는다.

## 영상 규칙
- 얼굴이 나오지 않는 영상만 쓴다. (위에서 내려다본 손·화면 구도, 화면 녹화)
- blur는 보조 수단이다. 얼굴이 움직이며 나오는 장면은 쓰지 않는다.
- 소리는 항상 제거한다. (`tools/clip.sh`가 `-an`으로 뺀다)
- 화면 속 계정 이름, 알림, 프로필 사진, 이름표, 유리·모니터 반사를 확인한다.
- 4초 이하는 GIF, 그보다 길면 MP4를 쓴다. 쓰지 않는 결과물은 지운다.
- 원본 영상은 `notes/` 또는 레포 밖에만 둔다. 글 폴더에는 `tools/clip.sh` 결과물(mp4/gif/jpg)만 넣는다.
- 본문에는 `{{< clip src="app-demo.mp4" alt="퀴즈 앱이 점수를 올리는 장면" >}}`로 넣는다. `alt`는 필수다.

```sh
# 좌표 잡기: 시작 프레임만 레포 밖 임시 폴더에 저장 (원본 크기도 출력)
./tools/clip.sh "notes/1주차 수업.mp4" 01:05 6 content/posts/2026-10-24-week-02 app-demo --preview
# 결과물 만들기: crop 먼저, blur 좌표는 crop 뒤 화면 기준
./tools/clip.sh "notes/1주차 수업.mp4" 01:05 6 content/posts/2026-10-24-week-02 app-demo --crop 1280:600:0:120 --blur 200:80:1000:20
```

## 빌드 확인
- `hugo --gc --minify --printPathWarnings`가 경고 없이 끝나야 한다.
- 초안 확인: `hugo server --buildDrafts`
