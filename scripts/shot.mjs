// 截圖工具種子 — 讓 AI「看」頁面：導航 → (可選登入) → 截圖 PNG，AI 再讀圖判讀。
// 對應 docs/frontend-design-principles.md A10（看畫面，不只讀 code，鐵則）。
//
// 移植到專案：
//   1. 放到 <repo>/frontend/scripts/shot.mjs（或前端根目錄）。
//   2. 需 playwright（前端通常已有 E2E 依賴；否則 `npm i -D playwright`）。
//   3. 改 DEFAULT_BASE / 登入流程（loginFlow）對齊你的 dev server 與 auth：
//      - test-login 端點路徑、登入後跳轉的 URL pattern、localStorage token key。
//
// 用法：
//   node scripts/shot.mjs --url /demo/page --out /tmp/x.png
//   node scripts/shot.mjs --url /dashboard --login --mobile --out /tmp/x.png
//   node scripts/shot.mjs --url /bill --login --base http://localhost:5173 --out /tmp/x.png
//
// 旗標：--url <path|fullURL> / --out <png> / --base <url> / --login / --mobile /
//       --full（整頁）/ --headed（顯示視窗）/ --wait <ms>

import { chromium } from 'playwright';

const DEFAULT_BASE = 'http://localhost:8010'; // ← 改成你的 dev server
const LOGIN_PATH = '/test-login'; // ← 改成你的測試登入端點（需 dev 環境開啟）
const POST_LOGIN_URL = /\/(dashboard|home|source|agents|clients)/; // ← 登入後跳轉

const args = process.argv.slice(2);
const get = (k, d = null) => {
  const i = args.indexOf(`--${k}`);
  if (i === -1) return d;
  const v = args[i + 1];
  return v && !v.startsWith('--') ? v : true;
};
const has = (k) => args.includes(`--${k}`);

const base = get('base', DEFAULT_BASE);
const url = get('url', '/');
const out = get('out', '/tmp/shot.png');
const fullUrl = String(url).startsWith('http') ? url : base.replace(/\/$/, '') + url;
const viewport = has('mobile')
  ? { width: 390, height: 844 }
  : { width: 1440, height: 900 };
const waitMs = parseInt(get('wait', '1500'), 10);

async function launch() {
  // 優先用本機 Chrome；沒裝退回 Playwright chromium
  try {
    return await chromium.launch({ channel: 'chrome', headless: !has('headed') });
  } catch {
    return await chromium.launch({ headless: !has('headed') });
  }
}

async function loginFlow(page) {
  await page.goto(base.replace(/\/$/, '') + LOGIN_PATH, {
    waitUntil: 'domcontentloaded',
  });
  await page.waitForURL(POST_LOGIN_URL, { timeout: 30000 }).catch(() => {});
  await page.waitForTimeout(2000);
}

(async () => {
  const browser = await launch();
  const ctx = await browser.newContext({
    viewport,
    deviceScaleFactor: 2,
    locale: 'zh-TW',
  });
  const page = await ctx.newPage();
  try {
    if (has('login')) await loginFlow(page);
    await page.goto(fullUrl, { waitUntil: 'networkidle', timeout: 45000 });
    await page.waitForTimeout(waitMs);
    await page.screenshot({ path: out, fullPage: has('full') });
    console.log(`OK ${fullUrl} -> ${out} (${viewport.width}x${viewport.height})`);
  } catch (e) {
    console.error('SHOT FAILED:', e.message);
    process.exitCode = 1;
  } finally {
    await browser.close();
  }
})();
