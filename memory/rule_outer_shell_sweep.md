---
name: Cross-cutting concern 必 sweep outer shell
description: permission / audit / observability / i18n / a11y 這類橫切議題實作時必須把 sidebar / banner / route / layout shell 一起 sweep，不只 endpoint / button 層
type: feedback
---

任何 cross-cutting concern（permission gate / audit log / observability metric / i18n string / a11y label）導入時 — 不能只 sweep mutation endpoint 或 button 層；必須把**整個 outer shell**（sidebar / banner / page route / layout / header / footer）都 sweep 一輪。否則 BUG 會反覆在「外殼」出現。

**Why:**
- Cross-cutting concern 的 BUG 形態是「漏掉一處」，比 logic bug 更隱形
- 預設 sweep 的 endpoint / button 層只佔系統表面積的 30-40%
- 外殼層（sidebar 顯示什麼 tab / banner 顯示什麼 / route 進得去進不去 / header 顯示用戶身份）佔 60-70%
- 商家 / 客戶看到的第一印象通常是外殼，不是 endpoint
- 真實案例（generic）：權限系統做了 backend `require_feature` + button `PermissionGate`，但 sidebar / banner / page route 全 hardcoded，member 看到所有 tab → 看似「權限沒設」其實 backend 都擋了，UX 完全失敗
- 「漏 sweep 外殼」是設計缺陷不是局部漏 — 設計時就要把 outer shell 納入 cross-cutting concern 的責任範圍

**How to apply:**

**Cross-cutting concern 落地 checklist**（任何 5 大類橫切議題都跑）：

| 層次 | 要 sweep 的對象 | 範例 — 權限 | 範例 — i18n | 範例 — 觀測 |
|---|---|---|---|---|
| 1. Endpoint | 後端 API 路徑 | `require_feature` gate | API 錯誤訊息 i18n | request counter / latency |
| 2. Button | 互動元素 | `<PermissionGate>` | button label `t()` | click event metric |
| 3. **Sidebar** | navigation 主入口 | tab visibility 過濾 | tab label `t()` | tab click 事件 |
| 4. **Banner / alert** | 全屏訊息層 | banner 條件 owner-only | banner text `t()` | banner shown metric |
| 5. **Page route** | URL 直打進來 | route-level guard | page title `t()` | page view event |
| 6. **Layout** | header / footer / 切換器 | user identity 區塊 | layout 文案 `t()` | layout-level error |
| 7. **Loading / empty / error states** | 過渡頁面 | loading 期間不亮 button | empty state 中文 | error state 記 log |
| 8. **No-context state**（**容易漏**）| user 登入但無任何 tenant / workspace / project / org context | 整個 dashboard 直接 fullscreen「無 context」頁 + 登出 | 文案中文 | no-context page view 事件 |

> **第 8 層特別說明（real BUG 提煉）**：權限系統做了「user 沒對應 tenant→tenant list 回空」，但前端 fail-OPEN 路徑沒擋 — context=null 時 `has()` 全 true → sidebar 全亮 / page 進得去（即使 backend 都 401）。這層是「user 身份合法但沒被授權任何資源」的特殊 empty state，跟一般「無資料」empty state 不同 — 整個 dashboard 不該 render，要直接接管全屏。設計時容易被當「list 為空 → render empty list」帶過，實際是「沒 context → 整個 app 不該動」。

**設計階段就納入**：
- M0 design doc §影響範圍表必列「endpoint + button + sidebar + banner + route + layout + states」7 層
- 每層列「需要 sweep 嗎？(Y/N) + sweep 方式」
- 如果某層 N — 明確說「為什麼這層不需要」（譬如 i18n 不需要 sweep observability）

**M(N) 收尾必驗 7 層 sweep 完成**：
- M4 / 收尾 commit 列「7 層 sweep checklist ✅」
- 漏一層 → 不算 module SHIPPED，補完再 close

**Anti-pattern**：
- ❌「先做 endpoint + button 層，外殼有空再補」— 「有空再補」會無限延後，下一個商家 BUG 出來才補
- ❌「outer shell 的 BUG 算另一個 module」— cross-cutting concern 的責任不該被切碎
- ❌「外殼 fail-OPEN 沒關係，backend 會擋」— UX 仍會被當 BUG 報告

**CI Gate**（per `feedback_full_green_check`）：
任何 cross-cutting concern 都應該有 pytest / playwright CI gate enforce「新加 page / button / sidebar 必須對應跑過該 concern 的 sweep」— 否則下個 module 又會漏。
