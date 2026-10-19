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
