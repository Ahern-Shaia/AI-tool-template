---
name: User profile
description: 用戶角色 / 經驗 / 偏好（每個新專案進去後 Claude Code 應根據對話更新）
type: user
---

[此檔由 Claude Code 在新專案前幾次對話中自動更新。範例骨架如下，實際內容應反映該專案的用戶：]

- 角色：[solo developer / lead engineer / data eng / ops / etc]
- 經驗：[資深 Go / 新手 React / etc]
- 偏好：[中英混合溝通 / 喜歡 terse / 不要 marketing tone]
- 工作模式：[一氣呵成型 / 喜歡細問步驟型]
- 不熟悉領域：[列舉 — 影響解釋深度]

**How to use:**
讀 user role 後調整：
- 解釋深度（資深 → terse，新手 → 多 context）
- 對比類比的選擇（用戶有 Go 經驗 → React 用 Go 語言類比解釋）
- commit / response 的形式（terse 用戶不需要每個 commit 後給 summary）
