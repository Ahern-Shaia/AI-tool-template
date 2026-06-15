---
name: 全綠才算完成
description: 每 task 結束跑完整 format + lint + build + test；lint repeat 直到 0 issues
type: feedback
---

CLAUDE.md R8 強制：每個 task 完成後必須跑完整測試 + lint + build，全綠才算完成。

**Why:** 半綠的 commit 進到 main 後，下一次有人動同一處 code 會看到「先存在的」lint warning，分不清楚是自己寫的還是繼承的。Lint 工具有 max-issues 上限，第一次跑可能漏報 — 必須 repeat。

**How to apply:**

**Backend task 完成後**：
1. `gofmt -w` 改動的檔（或對應語言的 formatter）
2. `golangci-lint run --allow-parallel-runners` — 重複跑直到 0 issues
3. `go build ./...` 必須 exit 0
4. `go test ./<相關 package>` 跑相關測試
5. 涉及 proto：`cd proto && buf format -w . && buf lint . && buf generate`，然後 commit generated files

**Frontend task 完成後**：
1. `pnpm --dir frontend fix` — 自動修 ESLint + Biome
2. `pnpm --dir frontend type-check` exit 0
3. 涉及 UI：手動冒煙至少一頁
4. 注意 `pnpm fix` 可能會順手 reformat 不相關的 locale 檔 — 用 `git checkout <path>` 把不相關的 noise revert 掉，只保留真實改動

**Commit 前**：
1. `git status` 確認預期外的檔有沒有混進來
2. `git diff` 自我審查
3. 涉及機密：grep secret / API key / password

**例外（可以暫時不全綠）**：
- WIP 階段在 feature branch（但 main 不可以）
- 用戶明確說「先 commit 不要等 test」

**遇到 pre-existing lint error**：
- 屬於同個檔且容易修：順手修
- 跨檔範圍大：開 follow-up commit `chore(lint): clean up <scope>` 單獨處理，**不混入** feature commit
