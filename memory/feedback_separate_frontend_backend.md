---
name: 前端 / 後端 commit 必分開
description: 任何同時動 frontend + backend 的改動切兩個 commit；報告分段；設計文件 scope 也分
type: feedback
---

任何同時涉及前端 + 後端的工作 — commit 分、report 分段、design doc scope 也分。純 docs / infra / shared schema 可例外。

**Why:**
- **review 簡單**：reviewer 看「frontend 改了什麼」+「backend 改了什麼」兩條獨立故事
- **rollback 獨立**：發現後端 BUG 不必把前端一併 revert（兩個 service 可獨立部署）
- **責任歸屬**：後端工程師看 backend commit、前端工程師看 frontend commit，git blame 結果乾淨
- **CI/CD 對齊**：如果 backend 部署比 frontend 慢（image build / migration），分 commit 讓部署順序自然
- 對 monorepo 尤其重要：一個 PR / commit 同時 touch backend + frontend 容易隱藏 API contract drift

**How to apply:**

**正常情境**（雙開 feature）：
- Commit 1: `feat(backend): <description>` — backend API + schema + tests
- Commit 2: `feat(frontend): <description>` — UI 接 backend API + e2e test
- 兩 commit 都 build / lint / test 各自全綠才推進下一個

**修 BUG 情境**（root cause 跨層）：
- 先補後端 fix + regression test → commit
- 再補前端 fix + UI 驗證 → commit
- BUG report 也寫成「backend / frontend」兩段，不混

**例外（可以同 commit）**：
- 純 schema migration（DB-only，frontend 不變）
- 純 infra config（Dockerfile / nginx.conf）
- 純 docs 更新
- 純 i18n 字串更新（locale 檔）
- shared types / proto / openapi 一致性更新（contract 同步）

**Report 也分段**：
向用戶報告進度時，「Backend 改了 X」/「Frontend 改了 Y」明確分節 — 不要寫成「我改了 X 和 Y」混在一起，user 不容易掃描。

**Design doc scope 也分**：
模組設計 docs 寫 `M1 backend / M2 frontend` 分開 sub-task，不混在一個 milestone。
