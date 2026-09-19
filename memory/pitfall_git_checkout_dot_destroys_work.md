---
name: git checkout -- . 會毀掉全部未提交工作
description: 變體:拿 stash 查一件事、清理腳本認不出就刪
type: pitfall
---

`git checkout -- .` / `git restore .` 秒殺所有未提交改動,無法復原。
變體:為了「查一下乾淨狀態」隨手 `git stash` 然後忘了 pop / 弄丟;
清理迴圈「保留清單比對失敗」⇒ 認不出來就刪 = 全刪(預設方向要反過來:
認得出來才刪)。

**規則**:任何會丟工作區改動的指令前,先 `git status` + 必要時 `git stash push -m`
帶名字;批次清理的預設是**跳過**不是刪除;回退單檔用明確路徑,不用 `.`。
