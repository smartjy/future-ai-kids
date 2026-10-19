# future-ai-kids

**미래AI육성 캠프** — AI with our kids, 아이들과 AI 기록

초등학생 연구원들과 매주 진행하는 AI 수업을 기록하는 블로그입니다.
주소: https://smartjy.github.io/future-ai-kids/

- 생성기: [Hugo](https://gohugo.io/) (Apache-2.0) extended 0.168.0
- 테마: [PaperMod](https://github.com/adityatelange/hugo-PaperMod) (MIT), `themes/PaperMod`에 벤더링 (출처 커밋은 `themes/PaperMod/VENDORED_FROM`)

## 로컬에서 보기

```sh
brew install hugo
hugo server --buildDrafts   # 초안 포함 미리보기 → http://localhost:1313/future-ai-kids/
hugo --gc --minify          # 배포용 빌드 (public/)
```

## 폴더 구조

```
content/posts/YYYY-MM-DD-week-NN/index.md   주간 글 (사진·영상도 같은 폴더)
data/teams.yaml                              팀 목록 (별칭)
archetypes/posts.md                          새 글 템플릿
notes/                                       수업 메모 원본 — 로컬 전용, 커밋 안 됨
.private/names.txt                           금지어 목록 — 로컬 전용, 커밋 안 됨
```

## 새 글 쓰기

```sh
hugo new content posts/2026-10-24-week-02/index.md
```

`data/teams.yaml`에서 `active: true`인 팀마다 섹션이 자동으로 들어갑니다. 그 주에 쉰 팀은 지워 주세요.

## 팀 추가

`data/teams.yaml`에 항목을 하나 추가합니다. `name`에는 아이들이 정한 별칭만 쓰고, 학교명·동네·반 이름은 쓰지 않습니다.
팀별 글 모음은 `/teams/<별칭>/`에서 볼 수 있습니다.

## 영상 넣기

원본 영상은 `notes/`(커밋 안 됨) 또는 레포 밖에 둡니다. 글 폴더에는 잘라낸 결과물만 넣습니다.
얼굴이 나오지 않는 장면(위에서 내려다본 손·화면, 화면 녹화)만 고르세요. 자세한 규칙은 `CLAUDE.md`의 「영상 규칙」에 있습니다.

1. 쓸 장면을 잘라 글 폴더에 mp4/gif/jpg를 만듭니다. (`brew install ffmpeg` 필요)
   ```sh
   ./tools/clip.sh <원본> <시작 mm:ss> <길이(초)> <글 폴더> [이름] [--crop W:H:X:Y] [--blur W:H:X:Y ...] [--preview]
   ./tools/clip.sh "notes/1주차 수업.mp4" 01:05 6 content/posts/2026-10-24-week-02 app-demo
   ```
   - `app-demo.mp4`: 가로 720px, 소리 없음, 2MB 이하가 목표
   - `app-demo.gif`: 가로 480px, 12fps (4초 이하 짧은 장면용)
   - `app-demo.jpg`: 첫 프레임 포스터 (메타데이터 제거)
   - 4초 이하는 gif, 그보다 길면 mp4를 쓰고 안 쓰는 파일은 지웁니다.
2. 본문에 shortcode를 넣습니다. `alt`는 필수이고, `caption`은 선택입니다.
   ```
   {{< clip src="app-demo.mp4" alt="퀴즈 앱이 점수를 올리는 장면" caption="점수가 오르는 순간" >}}
   ```
   mp4는 자동 재생·반복·소리 없음으로 나오고, 같은 이름의 jpg가 포스터가 됩니다. gif는 이미지로 나옵니다.

### 얼굴·이름표 가리기 (crop/blur)

1. `--preview`로 시작 프레임 한 장만 뽑아 봅니다. 레포 밖 임시 폴더에 저장되고, 원본 크기가 함께 출력됩니다.
   이미지 뷰어(미리보기 앱 등)에서 가릴 영역의 왼쪽 위 좌표(X, Y)와 가로·세로(W, H)를 잽니다.
   ```sh
   ./tools/clip.sh "notes/1주차 수업.mp4" 01:05 6 content/posts/2026-10-24-week-02 app-demo --preview
   ```
2. `--crop W:H:X:Y`로 필요한 영역만 남기고, `--blur W:H:X:Y`(여러 번 가능)로 사각형을 흐리게 합니다.
   **blur 좌표는 crop을 적용한 뒤의 화면 기준**입니다. crop을 쓸 때는 crop만 넣고 `--preview`를 한 번 더 돌려 좌표를 다시 잡으세요.
   ```sh
   ./tools/clip.sh "notes/1주차 수업.mp4" 01:05 6 content/posts/2026-10-24-week-02 app-demo \
     --crop 1280:600:0:120 --blur 200:80:1000:20 --preview
   ```
3. 좌표가 맞으면 `--preview`를 빼고 다시 실행합니다.
4. blur는 고정된 사각형만 가립니다. 결과 영상을 끝까지 재생해 움직이는 얼굴, 이름표, 계정 이름, 알림, 화면 반사가 없는지 확인하세요. 얼굴이 움직이며 나오는 장면은 쓰지 않습니다.

## 개인정보 (퍼블릭 레포)

레포에 올라간 것은 히스토리까지 전부 공개됩니다.

1. 금지어 파일을 만듭니다. 아이들 실명, 학교명, 반, 동네 이름을 한 줄에 하나씩 적습니다.
   ```sh
   mkdir -p .private && cp .private.example/names.txt .private/names.txt
   ```
2. 수업 메모와 원본 영상은 `notes/` 또는 레포 밖에 둡니다.
3. 실수로 개인정보를 커밋했다면 추가 커밋으로 덮지 말고 바로 작업을 멈추세요. 히스토리 정리가 필요합니다.

### 자동 검사 설정 (처음 한 번)

```sh
brew install exiftool ffmpeg              # 사진 메타데이터·영상 검사 도구
git config core.hooksPath .githooks       # 커밋할 때마다 개인정보 검사 실행
```

### 검사 도구

```sh
tools/privacy-check.sh                    # content/ 검사 (금지어는 data/도 함께)
tools/privacy-check.sh content/posts/2026-10-24-week-02   # 특정 글 폴더만
tools/strip-metadata.sh content/posts/2026-10-24-week-02  # 사진 GPS 등 메타데이터 제거
```

`privacy-check.sh`가 막는 것:

- 금지어(`.private/names.txt`)가 글에 들어 있음 — 로컬 전용, CI에서는 건너뜁니다. 일치한 단어는 출력하지 않고 위치만 알려 줍니다.
- 사진(jpg/png/heic/webp)에 GPS 정보가 남아 있음 → `tools/strip-metadata.sh <폴더>`
- 이미지 2MB, 영상(mp4/webm) 3MB, GIF 3MB 초과
- 영상에 오디오 트랙이 있음 → `tools/clip.sh`로 다시 변환

PR에서도 같은 검사(금지어 제외)가 돌아갑니다. 사람 눈으로 보는 검토(얼굴, 이름표, 화면 속 계정명 등)는 Claude Code 서브 에이전트 `privacy-reviewer`가 맡습니다.

## 배포

GitHub Pages(GitHub Actions)로 배포합니다. `main`에 머지되면 `.github/workflows/deploy.yml`이 사이트를 빌드해 https://smartjy.github.io/future-ai-kids/ 에 올립니다.

- 빌드: Hugo 0.168.0 extended (공식 릴리스 tarball), `hugo --gc --minify`
- `draft: true`인 글은 배포 빌드에 들어가지 않습니다. 초안은 PR check(`--buildDrafts`)에서만 빌드를 확인합니다.
- 다시 배포하려면 Actions 탭 → **Deploy to GitHub Pages** → **Run workflow**를 누릅니다.
- 사용하는 Actions는 GitHub 공식 액션만 쓰고 커밋 SHA로 고정합니다. 버전을 올릴 때는 태그와 SHA를 함께 바꿉니다.

### 저장소 설정 (사람이 한 번 직접)

1. **Settings → Pages → Build and deployment → Source: GitHub Actions**
2. **Settings → Branches → Add branch protection rule** (또는 Rulesets)에서 `main`을 보호합니다.
   - Require a pull request before merging (PR 필수)
   - Require status checks to pass before merging → `build` (PR check) 선택
   - Allow force pushes 끄기 (force push 금지)
   - Allow deletions 끄기
