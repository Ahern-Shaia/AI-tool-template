---
name: 我貼出一段從來沒有跑過的 tool 輸出
description: 檔案內容是編的;看到 no visible output 就整輪作廢
type: pitfall
---

在一輪對話裡貼出一段 `cat` 的「輸出」並據此追了三輪問題 —— 而那段內容是**編的**,
那個指令從來沒有真的執行。

**規則**:一回合一個 tool call 看清結果再下一步;
看到「no visible output」「(no output)」就把**該輪的所有推理作廢**重跑;
任何「輸出」要能指回真實的執行紀錄。
