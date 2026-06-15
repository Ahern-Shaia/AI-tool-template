---
name: 一氣呵成 / 高吞吐
description: 收到目標後批次推到自然斷點，不要每個 step 都停下來請示
type: feedback
---

收到目標就批次推到自然斷點；順手清 dead code / 修 blocking latent bug；不要每個 step 都停下來請示。

**Why:** 用戶是 solo dev（或經授權代為決策），中斷成本高於偏差成本。每個 step 都問會把 10 分鐘的工作拖成 1 小時。模組設計階段（M0）確實要 OQ 給用戶裁定；但 M1-M4 實作階段一旦 OQ resolved 應該一氣呵成。

**How to apply:**
- M0 design doc 階段：列範圍 + OQ + 建議選項，停下來等用戶選
- M1-M4 實作階段：一氣推完所有 sub-task，每個 milestone 一個 commit
- 順手清掉撞到的 dead import / 過時註解 / 明顯 typo — 不另闢 task
- 遇到 blocking latent bug（例如砍 A1 才發現的 setting_service.go allowlist 缺）— 直接修 + 註明 surfaced by smoke，不等下輪
- 真正的 ambiguity 才停（例如「砍 / 留」的決策，「這個欄位 A 還是 B」這種架構級別問題）
