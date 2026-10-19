# future-ai-kids 블로그 구축 계획서 (Claude Code용)

> 이 문서는 승인 후 레포 루트에 `PLAN.md`로 저장한다. Claude Code에 "PLAN.md 순서대로 진행해 줘"라고 요청한다.
> Phase마다 별도 브랜치와 PR로 진행하고, Phase가 끝날 때마다 사람의 확인을 받은 뒤 다음으로 넘어간다.
> 이번 승인 범위: **PLAN.md 저장 + Phase 1**. Phase 1 PR을 연 뒤 멈춘다.

## 0. 목표와 전제

- **목적:** 초등학생 아이들과 매주 진행하는 AI 수업(미래AI육성 캠프) 기록을 주 1회 블로그로 남긴다.
- **레포:** `smartjy/future-ai-kids` (퍼블릭, 현재 `README.md`만 있는 상태)
- **생성기:** Hugo (Apache-2.0) + PaperMod 테마 (MIT, `themes/PaperMod`에 벤더링)
- **배포:** GitHub Pages (공식 `actions/deploy-pages`)
- **주소:** https://smartjy.github.io/future-ai-kids/
- **블로그 정보:** 이름 `미래AI육성 캠프` / 설명 `AI with our kids — 아이들과 AI 기록` / 작성자 `AI연구소장`
- **출발점:** 스캐폴드 zip이 없으므로 이 계획서를 기준으로 스캐폴드를 새로 만든다.
- **팀 구성:** 현재 2팀, 앞으로 늘어날 수 있다. 매주 **글 1개에 여러 팀을 함께** 쓰고, 팀 이름은 **별칭**(예: 로켓팀, 별빛팀)만 쓴다.
- **문체:** 초안 작성 직후와 최종 발행 직전에 `/humanize-korean` 스킬로 AI 티를 없앤다.

### 로컬 준비물
| 도구 | 용도 | 라이선스 | 상태 |
|---|---|---|---|
| hugo (extended, 0.168.0) | 빌드 | Apache-2.0 | 설치 필요 (`brew install hugo`) |
| exiftool | 메타데이터 검사·제거 | Artistic/GPL, 로컬 CLI로만 사용 | 설치 필요 (`brew install exiftool`) |
| ffmpeg / ffprobe | 클립 변환, 오디오 검사 | LGPL/GPL, 로컬 CLI로만 사용 | 설치됨 |
| gh | PR 생성 | MIT | 설치됨 |
| humanize-korean 플러그인 (`im-not-ai`, v2.3.2) | 윤문 | MIT | 설치돼 있으나 비활성 → `/plugin`에서 켜고 세션 재시작 |

### 퍼블릭 레포라서 달라지는 핵심 원칙
- 레포에 올라간 것은 전부 공개된다. 초안, PR, 커밋 히스토리, 지운 파일까지 포함한다.
- 개인정보 검사는 push 전에 로컬에서 막는다. CI 검사는 2차 안전망이다.
- 수업 메모 원본, 원본 영상, 아이들 실명 목록은 레포 밖 또는 `.gitignore` 대상 폴더에만 둔다.
- 개인정보가 커밋된 것을 발견하면 파일만 지워서는 안 된다. 히스토리 정리(`git filter-repo`)가 필요하므로 즉시 작업을 멈추고 사람에게 알린다.
- `main`에 직접 push하거나 force push하지 않는다. 모든 변경은 PR로 한다.

---

## Phase 1. 레포 초기화와 퍼블릭 대응

**브랜치:** `setup/public-repo`

### 작업
1. 이 계획서를 `PLAN.md`로 저장한다.
2. 스캐폴드를 새로 만든다.
   - `themes/PaperMod`: 공식 레포 최신 릴리스 태그를 shallow clone한 뒤 `.git`을 지우고 벤더링한다. `LICENSE`는 남긴다.
   - `hugo.yaml`
     - `baseURL: https://smartjy.github.io/future-ai-kids/`, `languageCode: ko-kr`, `defaultContentLanguage: ko`
     - title, description, author는 0번의 블로그 정보대로
     - 메뉴: 글 / 팀 / 태그 / 검색. 출력: HTML, RSS, JSON(검색용)
     - `taxonomies`: `tag: tags`, `team: teams`
     - 외부 분석·댓글 스크립트는 넣지 않는다.
   - `data/teams.yaml`: 팀 목록 (`id`, `name`(별칭), `emoji`, `intro`, `active`)
     - 별칭은 사용자에게 받아 채운다. 받기 전에는 `팀1`, `팀2` 임시값을 둔다.
     - 학교명, 동네, 반 이름은 쓰지 않는다.
     - 새 팀은 여기에 한 줄만 추가하면 된다.
   - `archetypes/posts.md`
     - front matter: `title`, `date`, `draft: true`, `tags`, `teams`, `summary`, `cover`
     - 본문 골격: 이번 주 주제 → 오늘의 수업 흐름 → 활성 팀마다 `## <emoji> <별칭>` 섹션(연구원들이 만든 것 / 연구원들의 한마디) → 다음 주 예고
     - 팀 섹션과 `teams` 값은 `site.Data.teams`에서 `active: true`인 팀으로 자동 생성한다. 그 주에 쉰 팀은 지운다.
   - `CLAUDE.md`
     - 글쓰기 규칙: 아이들 눈높이의 따뜻한 톤, archetype 구조 유지, 호칭은 「로켓팀 연구원 A」처럼 팀 별칭 + 연구원 A/B/C
     - 메모(`notes/`)와 실명 목록(`.private/`)은 커밋하지 않는다.
     - 개인정보 원칙(위 퍼블릭 레포 원칙 요약), main 직접 push 금지
     - humanize 규칙(아래 「문체 다듬기」 참고)
   - `content/posts/<YYYY-MM-DD>-week-01/index.md`: 1주차 샘플 초안. `draft: true`, 가상의 수업 내용, 2팀 섹션 포함, 실명·사진 없음. 작성 후 `/humanize-korean` 적용
   - `.github/workflows/pr-check.yml`: PR에서 `hugo --gc --minify --buildDrafts` 빌드 확인 (Phase 2에서 보강)
3. `.gitignore`: `notes/`, `.private/`, `_workspace/`(humanize 중간 산출물), `public/`, `resources/_gen/`, `.hugo_build.lock`
4. `.private.example/names.txt`: 예시 단어만 둔다 (예: `홍길동`, `예시초등학교`).
5. README: 소개, 로컬 실행(`hugo server --buildDrafts`), 폴더 구조, 금지어 파일 만드는 법, 팀 추가 방법. 배포 섹션은 GitHub Pages 기준으로 쓴다.
6. 커밋 → `git push -u origin setup/public-repo` → `gh pr create`

### 완료 조건
- `git ls-files`에 `notes/`, `.private/`, `_workspace/`가 없다.
- `hugo --gc --minify`가 경고 없이 빌드된다.
- `hugo server --buildDrafts`에서 1주차 초안이 열리고, `/teams/<별칭>/` 페이지에 해당 글이 나온다.

---

## Phase 2. GitHub Pages 배포

**브랜치:** `setup/pages-deploy`

### 작업
1. `.github/workflows/deploy.yml`
   - 트리거: `main` push, `workflow_dispatch`
   - 권한: `contents: read`, `pages: write`, `id-token: write` (최소 권한)
   - 단계: checkout → Hugo 0.168.0 extended 설치(공식 릴리스 tarball) → `hugo --gc --minify` → `actions/upload-pages-artifact` → `actions/deploy-pages`
   - `concurrency: pages`로 동시 배포를 막는다.
2. `pr-check.yml` 보강: `--buildDrafts` 빌드 확인 + 이미지·영상 검사(Phase 3 규칙과 동일)
3. 사용하는 Actions는 GitHub 공식 액션만 쓰고, 커밋 SHA로 고정한다.
4. README에 사람이 직접 할 일을 적는다.
   - Settings → Pages → Source: GitHub Actions
   - Settings → Branches → `main` 보호: PR 필수, PR check 통과 필수, force push 금지

### 완료 조건
- main 머지 후 https://smartjy.github.io/future-ai-kids/ 가 열린다.
- `draft: true`인 글은 프로덕션에 나오지 않는다.

---

## Phase 3. 개인정보 보호 가드레일 (가장 중요)

**브랜치:** `setup/privacy-guard`

### 작업
1. `tools/privacy-check.sh` (로컬·CI 공용)
   - 금지어: `.private/names.txt`가 있으면 그 단어로 `content/`를 검색해 하나라도 나오면 실패 (CI에는 파일이 없으므로 로컬 전용). 팀 구분 없이 파일 하나로 관리한다.
   - 이미지 메타데이터: jpg/png/heic/webp에 GPS 정보가 있으면 실패
   - 크기: 이미지 2MB, 영상(mp4/webm) 3MB, GIF 3MB 초과 시 실패
   - 영상 오디오: mp4/webm에 오디오 트랙이 있으면 실패 (ffprobe)
   - 실패 메시지는 한국어로, 파일명과 해결 방법을 함께 출력
2. `tools/strip-metadata.sh`: `exiftool -all= -overwrite_original`로 글 폴더 이미지 메타데이터 일괄 제거
3. `.githooks/pre-commit`에서 `tools/privacy-check.sh` 실행. README에 `git config core.hooksPath .githooks` 안내
4. `pr-check.yml`에서도 `tools/privacy-check.sh` 실행
5. 서브 에이전트 `.claude/agents/privacy-reviewer.md` 작성 (아래 「서브 에이전트」 참고)
6. `CLAUDE.md` 개인정보 섹션 보강
   - 커밋 전에 반드시 `tools/privacy-check.sh`를 실행한다.
   - 메모에 실명이 있으면 글에는 「팀 별칭 + 연구원 A/B/C」로 바꿔 쓰고, 바꾼 사실은 PR 설명에만 남긴다. 실명 자체는 PR에도 쓰지 않는다.
   - 개인정보 커밋을 발견하면 추가 커밋으로 덮지 말고 즉시 멈추고 사람에게 보고한다.

### 완료 조건
- 금지어가 들어간 테스트 글, GPS가 남은 테스트 사진, 오디오가 있는 테스트 영상이 각각 커밋 단계에서 막힌다. (테스트 파일은 확인 후 커밋하지 않고 삭제)
- `privacy-reviewer`가 얼굴이 나온 테스트 이미지를 차단으로 보고한다.

---

## Phase 4. 수업 영상 클립 (MP4/GIF)

**브랜치:** `feature/video-clips`

### 영상 첨부 흐름
1. 원본 영상은 레포 밖 또는 `notes/`(gitignore)에만 둔다.
2. `tools/clip.sh`로 쓸 장면만 잘라 글 폴더에 결과물(mp4/gif/jpg)만 만든다.
3. 본문에 `{{</* clip src="app-demo.mp4" alt="퀴즈 앱이 점수를 올리는 장면" */>}}`를 넣는다.
4. 커밋 시 privacy-check, PR 전 privacy-reviewer가 검사한다.

### 작업
1. `tools/clip.sh`
   - 사용법: `./tools/clip.sh <원본> <시작 mm:ss> <길이(초)> <글 폴더> [이름] [--crop W:H:X:Y] [--blur W:H:X:Y ...] [--preview]`
   - 출력 1: `이름.mp4` — 가로 720px, H.264, 오디오 제거(`-an`), `-movflags +faststart`, 목표 2MB 이하
   - 출력 2: `이름.gif` — 가로 480px, 12fps, palettegen/paletteuse 2-pass (짧은 장면용)
   - 출력 3: `이름.jpg` — 첫 프레임 포스터 (메타데이터 제거)
   - 얼굴 가림 수동 옵션
     - `--crop W:H:X:Y`: 지정 영역만 남긴다.
     - `--blur W:H:X:Y`(여러 번 지정 가능): `split` + `crop` + `boxblur=20` + `overlay`로 고정 사각형 영역을 흐리게 한다.
     - 필터 순서: crop → blur → scale. mp4, gif, jpg 모두 같은 필터를 쓴다.
     - 옵션을 쓰면 "고정 영역만 가려집니다. 움직이는 얼굴은 가려지지 않으니 결과를 끝까지 확인하세요" 경고를 출력한다.
     - `--preview`: 시작 시점 한 프레임을 scratchpad(레포 밖)에 jpg로 저장해 좌표를 잡을 수 있게 한다.
   - 끝나면 `tools/privacy-check.sh`를 자동 실행한다.
2. Hugo shortcode `layouts/shortcodes/clip.html`
   - 출력: `<video autoplay loop muted playsinline preload="metadata" poster="...">`, 같은 폴더의 포스터를 자동으로 찾는다.
   - `.gif`면 `<img>`로 출력한다.
   - `alt` 필수, 없으면 빌드 경고(`warnf`)
3. `CLAUDE.md` 영상 규칙
   - 얼굴이 나오지 않는 영상만 쓴다. (위에서 내려다본 손·화면 구도, 화면 녹화)
   - blur는 보조 수단이다. 얼굴이 움직이며 나오는 장면은 쓰지 않는다.
   - 소리는 항상 제거한다.
   - 화면 속 계정 이름, 알림, 프로필 사진, 이름표, 유리·모니터 반사를 확인한다.
   - 4초 이하는 GIF, 그보다 길면 MP4를 쓴다.

### 완료 조건
- 샘플 화면 녹화로 `clip.sh`를 실행하면 3개 파일이 생기고, shortcode가 자동 재생·반복 영상으로 표시된다.
- `--blur`를 준 결과물에서 지정 영역이 흐리게 나온다.

---

## Phase 5. 주간 글쓰기 흐름

**브랜치:** `feature/weekly-flow`

### 작업
1. `archetypes/posts.md` 정리: 영상 shortcode 예시 주석 추가
2. 슬래시 명령 `.claude/commands/weekly-post.md`
   1. 수업 날짜, 이번 주 참여한 팀, 메모 위치(`notes/YYYY-MM-DD.md`, 한 파일 안 팀별 제목 또는 `notes/YYYY-MM-DD-<team-id>.md`)를 확인한다.
   2. `post/week-NN` 브랜치를 만든다.
   3. `hugo new content posts/YYYY-MM-DD-week-NN/index.md`로 글 폴더를 만든다.
   4. 메모를 바탕으로 CLAUDE.md 규칙에 맞춰 본문을 쓴다. (`draft: true`)
   5. **`/humanize-korean`으로 윤문한다.**
   6. 사진은 `tools/strip-metadata.sh`, 영상은 `tools/clip.sh`로 처리한다.
   7. `tools/privacy-check.sh`를 통과시킨다.
   8. 네이버 요약본 `naver.md`를 쓰고 `/humanize-korean`으로 윤문한다. (Phase 6)
   9. **`privacy-reviewer` 에이전트로 검토한다.** 차단이면 고치고 다시 검토한다.
   10. PR을 연다. 본문: 요약, 참여 팀, 사용한 미디어 목록, 개인정보 처리 내역(실명 없이), 네이버 요약본 위치
   11. 사람이 로컬(`hugo server --buildDrafts`)에서 확인한다.
   12. **최종 발행 전 `/humanize-korean`을 한 번 더 실행**하고, `privacy-reviewer`를 다시 돌린 뒤 `draft: false`로 바꿔 머지한다.

### 완료 조건
- `/weekly-post`로 샘플 메모에서 2팀이 함께 들어간 2주차 초안 PR이 만들어진다.

---

## Phase 6. 네이버 블로그 동시 운영

**브랜치:** `feature/naver-summary`

### 작업
1. 글 폴더에 `naver.md`를 둔다. `hugo.yaml`에 `ignoreFiles: ['naver\.md$']`를 추가해 사이트에 나오지 않게 한다.
2. 템플릿
   - 제목: GitHub 글과 같다.
   - 본문: 핵심 3~4줄(공통), 팀마다 「연구원들의 한마디」 1개, 대표 이미지 1장 위치 표시
   - 마지막 줄: `전체 기록 보기 → https://smartjy.github.io/future-ai-kids/posts/<slug>/`
3. `CLAUDE.md` 규칙
   - 네이버에는 전문을 복사하지 않는다. (유사 문서로 판단되면 노출이 줄어든다)
   - GitHub에 먼저 발행한 뒤 네이버에 올린다.
   - 이미지는 네이버 에디터에서 직접 업로드한다.
   - `naver.md`도 작성 후와 업로드 전에 `/humanize-korean`을 실행한다.

### 완료 조건
- 2주차 PR에 `naver.md`가 포함되고, 빌드 결과(`public/`)에는 들어가지 않는다.

---

## 문체 다듬기: humanize-korean

- **적용 시점:** ① 초안 작성 직후 ② 최종 발행(`draft: false`) 직전. `naver.md`도 같다.
- **바꾸지 않는 것:** front matter, shortcode, 이미지 경로, 링크, 팀 별칭, 「연구원 A」 호칭. 윤문 뒤 `git diff`로 확인하고 깨졌으면 되돌린다.
- **중간 산출물:** 스킬이 만드는 `_workspace/`는 `.gitignore`로 제외한다.
- 윤문 뒤에는 privacy-check를 다시 실행한다.

## 서브 에이전트

새로 만드는 것은 `privacy-reviewer` 1개다.

| 에이전트 | 여부 | 역할 |
|---|---|---|
| `privacy-reviewer` | 새로 작성 (Phase 3) | 글을 쓴 세션과 분리된 컨텍스트에서 개인정보를 독립 검토 |
| humanize 계열 | 플러그인 것 사용 | `/humanize-korean`이 내부에서 호출 |
| 글 작성·네이버 요약 | 만들지 않음 | `/weekly-post`를 메인 세션에서 실행 (메모와 대화 맥락이 필요) |

### `privacy-reviewer` 설계
- 도구: `Read`, `Grep`, `Glob`, `Bash`. Edit/Write는 주지 않는다. (보고만 하고 고치지 않는다)
- 입력: `git diff main --name-only`의 변경 파일
- 검사
  1. 텍스트: 금지어 파일이 못 잡는 실명처럼 보이는 이름, 학교·반·동네, 연락처, 특정 아이를 알아볼 수 있는 묘사
  2. 이미지: 포스터와 사진을 직접 열어 얼굴, 이름표, 교복·학교 로고, 화면 속 계정명·알림, 반사 확인
  3. 영상: ffmpeg으로 1초에 1프레임씩 scratchpad에 뽑아 같은 항목 확인 (blur 영역 밖 얼굴 포함)
  4. `tools/privacy-check.sh` 결과
- 출력: 통과/차단, 파일·프레임 시점·이유·해결 방법. 실명은 보고서에도 쓰지 않는다.
- 호출: PR을 열기 전, `draft: false`로 바꾸기 전
- 팀이 많아져 글이 길어지면 팀별 섹션 작성을 병렬 에이전트로 나누는 것을 그때 검토한다.

## 하지 않는 것 (범위 밖)
- 네이버·Medium 자동 업로드 (네이버는 글쓰기 API가 없고, Medium은 신규 API 연동이 막혀 있다)
- 얼굴 자동 블러 (누락 위험 때문에 촬영 단계에서 얼굴을 빼고, 고정 영역 수동 blur만 보조로 쓴다)
- 댓글, 방문자 분석 등 외부 스크립트 (필요해지면 별도 검토)

## 진행 체크리스트
- [ ] Phase 1 레포 초기화와 퍼블릭 대응
- [ ] Phase 2 GitHub Pages 배포
- [ ] Phase 3 개인정보 보호 가드레일
- [ ] Phase 4 영상 클립 도구
- [ ] Phase 5 주간 글쓰기 흐름
- [ ] Phase 6 네이버 요약본
