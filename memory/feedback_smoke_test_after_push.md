---
name: 高風險 endpoint push 後必跑 prod smoke
description: 新 endpoint / 對外 API 改動 / cron / webhook / schema 動到的 push 完必驗 routable + auth gate + log
type: feedback
---

任何「新 endpoint / 對外 API 行為改動 / cron / webhook / DB schema / 環境變數 / secret / IAM 改動」的 push 之後 — 必須立刻跑 30 秒 prod smoke，確認部署到位且基本行為正確。

**Why:**
- CI 過 ≠ prod 部署成功（image build OK 不代表 container 起得來）
- prod 環境的 secret / env / IAM 跟 CI / dev 不同，CI 不會抓到
- 「以為 push 完就 ship 了」隔幾小時被用戶/客戶反映 BUG，信任損失大於主動 30 秒驗證
- 高風險路徑（auth / payment / webhook）漏部署 = 商家業務中斷
- 主動驗證後可以在 release notification 寫「smoke 過了」，比「沒驗」可信

**How to apply:**

**push 後必驗的情境**：
- 新增 endpoint（任何 HTTP method）
- 改既有 endpoint 的 auth scheme / permission gate
- 改 secret / env var
- 改 schema migration 已 apply 到 prod DB
- 改 cron 排程或 cron handler logic
- 改 webhook 接收 / dispatcher logic
- 改 CI/CD 工作流 / IaC（Terraform / Cloud Run / K8s）

**Smoke 套件（30 秒內跑完）**：
1. **/health** endpoint 回 200 + `environment=production`
2. **新 / 改 endpoint 的 auth gate**：未認證打 → 預期 status code（401 / 403 / 405）
3. **routability**：每個改動的 endpoint 都 hit 一次，確認不是 404
4. **image tag 對齊**：`gcloud run services describe ... --format='value(image)'` 對到 HEAD SHA（`prod-<40-char-sha>` 或 git tag）
5. **過去 N 分鐘 ERROR log**：`gcloud logging read 'severity>=ERROR' --freshness=15m` 沒新增 ERROR

**驗證指令範本**（依雲端商調整）：
```bash
# Cloud Run image tag 對齊 HEAD
gcloud run services describe <svc> --region=<region> \
  --format='value(spec.template.spec.containers[0].image)'

# 過去 15 分鐘 ERROR log
gcloud logging read 'resource.type=cloud_run_revision AND severity>=ERROR' \
  --limit=10 --freshness=15m
```

**Frontend smoke**（如有）：
- `/` 回 200
- HTML 帶預期 root element（`<div id="root">`）
- 不會 redirect 到 stale host（cache）

**Skip 情境**：
- 純 docs / 純 i18n locale 更新
- 純 test code 改動（不影響 prod binary）
- 純 dev / staging 環境 push（不上 prod）

**Smoke 失敗時**：
- 立刻通知用戶 + revision rollback 指令（不 auto rollback，per R10 prod 操作要人手執行）
- 開 incident task：root cause + 部署順序 + 緩解
