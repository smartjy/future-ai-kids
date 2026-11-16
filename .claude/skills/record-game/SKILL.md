---
name: record-game
description: 학생 팀이 AI 앱에서 만든 게임(아티팩트)을 로컬 사본으로 실행해 자동 조작으로 화면을 녹화하고, 글에 넣을 클립·대표 이미지·클립 프레임까지 만든다. 그 주 게임 화면 녹화가 notes/에 없을 때 /draft-post가 부른다. 「게임 영상 녹화해 줘」, 「게임 영상 추가해 줘」, /record-game에 사용한다.
argument-hint: "<수업 날짜 YYYY-MM-DD> <team-id> [아티팩트 URL]"
allowed-tools: Read, Grep, Glob, Edit, Write, Artifact, Bash(ls:*), Bash(cp:*), Bash(mkdir:*), Bash(node:*), Bash(ffmpeg:*), Bash(ffprobe:*), Bash(python3:*), Bash(./tools/clip.sh:*), Bash(./tools/frames.sh:*), Bash(./tools/strip-metadata.sh:*), Bash(./tools/privacy-check.sh:*)
---

# /record-game — 게임 화면 녹화

학생들이 AI 앱에서 만든 게임을 세션이 실행해 녹화하고, 기록 글에 넣을 결과물을 만든다.
녹화는 **수업이 끝난 뒤** 세션이 한 것이다. 글과 메모에 그렇게 밝히고, 녹화하며 고른 행동을 수업 내용처럼 쓰지 않는다.
시작하기 전에 `CLAUDE.md`의 「영상 규칙」을 읽는다. 이 레포는 퍼블릭이다.

인자: `$ARGUMENTS` (수업 날짜, 팀 id, 있으면 아티팩트 URL)

## 1. 게임 받기

1. 사람에게 그 주 수업이 끝난 시점의 최신 게임 링크(아티팩트 URL)나 HTML 파일을 받는다. 링크를 모르면 `Artifact` 도구 `list`로 최근 수정된 아티팩트를 보여 주고 어느 것인지 확인받는다.
2. `Artifact` 도구 `read`로 받아 저장된 HTML을 `_workspace/game/<team-id>/index.html`로 복사한다. (같은 팀의 다른 게임이면 `<team-id>-<짧은 이름>/`)
3. 게임 파일을 훑어 다음을 확인하고 팀 메모에 적을 준비를 한다.
   - 외부에서 불러오는 것: `<script src>`, 폰트. **게임이 원래 불러오는 CDN 라이브러리·웹 폰트 말고는 외부 네트워크를 쓰지 않는다.**
   - 내장 이미지(`data:image`, png·jpg 참조) 여부. 사진이 들어 있으면 얼굴·이름표가 없는지 먼저 보고, 있으면 멈추고 사람에게 알린다.
   - 공유 저장소(랭킹 등)는 로컬 사본에서 연결되지 않는다. 다른 사람의 닉네임이 화면에 나오지 않는지 녹화 뒤 확인한다.

## 2. 녹화 준비

1. 상태를 읽을 수 있게 사본 `bot.html`에만 읽기용 훅을 한 줄 더한다. (예: 게임 상태 객체를 만든 바로 뒤에 `window.__game = game;`) **게임 로직은 바꾸지 않는다.** `index.html`은 그대로 둔다.
2. 이 스킬 폴더의 `rec-template.js`를 `_workspace/rec/<team-id>-rec.js`로 복사하고 「바꿀 곳」 네 군데만 고친다.
   - 상태 읽기, 시작 화면 넘기기, 한 번의 조작(목표를 향해 돌기·이동·공격 등)
   - 닉네임 입력이 있으면 실제 사람 이름이 아닌 값을 쓴다. 이 값은 팀 메모에 적는다.
   - 3D(three.js 등) 게임이면 `WEBGL = true`
3. `_workspace/rec/node_modules/playwright-core`가 없으면 설치하지 말고 사람에게 알린다.

## 3. 녹화

```bash
cd _workspace/rec && node <team-id>-rec.js
```

- 게임의 핵심 흐름(시작 → 플레이 → 클리어나 결과 화면)이 나오게 한다. 조작이 서툴러 원하는 장면이 안 나오면 「한 번의 조작」을 고쳐 다시 녹화한다. (예: 탄약이 떨어졌는데 계속 던져 「없어요」 문구가 쌓이면 남은 수를 보고 던지게 고친다)
- 녹화본을 `notes/YYYY-MM-DD/media/<team-id>-game.webm`으로 옮긴다. 원본은 레포에 넣지 않는다.
- 원본에서 프레임을 뽑아(`./tools/frames.sh <원본> _workspace/frames/<team-id>-raw 2`) 어느 시간에 어떤 장면이 있는지 본다.

## 4. 클립과 대표 이미지

```bash
./tools/clip.sh notes/YYYY-MM-DD/media/<team-id>-game.webm <시작 mm:ss> <길이(초)> content/posts/YYYY-MM-DD-week-NN <영문-이름> [--crop W:H:X:Y]
```

- 화면 녹화는 `--crop`으로 게임 영역만 남긴다. 페이지 제목·설명 글, 브라우저 UI가 남지 않게 한다.
- 4초보다 긴 장면은 mp4만 생긴다. (gif는 4초 이하일 때만)
- 대표 이미지는 장면이 잘 보이는 프레임을 따로 jpg로 뽑아 글 폴더에 두고 `./tools/strip-metadata.sh <글 폴더>`를 돌린다. `clip.sh`가 만든 첫 프레임 jpg는 영상 포스터다.

## 5. 클립 프레임 확인 — 글은 이 프레임으로 쓴다

```bash
./tools/frames.sh content/posts/YYYY-MM-DD-week-NN/<영문-이름>.mp4 _workspace/frames/<team-id>-clip 1
```

- **글의 영상 설명, `alt`, 사실 검증은 원본이 아니라 이 클립 프레임으로 한다.** 원본 녹화로 쓰면 클립에 없는 장면을 쓰게 된다. (2026-11-14 Bsil, 11-15 Doumy에서 fact-checker가 잡았다)
- 글에 쓰려는 장면(클리어 화면, 공격 장면 등)이 클립에 모두 들어 있는지 마지막 프레임까지 본다. 빠졌으면 4단계에서 구간을 다시 잡는다.
- 모든 프레임에서 얼굴, 이름표, 계정명, 알림, 반사, 다른 사람의 닉네임(랭킹 화면 등)이 없는지 본다.

## 6. 팀 메모에 녹화 경위 적기

팀 메모(`notes/YYYY-MM-DD/<team-id>.md`)에 적는다. `fact-checker`가 이 기록으로 영상과 수업 내용을 구분한다.

```markdown
## 영상
- media/<team-id>-game.webm — 사람 지시로 수업 뒤 AI 앱에 있던 최신 게임을 세션이 로컬에서 실행해 자동 조작으로 녹화
- 녹화한 쪽이 고른 것 (수업 내용 아님): 맵 ○○, 닉네임 「○○」, 주인공 ○○ 등
- 글에 쓴 클립: <영문-이름>.mp4 = 원본 mm:ss부터 N초. 클립 프레임 _workspace/frames/<team-id>-clip/
- 게임 파일 확인: 내장 사진 없음 / 외부는 ○○ CDN·폰트뿐 / 공유 랭킹은 로컬에서 연결 안 됨
```

## 7. 넘길 것

`/draft-post`(또는 사람)에게 다음을 알린다.

- 글 폴더의 결과물: 클립 mp4·포스터 jpg·대표 이미지 jpg 이름
- 클립 프레임 폴더와 각 장면의 시간(예: 「0~5초 돌 던지기, 20초 뿅망치, 22초 기절!, 30초 YOU WIN!」)
- 녹화한 쪽이 고른 것 목록

## 멈춰야 할 때

- 게임 파일에 사진이 들어 있고 얼굴·이름표·학교 로고가 보일 때
- 녹화 화면에 다른 사람의 닉네임이나 계정명이 나올 때 (그 구간은 클립에 넣지 않는다)
- `playwright-core`나 `ffmpeg`가 없을 때 (설치하지 말고 알린다)
