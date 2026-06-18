---
name: 建新 package / 目錄前先查路徑撞名
description: design doc 給的模組路徑是建議不是契約。新建 `internal/X/` 之類的 package / 目錄 / namespace 前先 `ls` + grep 名稱，既有同名 package（不同產品 / feature）會撞名，逼你整批改 package decl + 重做 commit。撞到就用帶意圖的 sub-package。
type: pitfall
---

照 design doc 寫的路徑直接 `mkdir` 新 package，可能跟既有同名 package（完全不同產品 / feature）撞名。一旦兩個 package 在同一路徑各自宣告 `Status` / `Report` / `Generator` 等 type，就編譯衝突，得整批 `mv` + 改每個檔的 package decl + 重生 commit，history 還多一個尷尬的「move」中間步。30 秒的預檢就能完全避免。

**Why:**
- design doc 寫策略不寫實現細節，路徑名是**建議不是契約**
- code reviewer 通常不檢查路徑 collision — 他預設「作者已經 ls 過」，所以這完全是作者預檢責任
- 撞名後的修法（rename + 重 commit）不會炸但純重工，且污染 commit history

**具體案例（Argus）：** 寫月度合規報告時 design plan 指定 `backend/internal/compliance/`，照寫後 lint 才發現該 path 已有另一個 compliance package（SOC2 / ISO27001 control mapping，跟月度 KPI 完全不同產品）。兩邊各自宣告 `Status` / `Report` / `Generator` → 編譯衝突。修法：整批 `mv` 進 `compliance/monthly/` 子 package。

**How to apply:**
- 新建任何 `internal/X/`（或等價的 package / 目錄 / proto package / namespace）前固定跑：

  ```bash
  ls <path>/X/ 2>&1            # 已存在 → 直接用 X/Y/，不爭辯
  grep -rln "^package X\b" .   # 雙保險：哪裡用過這個 package name
  ```

- 任一邊有結果 → 改用帶意圖的 sub-package：`compliance/monthly/`、`drift/scanner/`、`session/replay/`，不要硬擠進已被占用的 top-level 名
- 同理也適用 proto package、前端 module 目錄、任何全域命名空間
