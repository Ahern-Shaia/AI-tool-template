# ChatGPT Rules

這個目錄保存從 Claude Code starter 轉換而來的 ChatGPT / Codex 專案規則。

## 檔案

- `CHATGPT_PROJECT_INSTRUCTIONS.md`：可直接貼到 ChatGPT Project Instructions，或合併到 Codex 專案根目錄的 `AGENTS.md`。

## 使用方式

### ChatGPT Projects

1. 開啟目標 Project 的 Instructions。
2. 貼上 `CHATGPT_PROJECT_INSTRUCTIONS.md` 全文。
3. 依專案實際技術棧改掉 `[PLACEHOLDER]`。

### Codex / ChatGPT coding agent

把 `CHATGPT_PROJECT_INSTRUCTIONS.md` 的內容合併到目標 repo 根目錄的 `AGENTS.md`。Codex 會優先讀取 repo 內的 `AGENTS.md`，因此這是最容易被持續執行的形式。

## 與 Claude 版的同步

本目錄是 `../CLAUDE.md` + `../AGENTS.md` 的 ChatGPT/Codex 轉換 —— **Claude 版是權威**,
這裡是它的投影。改規則先改 Claude 版,再同步到這裡。

- 2026-09:同步〈通用鐵則〉為 §11 Universal Hardened Rules(MUST 風格,
  stack-independent,客製時不可刪)· §5 profile 改為開工時決定(同 R16 修正)·
  §0 前指向 `docs/pre-dev-decisions.md`(開工前 24 格)。

## 設計原則

這份版本把 Claude Code 特定語彙改成 ChatGPT / Codex 可執行的規則：

- 使用 `MUST / MUST NOT` 式硬規則。
- 明確列出「完成」定義。
- 明確列出必須停下來問人的情境。
- 要求回報實際跑過的指令與失敗原因，不允許假裝已完成。
- 把前端設計、PR 前檢查、FMEA 失效場景反思保留為不可省略流程。
