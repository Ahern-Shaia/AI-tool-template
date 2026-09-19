---
name: zsh 不對變數做分詞
description: FILES="a b c" 再 $FILES ⇒ 整串當一個路徑;症狀是「No files were processed」
type: pitfall
---

`FILES="a b c"` 然後 `cmd $FILES` —— 在 zsh 裡**整串被當成一個不存在的路徑**
(zsh 預設不 word-split 變數,與 bash 相反)。

症狀:「開始」與「結束」時間戳相同(其實沒跑)· `No files were processed` ·
`ERR_MODULE_NOT_FOUND` 的路徑裡有空格(參數黏住了)。

**修法**:直接把路徑列在命令列;或用陣列 `files=(a b c); cmd $files`;或 `${=FILES}`。
