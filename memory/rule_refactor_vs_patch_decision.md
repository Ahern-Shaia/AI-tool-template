---
name: 修補 vs 重構決策架構
description: 區分「設計缺陷」/「sweep 紀律不夠」/「局部漏」三件事；不要把任何反覆 BUG 都當成設計缺陷要重構
type: feedback
---

當用戶或團隊感受「某模組一直在修補」時 — 不要直接跳到「該重構了」結論。先把 BUG 性質分三類：(A) 設計缺陷、(B) sweep 紀律不夠、(C) 局部漏。三類解法不同，搞混會浪費 2-4 週工程。

**Why:**
- 真正的「設計缺陷」應該重構 — 但這只占 < 20%
- 大部分「一直修補」感覺是 sweep 紀律不夠 — 解法是加 CI gate / sweep 規範，不是重構
- 純局部漏（filter 漏一條 / 條件漏一個 if）就更不該觸發重構討論
- 重構成本（兩週 + prod 風險 + 商家停權）vs 修補成本（每次半天 + 加 CI gate 永久消滅該 BUG class）— 對 < 100 商家 / < 5 actor 規模通常 CI gate 划算
- 業界 model（OPA / Cedar / Auth0 FGA / Casbin）有導入門檻 — 規模到才划算，太早導反而增加複雜度

**How to apply:**

**用戶感受「一直在修補」時 — 先分類**：

| 類型 | 特徵 | 解法 | 範例 |
|---|---|---|---|
| **(A) 設計缺陷** | 模型本身不對；新需求不停打破假設；每加 actor / resource / action 都要改 core API | 重構（用業界 model 參考） | actor 8+ 種 / resource 彼此引用 / condition-based 規則 |
| **(B) sweep 紀律不夠** | 模型對；BUG 都是「某新功能加上去忘了 sweep 對應路徑」；同類 BUG 反覆 | 加 CI gate enforce sweep + 寫 sweep checklist | 新加 page 忘 wrap permission guard / 新加 endpoint 忘加 audit log |
| **(C) 局部漏** | 模型對，sweep 紀律也有，就是 filter 條件少寫一條 | 補 filter + 加 regression test | `WHERE active=true` 漏掉一處 |

**決策 framework**：

> 對「一直修補」感受問 3 個問題：
>
> 1. **模型核心 API 有沒有被新需求逼著改？** 有 → 可能是 (A)；沒有 → 跳 2
> 2. **BUG 是不是同類型反覆出現（新功能加上去忘了 sweep）？** 是 → (B)；不是 → 跳 3
> 3. **這個 BUG 是不是單一條 filter / if 漏掉？** 是 → (C)；都不是 → (A)

**重構觸發條件**（什麼時候真該動）：

| Vertical | 觸發條件 |
|---|---|
| 權限系統 | actor 種類 8+ / resource 彼此引用 / condition-based 規則 / 商家數 100+ |
| Audit 系統 | event 種類 50+ / 跨系統 join 變慢 / 合規查詢需 ad-hoc |
| Observability | 指標 200+ / 自家 logging 比 vendor 貴 / 跨 region join 卡 |
| Auth | SSO 多家 / 多 IdP / federation 需求 |

**未到觸發條件時**：
- 加 CI gate 消滅該 BUG class（per `rule_outer_shell_sweep`）
- 加 sweep checklist 進 design doc 範本
- 加 catalog 命名規範 / lint
- 寫 ADR（Architecture Decision Record）記錄「為什麼此時不重構」

**Surface 給用戶的格式**：
- 直接承認「確實是 patchy」（不防衛 model 是對的）
- 區分三類：哪些是 (A) / (B) / (C)
- 給「不重構 + 做 X / Y / Z」vs「重構 + 預估 N 週 + 風險」對比
- 給真正觸發重構的條件（讓用戶知道未來什麼時候該重啟這討論）

**Anti-pattern**：
- ❌「BUG 反覆 = 模型錯 = 重構」— 沒分三類
- ❌「先重構再看 BUG 還在不在」— 重構期 BUG 風險更高
- ❌「業界都用 X 所以我們也該用」— 規模 / actor 數沒到，導入後反而負擔
- ❌「修補就好不討論架構」— 真正設計缺陷拖久反而代價更大；要主動定期 review
