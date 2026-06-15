---
name: Commit message 格式
description: <type>(<scope>): <description> + 中文 body；Co-Authored-By Claude 行預設不加（除非用戶明說要）
type: feedback
---

**Subject** （≤ 70 chars）：
```
<type>(<scope>): <description>
```

- `<type>`：`feat` / `fix` / `chore` / `docs` / `refactor` / `test` / `i18n` / `perf` / `build`
- `<scope>`：模組名 / area，例如 `risk`、`audit`、`webhooks`、`p0-1`
- `<description>`：祈使句現在式（"add CEL evaluator" 不是 "added"）

**Body** （≥ 1 段，技術改動必寫）：
- 描述 *why*（surfaced by what / motivation），不只是 *what*
- 列實際改動的關鍵檔案 + 影響範圍
- 若 cleanup：列 LOC 影響 + 驗證命令
- 若 fix：描述 root cause + 重現步驟（如有）
- 用戶日常語言寫（中英混合可以；技術名詞保原文）

**Footer — Co-Authored-By Claude 行**：

**預設不加**。對話開頭用戶明說「想保留 Claude 簽名」/「commit 帶 Claude trailer」才加。

**Why default off:**
- Solo dev 環境中 `Co-Authored-By: Claude` 是噪音 — git log 看起來像「不是我寫的」
- 公司 / 客戶 audit 看 history 會覺得「這人沒在寫 code」
- 也跟 `claude` 在 commit 提交者欄位產生重複署名感
- 一些公司流程把任何 Co-Authored-By 行視為「外部協作者」會觸發 compliance 流程

**用戶明說要保留的情境**：
- 開源專案想顯示 AI 協作透明度
- 內部 R&D log 追蹤 AI usage
- 「想知道哪些 commit 是 Claude 完成的好統計」

那時就加：
```
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

**範例（不簽 — 預設）**：
```
fix(webhooks): pass projectId when navigating to webhook create/detail

`/projects/<id>/webhooks` "Create" button + row clicks were calling
navigate({ name, params: { ... } }) without projectId. The route
pattern `/projects/:projectId/webhooks/{new,:id}` interpolated the
missing param as empty string, producing `/projects//webhooks/new`
— a path no route matches, which then bounces through the project
layout guard to /landing.

Surfaced during P0-1 smoke testing.
```

**範例（簽 Claude — 用戶明說要）**：
```
fix(webhooks): pass projectId when navigating to webhook create/detail

[same body as above]

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

**反例（不要）**：
```
fix: webhook bug          ← scope 缺，description 空泛
update files              ← 完全沒資訊
WIP                       ← prod commit 不該 WIP
Generated with Claude     ← 這種 trailer 一律不加（即使用戶要簽，用標準 Co-Authored-By）
```
