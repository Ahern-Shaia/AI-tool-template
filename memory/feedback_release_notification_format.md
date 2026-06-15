---
name: 發版通知 8 段式擴充模板
description: 任何 push to prod 後自動採此 8 段式發版通知，超過 SOP 基礎結構，便於商業 / 客戶 / 內部三邊對齊
type: feedback
---

Push 到 prod + smoke 過後 — 自動產生 8 段式發版通知作為對話 final response。便於用戶後續轉貼內部 Slack / 客戶 / Status Page / Changelog 任一管道。

**Why:**
- 純粹「已 push」/「smoke 過了」訊息對外不夠用 — 內部 ops / 客戶 / commercial team 需要不同形式
- 8 段固定結構讓未來通知可預期 / 可被 SOP 化（後續若導 release-notes 工具可自動套用）
- 「Rollback」「同類風險」這兩段強迫 Claude 主動思考「萬一壞了怎辦」/「這次踩坑下次哪邊還會踩」— 是 Mode B 風險可見化的具體實踐
- 商業可見的「對外通知」段強迫區分 user-visible vs invisible change，避免內部「上線完啥都沒改」感

**How to apply:**

採以下 8 段（顯式分節，標題用 H3）：

```markdown
## 發版通知 — YYYY-MM-DD <模組名>

### 1. 類型
[一句：feature / bug fix / infra / security patch / docs / internal-only]

### 2. Commit list
[列 N 個 SHA + 一句 description，新到舊。用 code block 包，便於複製]

### 3. 內部通知
[團隊內部要知道的：root cause / 改了什麼 / 之後新功能怎麼用 / 三道防線在哪 / 別人加新東西該怎做]
[寫給工程 / ops 同事看，技術細節 OK]

### 4. 對外通知
[要 / 不要對商家或客戶發通知？]
- 不發 → 一句說明「商家無感」
- 發 → 寫好「給客服貼到 LINE / Slack / Email 的版本」

### 5. 部署步驟（已完成）
[git push → CI trigger → image build → service rollout]
[列實際命令 + 對應 service URL + image tag]

### 6. Smoke 結果
[表格列 N 條 smoke check + 結果 ✅/❌]

### 7. Rollback
[每個 service 個別 rollback 指令範例]
[資料庫 schema 變動有沒有 backward compat / 反向 migration]
[「為什麼這 rollback 不影響其他 service」說明]

### 8. 同類風險（看顧的方向）
[1-4 條這次踩過的坑 / 未來相關方向會踩的同類坑]
[每條：現況 + 緩解策略 + 觸發追蹤條件（譬如「商家報告 X 才動」）]
```

**質感要求**：
- §3 / §4 / §8 用完整句子，不只列 bullet — 內部 / 對外通知是要被別人轉貼的，bullet 太乾
- §6 用表格（Markdown table），smoke 結果一眼能掃
- §7 給的指令要可複製貼上，不留 `<placeholder>`（譬如 `<前一 revision>` 要 placeholder 但要說明怎麼查）
- §8 每條都要附「觸發追蹤條件」— 否則就變空泛 risk register

**範例觸發時機**：
- 任何成功 push to prod 後（不論 fix / feature / refactor）
- 用戶問「總結這次發版」/「給內部通知」/「該怎麼跟客戶說」
- 自動接在 smoke pass 後不必等用戶 prompt

**例外（不必出 8 段）**：
- 純 dev / staging push（不上 prod）
- 純 docs PR（沒 deploy）
- 純 internal lint / test cleanup（沒人在意）
