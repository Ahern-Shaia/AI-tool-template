# Claude Code Starter

把「careful, methodical commit style」的工作習慣帶到新專案的 starter template。

## 內容

```
claude-starter/
├── CLAUDE.md                   ← 專案最高指導原則 (R1–R15)
├── AGENTS.md                   ← Dev workflow 細節
├── docs/
│   ├── pre-pr-checklist.md     ← PR 前的人工檢查清單 (R15)
│   ├── cleanup-plan.md         ← 收斂功能的批次計畫範本
│   └── modules/
│       └── _template.md        ← 模組設計文件 (M0-M4 + OQ-N)
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
│   ├── rule_full_green_check.md          ← 全綠才算完成
│   └── reference_brain.md                ← Project Brain MCP
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
2. 複製 `docs/{pre-pr-checklist,cleanup-plan}.md` + `docs/modules/_template.md`
3. 種 `memory/*.md` 到 `~/.claude/projects/<encoded-project-path>/memory/`
4. 提示哪些 `[PLACEHOLDER]` 要改

### 方法 2：手動 copy（更可控）

```bash
cd /path/to/new-project

# 核心檔（必複製）
cp ~/Documents/AI-tools/claude-starter/CLAUDE.md ./
cp ~/Documents/AI-tools/claude-starter/AGENTS.md ./

# 流程文件
mkdir -p docs/modules
cp ~/Documents/AI-tools/claude-starter/docs/pre-pr-checklist.md docs/
cp ~/Documents/AI-tools/claude-starter/docs/cleanup-plan.md docs/
cp ~/Documents/AI-tools/claude-starter/docs/modules/_template.md docs/modules/

# 記憶種子（手動 — Claude Code 路徑編碼會吃中文 / 空白）
ENCODED=$(echo "$(pwd)" | sed 's|/|-|g')
mkdir -p ~/.claude/projects/$ENCODED/memory
cp ~/Documents/AI-tools/claude-starter/memory/*.md ~/.claude/projects/$ENCODED/memory/
```

## 套用後要改的地方

### 1. `CLAUDE.md`
- §0 專案身份：名稱 / 用途 / 語言 / git remote
- §1.3 程式碼層硬規則（R11-R15）：依專案技術棧改寫
- §2 技術棧：依語言改
- §4 程式碼目錄結構：依實際 layout 寫

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

## 進階：Project Brain (可選)

如果想要 MCP knowledge graph：

```bash
# 在新專案 root
git clone <project-brain-repo> .brain
cp ~/.claude/CLAUDE.md ./.claude/  # 教 Claude 用 brain MCP
```

詳見 `memory/reference_brain.md`。

## 版本

v1.0 (2026-05-15) — 初版，基於 Argus 專案累積的工作慣例萃取。
