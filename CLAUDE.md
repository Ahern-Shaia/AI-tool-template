@AGENTS.md

# CLAUDE.md — [PROJECT_NAME] 開發指引

> 本文件是 Claude Code 在 [PROJECT_NAME] 中的最高指導原則。所有開發任務開始前，Claude Code 必須先讀完本文件。

> 狀態：[PHASE / STATE]
>
> [一兩句專案目前狀態描述 — 是 greenfield / refactor / migration / 維護期，影響 Claude Code 行為的關鍵脈絡]

---

## 0. 專案身份

- **名稱**：[PROJECT_NAME]
- **用途**：[一句話描述產品 / 系統做什麼]
- **語言**：[Go / Python / TypeScript / etc]
- **運行**：[單一二進位 / K8s / SaaS / etc]
- **授權**：[MIT / Apache-2.0 / proprietary / TBD]
- **Git remote**：[origin URL or "TBD"]

---

## 1. 不可違反的鐵則

### 1.1 一般開發

| 規則 | 說明 |
|---|---|
| **R1** | 任何破壞性修改（DB schema、API 介面）**必須先寫遷移計畫**，PR 描述中說明影響範圍 |
| **R2** | 安全敏感模組（認證、權限、審計、計費）**必須有單元測試 + 整合測試**，覆蓋率 > 80% |
| **R3** | **不可在程式碼中硬編 secret**（API key、密碼、token）。一律走環境變數或 secret manager |
| **R4** | 涉及 SQL 執行的功能**必須走 prepared statement**，禁止字串拼接 |
| **R5** | 所有寫入操作**必須記錄 audit log**，包含 actor、action、target、timestamp、result |

### 1.2 Claude Code 行為

| 規則 | 說明 |
|---|---|
| **R6** | Claude Code **不得自行決定架構**。重要設計（資料模型、API 介面、狀態機）**必須先寫設計文件、由人 review 後再實作**（用 `docs/modules/<module>.md` 模板）|
| **R7** | Claude Code 在不確定時**必須停下來問**，不可猜測。例外：使用者明確說「全部由你決定」時，可在已宣告的範圍內裁定 |
| **R8** | **每個 task 完成後必須跑完整測試 + lint + build**，全綠才算完成 |
| **R9** | **不得使用 `--no-verify` 跳過 git hook**；不得用 `git push -f` 推 main 分支 |
| **R10** | 涉及生產環境的任何操作（部署、執行 SQL、資料變更）**必須由人手動執行**，Claude Code 只能產生指令，不能直接執行 |
| **R17** | **功能標「完成」或上 prod 前，必須產出 FMEA 失效場景反思** — 逐路徑（每個入口 / 外呼 / 狀態轉換 / 並發點 / 部署順序）列「失效模式 → 影響 → 嚴重度（P0/P1/P2）→ 緩解狀態（✅/⚠️ 殘留/🔒 外部 gate）」，寫進 design doc 固定章節（範本見 `docs/modules/_template.md`「失效場景反思（FMEA）」段）。**任一 P0 未緩解不得上 prod**；已知殘留也要列（為何可忍 + 治本方向）。無 design doc 的小改動 / hotfix 至少在回報中口頭列失效場景 + 緩解。心態 = pre-mortem（假設它已壞，反推為什麼），不是只測 happy path |

> R17 編在 §1.2（通用行為鐵則）而非 §1.3 —— 它不依專案技術棧，不可砍。

### 1.3 程式碼層硬規則（依專案技術棧調整）

> 這節是 starter 版本，依專案技術棧改寫 / 增刪 / 全砍。下面是常見規則範例：

| 規則 | 說明 |
|---|---|
| **R11** | （DB layer）**Composite-PK predicate**：對使用複合主鍵的表，所有 `WHERE / JOIN / DELETE / UPDATE` predicate 必須帶完整 PK，不可只以 `id` 過濾 |
| **R12** | **i18n locale-only**：所有 UI 顯示字串只能放 locale 檔，禁止硬編 |
| **R13** | **Component spacing**：button group / form group 一律用 `gap-*`，禁止 `space-x-*` / `space-y-*` |
| **R14** | **新代碼語言/框架選擇**：[依專案訂定，例如 "新 UI 一律 React + Base UI，不在 Vue 上加新功能"] |
| **R15** | **Pre-PR Checklist**：`gh pr create` 前必須走過 `docs/pre-pr-checklist.md` |
| **R16** | **前端設計鐵則**：所有前端產出必過 `docs/frontend-design-principles.md` —— **§A 普世核心**（刻意 > 出廠預設、token、a11y、動效、先研究、全狀態、響應式、複用、文案）一律適用、**§C 設計流程迴圈**動手前先跑；**§B 美學 profile 本專案鎖定 `modern-SaaS-craft`，不可換**。Claude Code 不得自行改用其他 profile（playful / editorial / minimal / brutalist 等）；要換必須由人改本鐵則 + `docs/frontend-design-principles.md` §B，並於 PR 說明理由 |

### 1.4 執行模式（autonomy level）

> 用戶在啟動 Claude Code 時可選兩種執行模式之一：

**Mode A — 互動模式（預設）**：
- 每個高風險動作前確認（重啟 / 動 prod / 大範圍刪除）
- 適合：新專案探索期、不熟領域、需共同決策
- 對應 feedback：`feedback_single_task_execution.md`

**Mode B — 企業級自主模式**：
- 啟動指令：`claude --dangerously-skip-permissions`
- 含意：用戶**主動移除摩擦** + **要求加深度**（不是降低標準）
- 行為調整：
  - 平行 Agent / 背景 Monitor / 試錯 repro 不再每次問
  - 每個 commit 主動跑 cross-cutting checks（security / observability / cost / compat 四檢，見 `memory/rule_cross_cutting_checks.md`）
  - design doc 範本擴 §安全模型 / §容量 / §失效 / §觀測 / §成本 / §兼容 六大章節
  - Trade-off 主動 surface（不等用戶問就告知影響）
- **仍會停下來的情境**：架構選擇 / 砍-留決策 / business logic 模糊 / `git push -f` 等不可逆操作
- 對應 feedback：`feedback_enterprise_execution.md`

> 用戶於對話開頭明說「企業級」/「商用系統」/「production-grade」即切到 Mode B。

---

## 2. 技術棧

### 2.1 後端
- [語言 + 版本]
- [DB / cache / queue]
- [API protocol: gRPC / REST / GraphQL]
- [Migration tool + 路徑慣例]

### 2.2 前端
- [Framework + 版本]
- [UI lib]
- [State management]

### 2.3 工具
- [pnpm / npm / yarn — 二選一不可混用]
- [proto / openapi 生成器]
- [lint / format / type-check]

---

## 3. 開發流程

詳細指令見 `AGENTS.md`。摘要：

```bash
# Backend
[make build / cargo build / etc]
[make test / pytest / etc]
[make lint]

# Frontend
[pnpm fix / npm run lint / etc]
[pnpm type-check]
[pnpm test]

# Proto / Codegen
[make proto / buf generate / etc]
```

每個 task 完成後（R8）：

1. **format** modified files
2. **lint** — 重複跑直到 0 issues
3. **build / test**
4. 涉及 proto / API schema：regen + commit generated files
5. 涉及 frontend：fix + type-check + test

---

## 4. 程式碼目錄結構

```
[PROJECT_NAME]/
├── [backend or src/]
│   ├── [layered structure]
│   └── internal/                ← 【公司新增模組進這裡】
├── [frontend/]                  ← (如有)
│   └── src/
├── proto/                       ← (如有)
├── docs/
│   ├── pre-pr-checklist.md
│   ├── modules/<module>.md      ← 模組詳細設計（CLAUDE.md R6）
│   └── ...
├── CLAUDE.md  AGENTS.md  README.md
```

---

## 5. 與 Claude Code 協作

### 5.1 任務啟動流程
1. 讀完 `CLAUDE.md`（本檔）+ `AGENTS.md`
2. 讀對應模組 `docs/modules/<module>.md`（如有）
3. `git status` 確認在乾淨分支
4. 確認測試環境可正常啟動

### 5.2 任務拆解粒度

**原則**：一個 task 應**一個檔案內 + 改動 < 200 行 + 單一 commit**。複雜功能拆多 task 串接。

模組級任務按 **M0 → M1 → M2 → M3 → M4** 切：
- **M0**：寫 design doc，列開放問題（OQ-XYZ-N），等用戶裁定
- **M1–M3**：實作各 sub-task，每個 milestone 一個 commit
- **M4**：docs 收尾 + MODULES.md 標 ✅

### 5.3 何時必須停下來問

| 情境 | 為什麼 |
|---|---|
| 需要修改現有共用模組 | 影響範圍大，可能破壞其他模組 |
| 需要新增 DB schema 或 migration | 影響面廣，需設計 review |
| 需要繞過或停用既有測試 | 通常表示測試發現真實問題 |
| 業務邏輯模糊 | 領域知識需 DBA / domain expert 主導 |
| 需要新增第三方依賴 | 影響供應鏈安全 |
| 大規模重新命名 / 刪除 | 不可逆操作，需明確授權 |

### 5.4 PR 規範

PR 標題：`<type>(<scope>): <description>`（例 `feat(risk): add CEL evaluator`、`fix(audit): handle nil ctx`）。

PR 內容必含：目的、變更內容、測試結果、影響範圍。

---

## 6. Quick Reference

| 用途 | 路徑 |
|---|---|
| 本主指引 | `CLAUDE.md` |
| Dev workflow 細節 | `AGENTS.md` |
| 模組詳細設計 | `docs/modules/<module>.md` |
| Pre-PR Checklist | `docs/pre-pr-checklist.md` |
| Cleanup 收斂規劃 | `docs/cleanup-plan.md` |
| 前端設計原則（核心 + 美學 profile） | `docs/frontend-design-principles.md` |

---

## 附錄：本文件變更紀錄

| 日期 | 版本 | 變更 | 作者 |
|---|---|---|---|
| YYYY-MM-DD | v1.0 | 初版 | [填名] |
