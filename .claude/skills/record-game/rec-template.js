// 게임 화면 녹화 템플릿 — /record-game 스킬에서 쓴다.
// 이 파일을 _workspace/rec/<team-id>-rec.js로 복사한 뒤 「바꿀 곳」만 고쳐서 _workspace/rec 안에서 실행한다.
//   cd _workspace/rec && node <team-id>-rec.js
// playwright-core(Apache-2.0)는 _workspace/rec/node_modules에 이미 있다. 새 의존성은 설치하지 않는다.
// 녹화 결과: _workspace/rec/out-<team-id>/<임의 이름>.webm (마지막 줄에 경로를 찍는다)
const { chromium } = require('playwright-core');
const path = require('path');

// ── 바꿀 곳 1: 기본 설정 ─────────────────────────────
const TEAM = 'teamX';                                          // 팀 id
const GAME = path.resolve(__dirname, '../game', TEAM, 'bot.html'); // 읽기용 훅을 더한 로컬 사본
const VIEW = { width: 1280, height: 720 };                     // 녹화 크기 (게임이 잘리지 않게)
const MAX_SEC = 45;                                            // 플레이 최대 시간
const WEBGL = false;                                           // 3D(three.js 등) 게임이면 true

// ── 바꿀 곳 2: 게임 상태 읽기 ────────────────────────
// bot.html에 더한 훅(예: window.__game = game)으로 필요한 값만 꺼낸다. 게임 로직은 바꾸지 않는다.
const readState = () => {
  const g = window.__game;
  return g ? { state: g.state } : null;
};

// ── 바꿀 곳 3: 시작 화면 → 플레이 시작 ────────────────
async function start(page) {
  // 예: 닉네임을 넣어야 하면 실제 사람 이름이 아닌 값을 쓴다. (화면에 나온다)
  // await page.fill('#nickInput', '테스트영웅');
  // await page.click('#startBtn');
}

// ── 바꿀 곳 4: 한 번의 조작 ──────────────────────────
// 상태를 보고 한 번 조작한다. 'stop'을 돌려주면 녹화를 마친다.
async function step(page, s, keys) {
  if (!s) return;
  if (s.state === 'win' || s.state === 'lose') return 'stop';
  // 예: await keys.hold('ArrowLeft', true); await page.keyboard.press('Space');
}

// ── 아래는 그대로 둔다 ───────────────────────────────
(async () => {
  const args = WEBGL ? ['--use-angle=swiftshader', '--enable-unsafe-swiftshader'] : [];
  const browser = await chromium.launch({ channel: 'chrome', headless: true, args });
  const ctx = await browser.newContext({ viewport: VIEW, recordVideo: { dir: path.resolve(__dirname, 'out-' + TEAM), size: VIEW } });
  const page = await ctx.newPage();
  page.on('pageerror', e => console.log('pageerror', e.message));
  const t0 = Date.now(); const mark = m => console.log(((Date.now() - t0) / 1000).toFixed(1) + 's', m);
  const held = new Set();
  const keys = {
    hold: async (k, on) => {
      if (on && !held.has(k)) { held.add(k); await page.keyboard.down(k); }
      if (!on && held.has(k)) { held.delete(k); await page.keyboard.up(k); }
    },
    releaseAll: async () => { for (const k of [...held]) await keys.hold(k, false); },
  };
  await page.goto('file://' + GAME);
  await page.waitForTimeout(2000); mark('loaded');
  await start(page); mark('play');
  let last = '';
  const end = Date.now() + MAX_SEC * 1000;
  while (Date.now() < end) {
    const s = await page.evaluate(readState);
    const tag = JSON.stringify(s && s.state);
    if (tag !== last) { mark('state ' + tag); last = tag; }
    if (await step(page, s, keys) === 'stop') { await keys.releaseAll(); await page.waitForTimeout(2500); break; }
    await page.waitForTimeout(40);
  }
  await keys.releaseAll(); mark('end');
  const v = await page.video().path();
  await ctx.close(); await browser.close();
  console.log('video', v);
})();
