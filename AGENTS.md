This file provides guidance to AI coding assistants when working with code in this repository.

## Project Architecture

> 依專案改寫。範例：
- Database schema is defined in `[path]`
- Migration files are in `[path]`
- Files in `[path]` are mappings to the database tables

## Baselines (read before writing code)

- **Security floor** — [`docs/security-baseline.md`](docs/security-baseline.md): stack-agnostic, P0 from day one.
- **Performance floor** — [`docs/performance-baseline.md`](docs/performance-baseline.md): its twin. Write §0 (p95 target / payload cap / outbound-call cap) before optimising anything.
- **Stack attachment** — `docs/stack-rules/<stack>.md`: what those two floors look like *in this stack*.
  No attachment for your stack yet → generate one against the fixed 16 dimensions in
  [`docs/stack-rules/_generator.md`](docs/stack-rules/_generator.md), have a human review it, and add
  its filename to `STACK_FILES` in `setup.sh` **in the same commit**.
- Every rule in an attachment must name its enforcement point (config flag / lint rule / CI job / grep
  guard). No enforcement point → it is a P2 convention, not a P0. A rule without a check always drifts.

## Development Workflow

**ALWAYS follow these steps after making code changes:**

### Backend Code Changes

1. **Format** — [`gofmt -w` / `cargo fmt` / `ruff format` / 依語言]
2. **Lint** — [`golangci-lint run` / `cargo clippy` / `ruff check`]
   - **Important**: Run lint repeatedly until 0 issues (lint tools have max-issues limits)
3. **Auto-fix** — [`--fix` flag if supported]
4. **Test** — Run relevant tests before committing
5. **Build** — Confirm production-grade build still succeeds
6. **Tidy deps** — After dep upgrades, run [`go mod tidy` / `cargo update --workspace` / etc]

### Frontend Code Changes

1. **Fix** — [`pnpm fix` / `npm run fix`] auto-fix ESLint + Biome / Prettier
2. **Check** — [`pnpm check`] validate without modifying (for CI)
3. **Type check** — [`pnpm type-check`]
4. **Test** — [`pnpm test`]

### Proto / API Schema Changes

1. **Format** — [`buf format -w proto`]
2. **Lint** — [`buf lint proto`]
3. **Generate** — [`cd proto && buf generate`]
4. **Commit generated files** alongside the source change

## Build/Test Commands

> 依專案調整。範例：

### Backend

```bash
# Build
[build command]

# Run single test
[test runner with single-test syntax]

# Lint
[lint command]
```

### Frontend

```bash
pnpm --dir frontend i
pnpm --dir frontend dev
pnpm --dir frontend fix
pnpm --dir frontend check
pnpm --dir frontend type-check
pnpm --dir frontend test
```

### Database

```bash
# Connect to local dev DB
[psql / mysql / etc command]
```

## Code Style

### General

- Follow Google style guides for all languages
- Write clean, minimal code; fewer lines is better
- Prioritize simplicity for effective and maintainable software
- Only include comments that are essential to understanding functionality or convey non-obvious information

### Naming

- Use American English
- Avoid plurals like "xxxList"

### Imports

- Use organized imports (sorted by import path)

### Formatting

- Use linting/formatting tools before committing

### Frontend / UI design

- 任何前端產出（mockup / 元件 / 版面 / 樣式）動手前先過 [`docs/frontend-design-principles.md`](docs/frontend-design-principles.md)：**§A 普世核心**（刻意 > 出廠預設、token、a11y、動效、先研究、全狀態、響應式、複用、文案）一律適用、**§C 設計流程迴圈**動手前先跑；**§B 美學 profile** 每專案挑一個（預設 `modern-SaaS-craft`）。
- 元件走語意 design token、禁硬編 hex；spacing 用 `gap-*`。產出後自問「這是不是出廠預設樣 / 有沒有貼品牌與 profile？」
- **CSS specificity 陷阱**：type 選擇器（`.section`）與元素 / 類別選擇器（`.cta`）的 padding / margin 容易互相抵銷，section 之間尤其常見 —— 寫樣式時留意特異度，別讓規則彼此取消。

### Error Handling

- Be explicit but concise about error cases

## Pull Request Guidelines

**Before running `gh pr create`, walk through [`docs/pre-pr-checklist.md`](docs/pre-pr-checklist.md).**

- **Code Review** — Follow [Google's Code Review Guideline](https://google.github.io/eng-practices/)
- **Author Responsibility** — Authors drive discussions, resolve comments, merge promptly
- **Description** — Clearly describe what the PR changes and why
- **Testing** — Include information about how the changes were tested

## Common Lint Rules

> 依專案語言調整。Go example:

- **Unused Parameters** — Prefix unused parameters with underscore
- **Modern Go Conventions** — Use `any` instead of `interface{}`
- **Confusing Naming** — Avoid similar names differing only by capitalization
- **Identical Branches** — Don't use if-else branches with identical code
- **Function Receivers** — Don't create unnecessary receivers
- **Proper Import Ordering** — Maintain correct grouping
- **Consistency** — Keep function signatures, naming, and patterns consistent

## Miscellaneous

> 把專案特有的「踩坑警告」放這裡。範例：
> - The database JSONB columns store JSON marshalled by `protojson.Marshal` in Go code, which produces camelCase keys (`task_run` becomes `taskRun`)
> - When modifying multiple files, run modifications in parallel whenever possible

---

# 通用鐵則(2026-09 從一個跑了三個月的真實專案抽取;每條都付過代價)

> 這一節**不依專案技術棧**,新專案原樣可用。專案特定的規則寫在上面各節的方括號裡。

## 研究與查證

### 深度研究 = 五站
① **自家 repo**(上游 design doc 與 schema 常已裁定過 —— 巨人的第一站是自己)
② **自己的相依套件**(讀 `.d.ts` / 原始碼,能力常已內建)
③ **競品**(一手逐字 + 出處 + 查證日;「文件沒寫」≠「沒有」,只能標待驗證)
④ **主管機關法規**(合規敏感模組必查一手條文 —— 法規不是背景知識,是會改架構的一手來源)
⑤ **第一次使用**:一個沒用過的人打開這個功能,知道下一步要做什麼嗎?
   (入口找得到?開場說了可以做什麼?**要填的東西他知道要填什麼嗎** —— 空白輸入框是對新手最難的介面?
   失敗是產品的責任還是叫他再試一次?產出打開就看得懂嗎?)

### 「我方沒有 X」也要附查法
寫下「沒有 X / 只有 Y」時,同一句話附上怎麼查的(哪個 grep、哪個檔)。
一輪七次「前提是錯的」全靠動手前對碼抓到 —— 那是習慣,把它變成格式。

### 判「查無」要兩種查法交叉
精確名 + 寬鬆字根(`grep -rli`)。兩者不一致,答案永遠是後者。
🔴 **兩種查法問同一個人不算兩種**:拿競品的詞查自己的 repo,十二格錯十格 ——
先弄清楚那個功能**是什麼**,再用自己的概念找。判準:下「沒有」之前,
先講得出「那我們是怎麼做這件事的」;講不出代表還沒懂,不是沒有。
兩種查法都回 0 且很整齊時,**更警覺不是更放心**。

### 代理指標的輸出不是答案
規則/腳本量出來的結論,報出去之前先抽樣看實際檔案。
只回報一筆結果的檢查特別可疑。FMEA 的每一條先問「這個操作真的存在嗎」。

### 提建議前先量分母
「該做一支守衛/該統一某個東西」—— 先數分母。分母是個位數時,答案通常是「靠既有機制」。

### 宣稱「差異化 / 向上設計」要同時過三條
① 對手**明確停在那裡**(一手逐字依據,「文件沒寫」只能標待驗證,不得當硬差異化)
② 你的**架構**讓你過得去(地基不同,不是多寫幾行 —— 後者對手隨時追上)
③ 對**使用者的真實痛**有意義(不是對「比對手炫」有意義)。
缺一降級為 parity。「對手沒有 X」是風險最高的句型 —— 一個專案的整條差異化論述
曾建立在「競品 0 AI」上,一查全有。

### 在產出物裡標注違規 ≠ 沒有違規
mockup / 元件 / 範例裡寫「這是本稿的簡化」再加註解,**比單純忘記更糟** ——
它讓違規看起來已處理,而實作的人看的是畫面不是註解。兩條路:修好,或整段拿掉
並在框外說明。⚠️ 與「誠實標注邊界」不衝突:「這段我沒做」該標;
「這段我做錯了但先這樣」不該留。

### 研究要可回查
出貨功能的 design doc 附**可點的出處連結 + 逐字引用 + 查證日**。
查不到的研究,價值有一半(日後重新查證)已經沒了。
⚠️ 檢查只能盯格式盯不了「有沒有做」—— 偵測「研究強度」只會產生假陰性
(曾把修掉三個 P0 資安漏洞的研究判成「沒做研究」)。

## 交付

### 全稱詞 → 差距表
任務含「100% / 全部 / 所有 / 不要殘留」時,交付報告**第一段**是拿原話逐句拆的
「做到/沒做到/做到幾成」差距表 —— 列名用**他的詞**,不是你做到的那個範圍。
那張表是**開工時**寫的,不是交付時補的。

### 拿稿比對只列不一樣的
「落地了嗎」的回答第一句講**差幾格**。列出相符處是在找證據支持已下的結論,不是比對。

### 報「全綠」之前
- 跑的範圍要等於 CI 的範圍(只跑兩支說全綠,與沒跑同一個結論品質)
- 看**筆數**:一份 21 筆的全綠報告與 2245 筆的長得一模一樣
- 背景跑的測試:`Running N tests` 要對得上結尾的 `N passed` ——
  exit 0 / status passed / 零失敗**三個訊號都可能是假的**(`nohup … &` 的 exit code 是 shell 的)
- 紅燈的名字要活過你的 pipe:junit/json reporter 寫在設定裡,與怎麼呼叫無關

### 出貨前 grep 呼叫端
「表 / 服務 / 端點 / 測試都在,就是沒有人呼叫它」—— 型別檢查與測試都不會紅。
修好後 grep 誰還記著舊狀態(「已修好」沒回寫到讀者會看的地方,是同一個病的另一半)。

## 規則與檢查

### 規則寫了沒檢查就會漂(付過十次代價)
禁令與檢查**同一個 commit**;反向也成立:CI 也會鎖住錯的規則,改條文不改白名單等於沒改。

### 檢查存在 ≠ 會被跑 —— 四種失效形狀
① 出貨前清單沒列它 ② 沒人跑那份清單 ③ 名字指向的東西不存在
④ **它從來沒有通過過**(寫完沒跑就 commit)。補檢查解決不了這四種 —— 要補的是**跑檢查的清單**,
而清單要被當清單跑,不是憑印象挑。

### 新守衛的突變測試要模擬「部分退化」
整個移除誰都抓得到;真實的漂移是**只漏改一處**。至少一個突變只動一處,
且突變後先 `diff -q` 斷言檔案真的變了(格式化折行會讓 replace 靜默失效,
「突變沒跑」與「守衛放過它」輸出同一句話)。

### 禁令也要舉證,加字也要舉證
「禁 X」要寫得出 X 具體傷害什麼;寫不出的是「預設不用」不是禁。
只要求一邊舉證,必然單向漂移而且無聲。
畫面上的說明句同理:加有理由、拿掉沒人要求舉證 ⇒ 句子只增不減。
判準:**能用形狀答的不用句子答**(範例值是形狀,說明段落是句子;兩者都合格,只有一個會累加)。

## 使用者面

### 錯誤訊息淺而易懂
判準:唸給不會用電腦的人聽,他知道哪裡錯、下一步做什麼。
禁 validator/DB/framework 原文上畫面。🔴 **最大破口是 fallback**:
轉譯函式結尾 `return error.message` 會讓每個沒對映的錯誤原文上畫面,而且看起來有處理。
API 的 `code` 給程式、`message` 給人,不混。

### 破壞性動作要講「不會發生什麼」
按下去之前答三件:會做什麼(逐項列名)· 能不能救回來(能回復的講保留期)·
**它不會做什麼**(不是免責聲明 —— 是讓使用者知道還有什麼要另外處理)。

## 授權與供應鏈

### 授權查證方法論
- SPDX 欄位不可作為唯一依據(常回 NOASSERTION;**附加條款不會出現在裡面**)—— 讀 LICENSE **本文**
- **禁競品條款可以推翻主授權**,它禁的動詞是 use-to-develop 不是 copy —— 下載閱讀就是 use
- 同公司不同產品授權可不同;無 LICENSE 檔 = 保留所有權利,比 AGPL 更不可用
- 行銷頁不算授權依據;授權會變,每次引用重新確認附查證日
- solo 做不了標準 clean room ⇒ 判準是「有沒有乾淨的替代來源」:
  功能看官方文件,實作讀同類 MIT(還能直接抄,比讀完自己想拿到更多)

### 供應鏈門檻切在「正式相依鏈」不切在嚴重度
`audit --prod` 不得有 high + 全樹不得有 critical。
🔴 把「現況數字」寫進註解它必然過期;把「規則」寫進門檻它不會。
「dev / prod」不是套件的屬性,是**部署腳本那一行**的屬性 —— 問「它在不在 prod」先讀 Dockerfile 怎麼裝。

## 量測(最常出錯的一族)

- **量測腳本自己會錯,而且是安靜的**:探針回的都是「看起來很正常的數字」。
  自檢要**陽性+陰性對照組**(只有陰性擋不住探針整個沒跑;陽性挑剛出貨的東西)
- 工具輸出被截斷處看起來像清單的結尾(`head` / max-diagnostics / strict-mode 只印前幾筆)——
  看 summary 的總數,不要數自己 grep 到的行數
- 一面倒的結果特別可疑(全 0 / 全部命中 / 六個主題量出同一個數 = 量尺壞掉的訊號)
- 重要結論不能只用一種查法;結論會反轉的那種,查三種
