---
name: 上 prod 前必做 FMEA 失效反思
description: 功能標完成 / 上 prod 前必產出 FMEA 失效場景反思（CLAUDE.md R17）；P0 未緩解不得上 prod
type: feedback
---

任何功能在標「完成」或上 prod 前，**必須產出 FMEA 失效場景反思**：**逐路徑**列
「失效模式 → 影響 → 嚴重度（P0/P1/P2）→ 緩解狀態（✅ 已處理 / ⚠️ 已知殘留 / 🔒 外部 gate）」。
**任一 P0 未緩解 → 不得上 prod**。已知殘留也要列（寫清楚為何可忍 + 治本方向），不是只列修好的。

**Why:** 「反思設計缺陷 → 修復」是高價值的收尾習慣 —— 把實作完的功能當作「假設它已經壞了」
反推哪裡會壞（pre-mortem），往往能在上線前當場揪出 P0 級缺陷（典型例：某確認流程在大螢幕 /
短內容下 onScroll 不觸發 → 按鈕永遠 disabled → 使用者根本無法完成註冊）。只測 happy path 抓不到。
技術名詞 = FMEA（失效模式與影響分析）+ pre-mortem（事前剖析）。

**How to apply:**
- 已 codify 成 **CLAUDE.md §1.2 R17**（通用行為鐵則，每 session override）+ §3 開發流程收尾步驟。
- module 級任務：填進 design doc 的「§12 失效場景反思（FMEA）」章節（`docs/modules/_template.md`
  已有固定格式 + 路徑骨架 + P0 檢查點）。
- 小改動 / hotfix（無 design doc）：至少在回報中口頭列失效場景 + 緩解，不用整章。
- 分路徑列：每個入口 / 外呼 / 狀態轉換 / 並發點 / 部署順序各一小節；額外列「不修的 pre-existing」。
- 嚴重度判準：P0 = 無法完成核心流程 / 資料毀損 / 跨租戶外洩；P1 = 資料髒 / 體驗差 / 可繞過；P2 = 邊角。
- 心態 = pre-mortem（假設它已壞，反推為什麼），不是只測 happy path。
- 關聯 [[feedback_verify_prod_state_before_push]]（部署順序 P0：migration 必先於 code）、
  [[feedback_smoke_test_after_push]]（push 後驗證）、[[rule_module_design_flow]]（M5 收尾接這步）。
