---
name: 截圖看不出 variant
description: disabled 把 primary 畫成次要;設定看原始碼,溢出看截圖
type: pitfall
---

看截圖判「三顆按鈕全是次要樣式」而它早就是 primary —— 當下的 `disabled`
把 variant 抹平了。反過來:字級改大把工具列撐爆,只有截圖看得到。

**規則:設定看原始碼,溢出看截圖** —— 兩邊都要,用對邊。
截圖上長一樣的東西(公式欄 vs 帶入欄、兩種 read-only)要用資料或原始碼分開。
