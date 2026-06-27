---
name: 模組設計流程
description: 任何 non-trivial 模組必走 M0 design doc + OQ-N 給用戶裁定 → M1-M4 落地 → MODULES.md 標 ✅
type: feedback
---

非 trivial 模組（>200 LOC、跨多檔、新建 DB schema、新 API）動工前**必須**先寫 design doc。

**Why:** CLAUDE.md R6 強制「不自決架構」。先 design 後 implement 的好處：
1. OQ 階段把所有「砍 / 留」、「方案 A / B」、「block / evict」決策一次性問清楚 — 後面實作不用回頭問
2. design doc 本身成為模組 spec — 一年後接手的人 (or AI) 直接讀文件
3. M0→M4 切分讓「一氣呵成」變可能 — M1 開始就只是執行，不再有 strategic 決策

**How to apply:**

**M0 design doc**（用 `docs/modules/_template.md` 當骨架）：
- §1 目標 + §2 不做的事 + §3 sub-task 切分 + §4-N 各 sub-task 細節 + §N+1 測試 + §N+2 milestones + §N+3 **開放問題 OQ-[ABBR]-N** + §N+4 SOP + §N+5 變更紀錄
- §1.2「對應 stakeholder 訴求」表把每個 sub-task ladder 到產品 / 商業需求
- 每條 OQ：一句問題 + 2–4 個選項 + Claude Code 建議 + 為什麼建議這選項
- 提交 commit `docs(<scope>): M0 ... design DRAFT v0.1`

**用戶裁定後**：
- 把 OQ 表頭從「選項 / 建議」改成「裁定 / 落地影響」
- 狀態 `DRAFT → APPROVED`
- changelog 加一行記錄裁定
- 提交 commit `docs(<scope>): v0.2 — OQ-[ABBR]-1..N resolved`

**M1-MN 實作**：
- 每個 milestone 一個 commit
- commit message 引用對應 OQ 裁定（"per OQ-APP-4 = B"）
- 出現意外 scope（surfaced by build / smoke）— 就地修 + 在 commit message 註明 surfaced from

**M(N+1) 收尾**：
- **FMEA 失效場景反思（R17，[[rule_fmea_before_ship]]）**：逐路徑列失效模式 → 影響 → 嚴重度 →
  緩解，填進 design doc §12；**任一 P0 未緩解不得標 SHIPPED / 上 prod**
- design doc 狀態 `APPROVED → SHIPPED`，版本 → v1.0
- 補 §SOP（操作指引 + 失敗模式 + 審計 SQL）
- 補 §milestones 表的 commit hash
- MODULES.md 對應模組標 ✅
- 提交 commit `docs(<scope>): M(N+1) close-out — <module> v1.0`

**例外**：bugfix / 純前端 i18n / lint cleanup / 修 typo — 不用走這套流程。直接 commit 就好。
