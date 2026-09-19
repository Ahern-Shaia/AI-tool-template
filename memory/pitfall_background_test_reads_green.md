---
name: 背景測試說綠,而它在第 25 條就斷了
description: exit 0 / status passed / 零失敗三個訊號都可能是假的
type: pitfall
---

背景跑的全套回報 exit 0、`.last-run.json` 寫 passed、log 零失敗 ——
**三個訊號全是假的**:它在第 25 條就被中斷了。

成因:`nohup … & | tail` 的 **exit code 是 shell/tail 的**(pipefail 沒設);
`.last-run.json` 記「有沒有紅」**不記「跑完了沒」**;`test:fails` 讀的是上一次的報告。

**判別法只有一個而且很便宜**:`Running N tests` 要對得上結尾的 `N passed`。
配套:junit/json reporter 寫在測試設定裡(與怎麼呼叫無關),紅燈的名字才活得過你的 pipe;
⚠️ 命令列 `--reporter=line` 會**整個取代**設定裡的清單,不是附加。
