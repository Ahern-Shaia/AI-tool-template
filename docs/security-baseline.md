# 資安基線(security baseline)—— P0 開工即生效

> 從一個真實多租戶 SaaS 專案的資安規範抽取(該專案的完整版含威脅模型六面)。
> **這一份是地板不是天花板**:全部與技術棧無關,新專案第一天生效,不等「資安階段」。
> 專案特定的威脅模型寫進本檔 §0 —— 那是開工前決策(`pre-dev-decisions.md` §一)。

## §0 開工先寫:威脅模型前三名

一句話寫下這個系統**最值錢的資產**與**前三個攻擊面**(範例:動態 SQL 注入 /
跨租戶資料洩漏 / LLM prompt injection)。後面所有取捨用它排優先。
寫不出來 = 還不知道自己在守什麼。

## §1 注入面

- **值一律參數綁定**,任何層都禁字串拼接 SQL
- **動態 identifier(表名/欄名)無法參數化** ⇒ 必須對 metadata 白名單驗證(查無即拒)
  → quote(`quote_ident`/`%I`)→ 跑在最小權限角色 → `statement_timeout` + row limit;
  建立時 identifier 鎖 regex(如 `^[a-z_][a-z0-9_]{0,62}$`)
- LLM 產生的查詢**不是例外**:模型輸出結構化 intent,由你的確定性程式碼編譯,見 §4

## §2 存取控制

- **deny-by-default**;每一條查詢綁 scope(多租戶 = `tenant_id` + DB 層 RLS,
  且 `FORCE ROW LEVEL SECURITY`;app 角色不得 BYPASSRLS、不得擁有表)
- 🔴 **「綁了 tenant ≠ 有權存取這一筆」**(BOLA/IDOR):還要驗「這個人能碰這個 id」——
  根因常是測試只有一位 actor;隔離測試 = A 建 → B 讀不到,**進 CI**
- UUID 不是授權控制;隱藏不是權限(藏起來的東西 API 仍讀得到)
- 租戶識別以**驗證過的 token 為真實來源**,剝除 client 自帶的 header
- 🔴 **測試不得用特權連線遮蔽安全機制**:superuser 跑整合測試 ⇒ RLS 與 grant
  都不執法,**少一條 grant 也是綠的** —— 曾五條測試全綠而真請求 500。
  安全敏感 service 在測試裡走與 prod 相同的低權車道

## §3 認證

- JWT:`verify()` 傳 **algorithms 白名單**、拒 `alg:none`、驗 exp/iss/aud;
  非對稱用 RS256/ES256;token 禁 localStorage
- 密碼 Argon2id;登入面 rate limit + 安全標頭
- 忘記密碼等回應**不可洩漏帳號存在與否**

## §4 AI / LLM 載重不變量(有 AI 功能就適用,無關大小)

- **模型輸出結構化 intent(非 raw SQL/code)→ 確定性程式碼 allowlist 編譯 +
  參數化執行 → 有權限的人核准每個狀態變更 → audit**
- **授權絕不由模型決定**;copilot 跑操作者的權限,每動作 audit
- 間接 prompt injection:**使用者/客戶資料 = 不可信輸入**,不得升權或觸發 tool call
- secret / PII 不進 prompt;LLM 輸出禁未編碼渲染、禁當 code 執行
- NL→查詢走唯讀、scope 過的角色 + timeout

## §5 SSRF 與外呼

- 使用者提供的 URL(webhook/匯入/圖片):擋私網段 + 雲 metadata(`169.254.169.254`)
  + 禁 redirect;有條件就加 egress 白名單
- 所有外部呼叫:timeout + circuit breaker(掛掉時核心功能照常 —— AI/搜尋是非關鍵路徑)

## §6 Secret 與資料

- secret 零進碼零進 git(`.env` gitignore + `.env.example` 只留形狀);
  **從 log、錯誤訊息、LLM prompt 一律 redact**
- DB 角色最小權限、無 SUPERUSER;migration 角色與 app 角色分離
- **金額 = decimal,禁 float**(每幣別小數位 + 明確捨入)
- 帳務/審計資料**不可變**:過帳後不刪不改,錯了開反向沖轉;
  「不可變」寫成**白名單**(哪些欄可改)不是黑名單 —— 黑名單讓新欄位自動可改
- 所有寫入記 audit(actor/action/target/timestamp/result)

## §7 供應鏈

- lockfile `--frozen-lockfile` + `ignore-scripts=true` + 掃描 fail CI
- 🔴 門檻**切在正式相依鏈**不切在嚴重度:`audit --prod` 不得有 high +
  全樹不得有 critical;「它在不在 prod」看**部署腳本那一行**怎麼裝,不看 manifest 分區
- fork 進來的程式碼逐檔 review;授權查證見 AGENTS〈授權與供應鏈〉

## §8 禁清單

回傳 stack trace / DB 錯誤原文給 client · `Math.random()` 產 token ·
自製 crypto · DB 對公網開 · 容器 root · LLM 輸出當 code 執行 ·
無 scope 的跨租戶查詢 · `--no-verify` 跳 hook 上 main

## §9 CI gates(全過才 merge)

secret 掃描(gitleaks 類)· 漏洞掃描(§7 兩道線)· **跨租戶隔離測試**(A 建 B 讀不到)·
循環依賴。⚠️ 「CI 有這條」要定期驗它**真的在跑**(job 0 step 沒 log = 沒開始跑,
不是測試過了 —— 曾靜默死一個月)

## §10 可靠性半頁(資安的鄰居,同樣第一天生效)

- **冪等性**:mutation / webhook / AI 動作 / 對外提交帶 idempotency key —— 重試不重複
- 跨模組副作用走 outbox(crash 不丟事件)
- per-tenant 配額(連線/query cost/LLM token)防 noisy neighbor
- 定期不變量對帳 job(帳要平、庫存 = 異動和),不符告警
