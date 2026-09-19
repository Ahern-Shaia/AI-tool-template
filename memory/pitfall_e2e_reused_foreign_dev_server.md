---
name: e2e 沿用了別人的 dev server
description: reuseExistingServer 讓「只在 e2e 生效」的設定永遠 false;判別法一行 lsof
type: pitfall
---

`reuseExistingServer: true` + 本機已有一台 dev ⇒ e2e 沿用它,
於是 e2e 專屬的 env(測試資料庫、放寬的 rate limit、關掉的 dev 指示器)
**全部不生效** —— 而症狀是一批看起來像產品缺陷的紅
(429、dev overlay 蓋住元素、看到另一個資料庫)。

**判別法一行**:`lsof -p $(lsof -ti:PORT) | grep -oE '\.next-[a-z]+'`
(或看它讀哪個 dist/env)。乾淨跑 = 先停掉那台。
把這個陷阱寫進 playwright config 的註解 —— 而且**跑之前要真的去讀它**。
