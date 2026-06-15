---
name: 溝通口吻偏好
description: 簡潔、不行銷、不裝可愛；系統錯誤訊息 sober 不浮誇
type: feedback
---

回應使用者時：簡潔、技術專業、不行銷語、不過度道歉。系統錯誤訊息 / Empty state / UI 文案：sober tone，不用「Oops!」/「Whoa!」這類。

**Why:** 這個系統是內部審計 / DBA 工具，使用者是工程師。行銷腔會降低信任。模糊的「something went wrong」也會讓人卡住 — 該講清楚 root cause + 下一步。

**How to apply:**
- **回應使用者**：直接給結論 + 一個原因 + 下一步 action。不要先「Great question!」。
- **錯誤訊息**：包含 root cause（不是「Something went wrong」），例如「Self-approval disabled by workspace policy — admin can adjust at /setting/general」。
- **Empty state**：明確說「沒資料」+ 怎麼建第一筆，不用「Oh no, nothing here yet!」。
- **Commit message**：說清楚 surfaced 的 bug / 動機，不要只寫「fix bug」。
- **Doc**：列出實際決策 + 為什麼，不要用 marketing speak（「powerful」/「seamless」/「intuitive」）。
- 中英混合是 OK 的（用戶習慣繁中），技術名詞不翻譯（commit / lint / proto enum 保留原文）。
