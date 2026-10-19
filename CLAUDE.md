# future-ai-kids — Claude Code 작업 규칙

초등학생 연구원들과 매주 진행하는 AI 수업(미래AI육성 캠프) 기록 블로그다. 전체 계획은 `PLAN.md`를 따른다.

## 이 레포는 퍼블릭이다
- 레포에 올라간 것은 전부 공개된다. 초안, PR 본문, 커밋 메시지, 히스토리, 지운 파일까지 포함한다.
- 수업 메모(`notes/`), 원본 영상, 실명 목록(`.private/`)은 **커밋하지 않는다.** 둘 다 `.gitignore` 대상이다.
- 아이들 실명, 학교명, 반, 동네 이름은 글, PR, 커밋 메시지 어디에도 쓰지 않는다.
- 개인정보가 커밋된 것을 발견하면 추가 커밋으로 덮지 않는다. 즉시 작업을 멈추고 사람에게 보고한다. (히스토리 정리가 필요하다)
- `main`에 직접 push하거나 force push하지 않는다. 모든 변경은 브랜치와 PR로 한다.

## 개인정보 검사
- 커밋 전에 반드시 `tools/privacy-check.sh`를 실행한다. (pre-commit hook이 `content/`, `data/`를 자동 검사한다. hook은 `git config core.hooksPath .githooks`로 켠다)
  - `tools/privacy-check.sh [경로 ...]` — 기본 `content/`, 금지어는 `data/`도 함께 본다. 종료 코드 0 통과, 1 실패
  - 검사: 금지어(`.private/names.txt`, 로컬 전용), 사진 GPS, 크기(이미지 2MB, mp4/webm·GIF 3MB), 영상 오디오 트랙
  - GPS가 걸리면 `tools/strip-metadata.sh <글 폴더>`로 메타데이터를 지운다. 영상 크기·오디오는 `tools/clip.sh`로 다시 만든다.
  - hook을 `--no-verify`로 건너뛰지 않는다.
- 메모에 실명이 있으면 글에는 「팀 별칭 + 연구원 A/B/C」로 바꿔 쓰고, 바꾼 사실은 PR 설명에만 남긴다. 실명 자체는 PR에도 쓰지 않는다.
- PR을 열기 전, 그리고 `draft: false`로 바꾸기 전에 `privacy-reviewer` 서브 에이전트를 호출해 독립 검토를 받는다. (얼굴, 이름표, 교복·로고, 화면 속 계정명, 영상 프레임까지 본다) 「차단」이면 고친 뒤 다시 검토받는다.
- 개인정보 커밋을 발견하면 추가 커밋으로 덮지 말고 즉시 멈추고 사람에게 보고한다.
- 검사 테스트에는 가짜 데이터만 쓴다. 테스트 파일과 테스트용 `.private/`는 커밋하지 않고 지운다.

## 글쓰기 규칙
- 아이들 눈높이의 따뜻하고 담백한 톤으로 쓴다. 과장하지 않는다.
- `archetypes/posts/index.md` 구조를 유지한다: 이번 주 주제 → 오늘의 수업 흐름 → 팀별 섹션 → 다음 주 예고
- 한 주에 글 하나, 그 주에 참여한 팀을 모두 한 글에 담는다. 쉰 팀은 섹션과 front matter `teams`에서 뺀다.
- 팀 이름은 `data/teams.yaml`의 별칭(`name`)만 쓴다.
- 아이 호칭은 「<팀 별칭> 연구원 A/B/C」로 쓴다. 메모에 실명이 있으면 이렇게 바꾸고, 바꾼 사실은 PR 설명에만 남긴다. (실명 자체는 PR에도 쓰지 않는다)
- 새 글은 `hugo new content posts/YYYY-MM-DD-week-NN`(끝에 `/index.md`를 붙이지 않는다)로 만들고 `draft: true`로 시작한다. 글 폴더에 `index.md`와 `naver.md`가 함께 생긴다. `/index.md`까지 쓰면 번들 아키타입이 적용되지 않아 제목이 틀리고 `naver.md`도 생기지 않는다.

## 네이버 블로그 요약본
- 글 폴더의 `naver.md`가 네이버 블로그용 요약본이다. `hugo.yaml`의 `ignoreFiles`로 사이트 빌드에서 빠진다.
- 네이버에는 전문을 복사하지 않는다. 유사 문서로 판단되면 노출이 줄어든다. 제목(GitHub 글과 같게), 핵심 3~4줄, 팀마다 「연구원들의 한마디」 1개, 대표 이미지 1장 위치만 담는다.
- 마지막 줄은 `전체 기록 보기 → https://smartjy.github.io/future-ai-kids/posts/<slug>/`로 둔다. 링크는 바꾸지 않는다.
- GitHub에 먼저 발행한 뒤 네이버에 올린다. (링크가 살아 있어야 한다)
- 이미지는 네이버 에디터에서 직접 업로드한다. `naver.md`에는 `[대표 이미지: 파일명 — 네이버 에디터에서 직접 업로드]` 표시만 남긴다.
- `naver.md`도 작성 직후와 네이버 업로드 직전에 `/humanize-korean`을 실행한다.

## 문체 다듬기 (humanize-korean)
- 초안 작성 직후, 그리고 `draft: false`로 바꾸기 직전에 `/humanize-korean`을 실행해 AI 티를 없앤다. 네이버 요약본도 같다.
- front matter, shortcode, 이미지 경로, 링크, 팀 별칭, 「연구원 A」 호칭은 바꾸지 않는다. 윤문 뒤 `git diff`로 확인하고 깨졌으면 되돌린다.
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
