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

자동 검사(`tools/privacy-check.sh`, pre-commit hook)는 Phase 3에서 추가됩니다.

## 배포

GitHub Pages(GitHub Actions)로 배포합니다. `main`에 머지되면 자동으로 올라갑니다. 워크플로와 저장소 설정 방법은 Phase 2에서 추가됩니다.
