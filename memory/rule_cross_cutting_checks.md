---
name: Cross-cutting checks — 跨層次必查清單
description: 任何 user-visible / data-touching commit 都必過 security / observability / cost / compat 四檢
type: feedback
---

企業級系統的失敗模式跨越層次。每個非 trivial commit 前必過 4 層 cross-cutting 檢查。

**Why:** Unit test 只測 happy path 的單元；lint 只測風格；build 只測 compile。真正打掛企業系統的是：authn 漏洞、observability 黑洞、cost runaway、breaking change 未發布前未發現。這 4 層必須在 commit 前主動覆蓋。

**How to apply:**

### Security 檢查（5 條）

1. **新 endpoint 過 authz interceptor?** — grep ACL middleware / IAM check 是否覆蓋新路徑
2. **input validation?** — proto `[(buf.validate.field)]` 或對應 framework annotation 是否齊全；free-form 字串有沒有 max length / sanitization
3. **SQL injection?** — 全用 prepared statement，沒有字串拼接
4. **secret 不入 git?** — grep 新檔有沒有 API key / password / token 字面值
5. **audit log 覆蓋?** — 寫入操作必記 actor + action + target + ts + result

### Observability 檢查（4 條）

1. **新 endpoint 有 metric?** — request counter + latency histogram + error counter
2. **新 background job 有 trace span?** — 跨 service 的 async chain 必須能在 trace UI 還原
3. **error path 有 structured log?** — `slog.Error(...)` 不只 message，必含 key=value context
4. **新 alert 對應有 runbook?** — alert 觸發後值班知道往哪查；alert 名稱對應 runbook 章節

### Cost 檢查（4 條）

1. **新 query 走 index?** — `EXPLAIN ANALYZE` 看 plan，不能 seq scan 大表
2. **N+1 query?** — 任何 loop 內的 DB call 必須批次化 / join 化
3. **外部 API call 有 rate limit 保護?** — 不要在熱路徑直接打外部，必經 cache 或 batch
4. **新 storage 有 retention?** — 任何新寫入路徑必確認資料生命週期（cleanup runner 或 TTL）

### Backwards Compat 檢查（4 條）

1. **proto field 刪除前 reserved?** — `reserved <num>` + `reserved "<name>"` 兩行都要
2. **API rename 有 deprecation 期?** — 新名稱先上 + 舊名稱保留 N 個版本後再刪
3. **DB migration 有 rollback?** — `up.sql` 對應有 `down.sql`，或在 PR description 描述如何反向
4. **feature flag 上線策略?** — 大改動走 feature flag，gradual ramp + kill switch

### 觸發時機

- M0 design doc 階段：在「§N 安全模型 / 容量 / 失效 / 觀測 / 兼容」對應章節 pre-fill 答案
- M1–MN 實作階段：每個 milestone commit 前主動跑一輪
- M(N+1) 收尾：把上述 4 層的最終狀態寫進 SOP

### 例外（可以略）

- 純 i18n locale 改動
- 純 typo / comment 修正
- 純 lint / format cleanup
- 純 doc 修改

這些 commit 寫 `chore(lint): ...` / `i18n(zh-CN): ...` / `docs(...): ...`，跳過 4 層檢查。

### 缺失時的處理

如果 4 層中有任何一條無法覆蓋（例如新 endpoint 暫時沒有 metric collector），**commit message body 必說明**：

```
NOTE: Observability gap — this endpoint lacks a request counter
because the metrics registry is being refactored under separate
track. Filed follow-up in cleanup-plan.md OQ-OBS-3.
```

不要 silently ship 不完整的 commit。
