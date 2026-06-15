---
name: Project Brain MCP
description: .brain/ 已內建（若有），任務開始 get_context、任務完成 complete_task、發現 Pitfall / Rule / Decision 即 add_knowledge
type: reference
---

Project Brain 是一個 MCP server，存放跨 session 的 structured knowledge graph（Pitfall / Rule / Decision 三種節點 + confidence score）。

**檢查是否安裝**：
```bash
ls .brain/ 2>/dev/null
ls .claude/CLAUDE.md 2>/dev/null
```

**有安裝的話**：
- 任務開始：呼叫 `get_context(task_description, current_file, workdir)`
- 任務完成：呼叫 `complete_task(task_description, decisions[], lessons[], pitfalls[])`
- 發現新 bug / 規則 / 架構決策：立即 `add_knowledge(kind="Pitfall"|"Rule"|"Decision", ...)`

**沒安裝的話**：
- 不要嘗試「假裝呼叫」brain MCP — 會 silent fail
- 依賴本地 `~/.claude/projects/<encoded-path>/memory/` 系統就好

**應存到 Brain 的內容**：
- 架構決策（"我們用 connectrpc 不用 grpc-gateway，因為 ..."）
- 領域知識（"composite-PK rule 是因為 BYT-9259 事故"）
- 生產踩坑（"useEffect 不能 gate on hasPermission，race condition"）
- 模組間 contract

**不應存的內容**：
- 程式碼本身（在 Git 裡）
- 一次性 debug 過程
- 個人 preferences（這些放 `~/.claude/projects/.../memory/feedback_*.md`）
