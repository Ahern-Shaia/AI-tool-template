---
name: 綁了 tenant_id ≠ 有權存取這一筆
description: BOLA/IDOR;根因常是測試只有一位 actor
type: pitfall
---

查詢綁了租戶 scope,不代表**這個人**有權碰**這個 id** —— 同租戶的另一個使用者、
另一個角色、另一張表單的記錄 id 塞進來,scope 全過。

**修法**:object-level authz 是獨立的一層(scope + ownership/role 都要);
**測試至少兩位 actor**(只有一位 actor 的測試結構上測不到這件事);
隔離測試「A 建 → B 讀不到」進 CI。UUID 難猜不是授權;隱藏不是權限。
