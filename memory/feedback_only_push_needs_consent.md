---
name: 只有 git push 需要明確同意
description: code edit / commit / 本地實驗自由做；每次 git push 必須單獨問再執行（不論主流程 / hotfix）
type: feedback
---

Claude Code 可以自由 edit / commit / 跑 test / 跑本地實驗 — 但**每次 `git push`** 必須單獨向用戶確認再執行。

**Why:**
- `git push` 是「local 工作 → remote / prod」的單向決策邊界
- Mode B（`--dangerously-skip-permissions`）的「移除摩擦」意圖在 local 範圍內成立，但 push 把工作公開 / 觸發 CI/CD / 影響部署
- 用戶往往想在 push 前再 review 一下 commit message 或 trade-off — 不該由 Claude 替他決定 push timing
- prod hotfix 也不例外 — 即使緊急，也應該由用戶按下「OK push」確認，不是 Claude 自決

**How to apply:**

**可以自由做（不必每次問）**：
- `git add` / `git commit`
- Edit / Write 檔案
- `pytest` / `npm test` / 各種測試
- 跑 local dev server 驗證
- `git status` / `git diff` / `git log`
- 跑 lint / format / build
- 開 background Monitor 觀察 build / deploy

**必須單獨問**：
- `git push`（任何分支，任何時機）
- `git push -f`（即使用戶說過要 force push 也再確認，因為破壞性）
- `git push --tags`
- 任何 `gh pr create` / `gh pr merge`

**問的方式**：
報告完成 + 列出 commit 摘要 + 直接問「要 push 嗎？」或「下 push 就上 prod」。不要假設「commit 完就會 push」。

**用戶說「push」後**：
- 直接執行 `git push origin <branch>`
- 設 Monitor 觀察部署（如有 CI/CD）
- 部到位後跑 prod smoke（per `feedback_smoke_test_after_push`）
- 出 release notification（per `feedback_release_notification_format`）

**例外**：
用戶在對話開頭明說「今天所有改動完直接 push 不必問」/「全部都你決定」— 才可省略 push 前確認，但仍須在每次 push 後**明確報告**「已 push」+ Monitor 部署狀態。
