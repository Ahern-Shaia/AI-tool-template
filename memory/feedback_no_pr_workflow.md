---
name: No PR / no reviewer workflow
description: Solo dev — 直接 commit 到 main，不假裝走 PR ceremony 或 reviewer gating
type: feedback
---

直接 commit 到 main / dev 分支，不提 reviewer、不開 draft PR、不等 review approval。

**Why:** 這個專案是 solo developer（或 1-2 人小組）的 setup — 沒有 reviewer 在等。假裝走 PR ceremony 反而拖慢 + 暴露「Claude 不懂這個專案實際 workflow」。

**How to apply:**
- 完成一個 task / milestone 直接 `git commit -m "..."` 到當前分支
- 不要建議「等 reviewer」、「開個 PR 給 X 看」、「讓 DBA review」
- 不要在 commit message 寫 "Co-Authored-By: <某虛構 reviewer>"（只保留 Claude 自己的 Co-Authored-By 簽名）
- Pre-PR Checklist 還是該走（self-review）— 只是沒有真的「PR review」這個 ceremony
- 若用戶後續切到團隊 workflow（找 reviewer），這條 feedback 由用戶明說後更新
