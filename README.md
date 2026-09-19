# Claude Code Starter

把「careful, methodical commit style」的工作習慣帶到新專案的 starter template。

> **2026-09 二次更新**|技術棧 → 規則的那條線接起來了:
> ① 新增 `docs/performance-baseline.md` —— **效能地板**(與棧無關,`security-baseline.md` 的雙生檔) (R20)
> ② `docs/stack-rules/` —— **技術棧附件**(Go / Python / React-Next / TS-NestJS)
>    + `_generator.md` 生成器規格(沒有現成附件的棧照**固定 16 維度**生成) (R21)
> ③ `setup.sh` 會**偵測 manifest 自動帶上對應附件**,並補齊過去漏掉的 4 份 docs
>    (R18 曾指向一個新專案根本沒有的檔)
> ④ `scripts/check-docs-wired.sh` —— 守衛:鐵則引用的檔必須存在、必須會被部署、不得有孤兒
>
> **2026-09 大更新**|從一個跑了三個月的真實產品專案(全 TS、solo + AI)回抽:
> ① 新增 `docs/pre-dev-decisions.md` —— **開工前要決定的 25 件事**,每件附「先定受益/後補付代價」的實證
> ② `AGENTS.md` 尾端新增〈通用鐵則〉—— 五站研究法、全稱詞差距表、規則與檢查同 commit、
>    授權查證方法論(SPDX 不可信/禁競品條款)、量測自檢(陽陰對照)等,每條都付過代價
> ③ `memory/` 新增 11 個通用 pitfall(量尺安靜地錯、檢查存在但沒人跑、出貨了沒人呼叫…)
> ④ CLAUDE.md R16 修正:美學 profile 從「鎖 modern-SaaS-craft」改為**開工時依母心智模型決定**
>    (前一版的鎖定在實戰中被推翻)

## 內容

```
claude-starter/
├── CLAUDE.md                   ← 專案最高指導原則 (R1–R21)
├── AGENTS.md                   ← Dev workflow 細節
├── docs/
│   ├── pre-dev-decisions.md    ← ⭐ 開工前決策清單(25 格,每格附真實專案的代價實證)
│   ├── security-baseline.md    ← ⭐ 資安地板(P0 第一天生效;含 AI/LLM 載重不變量) (R18)
│   ├── performance-baseline.md ← ⭐ 效能地板(與棧無關;量測自檢、逾時、N+1、快取 scope) (R20)
│   ├── stack-rules/            ← ⭐ 技術棧附件:地板在這個棧上長什麼樣 (R21)
│   │   ├── _generator.md       ←   沒有現成附件時的生成器規格(固定 16 維度)
│   │   └── go.md · python.md · react-nextjs.md · typescript-nestjs.md
│   ├── frontend-testing.md     ← ⭐ 前端真實操作驗證迴圈 + e2e 品質規則 (R19)
│   ├── pre-pr-checklist.md     ← PR 前的人工檢查清單 (R15)
│   ├── cleanup-plan.md         ← 收斂功能的批次計畫範本
│   ├── frontend-design-principles.md ← 前端 §A 普世核心 + §B profile(開工時決定)
│   └── modules/
│       └── _template.md        ← 模組設計文件 (M0-M4 + OQ-N)
├── scripts/
│   └── check-docs-wired.sh     ← 守衛:鐵則引用的檔要存在、要會被部署、不得有孤兒
├── chatgpt-rules/              ← ChatGPT / Codex 版規則(Claude 版的投影,同步方向單向)
│   └── CHATGPT_PROJECT_INSTRUCTIONS.md  ← 可直接貼 Project Instructions 或併入 AGENTS.md
├── memory/                     ← 用戶層持久記憶 (跨 session)
│   ├── MEMORY.md               ← 索引
│   ├── user_role.md            ← 用戶 profile
│   ├── feedback_enterprise_execution.md  ← ⭐ 企業級執行 (--dangerously-skip-permissions)
│   ├── feedback_single_task_execution.md ← 一氣呵成 (個人專案 / prototype)
│   ├── feedback_no_pr_workflow.md        ← Solo dev workflow
│   ├── feedback_communication_voice.md   ← 溝通口吻
│   ├── rule_module_design_flow.md        ← 模組設計流程
│   ├── rule_cross_cutting_checks.md      ← ⭐ Security/Observability/Cost/Compat 四檢
│   ├── rule_commit_format.md             ← Commit message 格式
│   └── rule_full_green_check.md          ← 全綠才算完成
└── setup.sh                    ← 部署腳本
```

## 套用到新專案

### 方法 1：直接 copy（最快）

```bash
cd /path/to/new-project
bash ~/Documents/AI-tools/claude-starter/setup.sh
```

`setup.sh` 會：
1. 複製 `CLAUDE.md` + `AGENTS.md` 到專案 root
2. 複製**所有被鐵則引用的 docs**（兩塊地板、開工前決策、前端兩份、checklist、模組範本）
3. **偵測技術棧**（`go.mod` / `pyproject.toml` / `package.json` 的 next·react·@nestjs/core·typescript
   / `Cargo.toml` …）→ 帶上對應的 `docs/stack-rules/<stack>.md`；沒有現成附件就印出
   「照 `_generator.md` 生成」的指引
4. 種 `memory/*.md` 到 `~/.claude/projects/<encoded-project-path>/memory/`
5. 提示哪些 `[PLACEHOLDER]` 要改

### 方法 2：手動 copy（更可控）

```bash
cd /path/to/new-project

# 核心檔（必複製）
cp ~/Documents/AI-tools/claude-starter/CLAUDE.md ./
cp ~/Documents/AI-tools/claude-starter/AGENTS.md ./

# 流程文件 + 兩塊地板（鐵則會引用，少一份就是鐵則指向不存在的檔）
mkdir -p docs/modules docs/stack-rules
S=~/Documents/AI-tools/claude-starter
cp $S/docs/pre-dev-decisions.md $S/docs/security-baseline.md \
   $S/docs/performance-baseline.md $S/docs/frontend-design-principles.md \
   $S/docs/frontend-testing.md $S/docs/pre-pr-checklist.md $S/docs/cleanup-plan.md docs/
cp $S/docs/modules/_template.md docs/modules/

# 技術棧附件：挑你這個專案的棧（沒有的話複製 _generator.md 生成一份）
cp $S/docs/stack-rules/_generator.md docs/stack-rules/
cp $S/docs/stack-rules/go.md docs/stack-rules/     # 或 python.md / react-nextjs.md / typescript-nestjs.md

# 記憶種子（手動 — Claude Code 路徑編碼會吃中文 / 空白）
ENCODED=$(echo "$(pwd)" | sed 's|/|-|g')
mkdir -p ~/.claude/projects/$ENCODED/memory
cp ~/Documents/AI-tools/claude-starter/memory/*.md ~/.claude/projects/$ENCODED/memory/
```

## 套用後要改的地方

### 1. `CLAUDE.md`
- §0 專案身份：名稱 / 用途 / 語言 / git remote
- §1.3 程式碼層硬規則（R11-R16）：只放**這個專案特有**的幾條；棧的通用規則在 `docs/stack-rules/`
- §2 技術棧：依語言改
- §4 程式碼目錄結構：依實際 layout 寫

### 1b. 兩塊地板的 §0（開工當天就要寫，不是之後補）
- `docs/security-baseline.md` §0 —— 最值錢的資產 + 前三個攻擊面
- `docs/performance-baseline.md` §0 —— p95 目標 / payload 上限 / 單請求外呼次數上限
- 兩個 §0 都是後面所有取捨的判準；寫不出來代表還不知道自己在守什麼 / 什麼叫慢

### 2. `AGENTS.md`
- 全部 `[替換]` placeholder 改成實際指令

### 3. `docs/pre-pr-checklist.md`
- §2 Data Safety：依 DB / schema 慣例改寫（composite-PK 規則只有某些專案需要）

### 4. `memory/user_role.md`
- 由 Claude Code 在前幾次對話中自動更新；或你手動 seed

## 開始用

新專案複製完後，第一次跟 Claude Code 對話時開頭加一句，**選擇執行模式**：

### Mode A — 互動模式（個人專案 / prototype / 內部工具）

```bash
claude
```
然後對話開頭：
> 「沿用 claude-starter 工作風格 — 一氣呵成、不假裝 PR ceremony、模組設計先寫 design doc + OQ-N 給我裁定再實作」

Claude 會走 `feedback_single_task_execution.md`。

### Mode B — 企業級自主模式（商用系統 / production-grade） ⭐

```bash
claude --dangerously-skip-permissions
```
然後對話開頭：
> 「企業級商用系統開發 — 跑完整 cross-cutting 檢查（security / observability / cost / compat），design doc 必含 §安全 / §容量 / §失效 / §觀測 / §成本 / §兼容六大章節」

Claude 會走 `feedback_enterprise_execution.md` + `rule_cross_cutting_checks.md`，行為調整：
- 平行 Agent / 背景 Monitor / 試錯 repro 不再每次問
- 每個 commit 主動跑 security / observability / cost / compat 四檢
- design doc 範本擴 §7-bis 企業級 cross-cutting 七大表
- Trade-off 主動 surface（不等用戶問就告知影響）
- 仍會停下來：架構選擇 / 砍-留決策 / business logic 模糊 / `git push -f` 等不可逆操作

---

Claude Code 會（兩種 mode 都會）：
1. 自動讀 `CLAUDE.md`（每次 session 啟動）
2. 自動讀 `~/.claude/projects/<encoded>/memory/MEMORY.md`（每次 session 啟動）
3. 任何 non-trivial 模組請求都會先寫 design doc
4. 任何完成的 task 都會跑 format / lint / build / test

## 安全 / 效能規則怎麼依技術棧生效

三層，開工那天一次接完：

```
第 0 層  地板（與棧無關，不可砍）
         docs/security-baseline.md      (R18)  注入 / authz / JWT / LLM / secret / 供應鏈
         docs/performance-baseline.md   (R20)  量測自檢 / N+1 / 逾時 / 快取 scope / 資源上限
            │
            ▼  「這兩塊地板，在我這個棧上長什麼樣？」
第 1 層  技術棧附件（挑一份）
         docs/stack-rules/go.md · python.md · react-nextjs.md · typescript-nestjs.md
            │
            ▼  沒有現成附件的棧
第 2 層  生成器規格
         docs/stack-rules/_generator.md  —— 固定 16 維度（S1–S8 安全 / P1–P8 效能），
                                            缺一維不准交，由人 review 後才生效
```

**為什麼要固定維度**：自由生成的規則沒有分母，看起來很完整但你不知道漏了什麼。
固定 16 維度的產出可以**對帳**——每一維要嘛有規則、要嘛寫「本棧由 X 內建涵蓋」、
要嘛寫「不適用 + 為什麼」，留白不是結論。

**為什麼每條規則都要寫執法點**：規則沒有檢查一定會漂（這個 repo 為它付過十次代價）。
所以附件裡每條 P0 都要指得出「哪個設定旗標 / 哪條 lint 規則 / 哪個 CI job / 哪支 grep 守衛」；
寫不出執法點的降級成 P2 慣例，不准掛 P0。每份附件檔尾有一節 **CI-fail 禁令清單**，
那節是直接給設定 CI 的人用的。

**接線也要被檢查**：`bash scripts/check-docs-wired.sh` 擋四種漂移 ——
鐵則引用了不存在的檔、引用了但 `setup.sh` 不部署、沒人引用的孤兒 doc、
新棧附件忘了加進 `STACK_FILES`。改 `docs/` 或 `setup.sh` 之後跑一次；
GitHub Actions 每次 push / PR 也會跑。

## 版本

v1.0 (2026-05-15) — 初版，基於 Argus 專案累積的工作慣例萃取。
