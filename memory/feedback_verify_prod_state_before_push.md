---
name: 事先檢查 prod state 才 push
description: schema / env / secret / IAM / infra 變動類 commit push 前必驗 prod 對應狀態已就緒；query 確認後才 push code
type: feedback
---

凡是依賴 prod state（DB schema column / env var / secret / IAM 角色 / infra resource）的 code 改動 — **push code 之前必須先驗 prod 對應 state 已就緒**，不可「先 push code 看 CI 過不過再說」。

**Why:**
- code expect 一個 schema column / env / secret / role 在 prod 上，但 prod 還沒有 → 部署成功但 runtime 500
- 真實案例（generic 改寫）：SQLAlchemy `SELECT *` 對應 ORM model 多了一個 column，prod DB migration 未跑 → 整個 endpoint 5xx → 商家業務中斷直到 rollback
- CI / staging 環境跟 prod 環境不對等是常態，不能假設
- Schema/env mismatch 的 BUG 在 CI 抓不到（CI 用 fresh DB / mock），只在 prod 爆

**How to apply:**

**Code commit 前必驗 prod state 的情境**：

| 改動類型 | 驗證對象 | 命令範本 |
|---|---|---|
| SQLAlchemy / ORM model 加 column | prod DB 該 column 存在 | `psql "$PROD_DB_URL" -c "\d <table>"` |
| New required env var | Cloud Run / K8s 已設 env | `gcloud run services describe ... --format='value(spec.template.spec.containers[0].env)'` |
| New secret | Secret Manager 已建 secret | `gcloud secrets list \| grep <name>` |
| New IAM role | service account 已 grant | `gcloud projects get-iam-policy ... --flatten="bindings[].members"` |
| 改 cron 排程 | Cloud Scheduler / cronjob 已部 | `gcloud scheduler jobs describe ...` |
| 改 pub/sub topic | topic + subscription 已建 | `gcloud pubsub topics list` |

**驗證後**：
- ✅ Prod state 已就緒 → push code
- ❌ Prod state 缺 → **先讓用戶手動補 prod state（per R10 prod 操作必須人手執行）**，補完再驗，再 push code

**順序硬規則**：
```
1. user 跑 migration / 補 env / 建 secret on prod (R10 人手)
2. user 確認「done」
3. Claude 驗 prod state（query）
4. Claude push code
5. CI / Cloud Build 自動部署
6. push 後跑 smoke（per feedback_smoke_test_after_push）
```

**例外**：
- 純 frontend UI 改動（不依賴新 backend state）
- 純 docs / locale / test code 改動
- 改既有 endpoint 但不依賴新 state（純 logic refactor）

**Anti-pattern**：
- ❌「我先 push 看 CI 過不過再說」— CI 過不代表 prod 起得來
- ❌「假設 user 已經跑 migration 了」— 必須 query 確認
- ❌「user 說 done 就直接 push」— user 可能跑錯環境（指向 dev DB 而非 prod DB）；query 第二輪驗證
