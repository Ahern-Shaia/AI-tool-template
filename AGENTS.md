This file provides guidance to AI coding assistants when working with code in this repository.

## Project Architecture

> 依專案改寫。範例：
- Database schema is defined in `[path]`
- Migration files are in `[path]`
- Files in `[path]` are mappings to the database tables

## Development Workflow

**ALWAYS follow these steps after making code changes:**

### Backend Code Changes

1. **Format** — [`gofmt -w` / `cargo fmt` / `ruff format` / 依語言]
2. **Lint** — [`golangci-lint run` / `cargo clippy` / `ruff check`]
   - **Important**: Run lint repeatedly until 0 issues (lint tools have max-issues limits)
3. **Auto-fix** — [`--fix` flag if supported]
4. **Test** — Run relevant tests before committing
5. **Build** — Confirm production-grade build still succeeds
6. **Tidy deps** — After dep upgrades, run [`go mod tidy` / `cargo update --workspace` / etc]

### Frontend Code Changes

1. **Fix** — [`pnpm fix` / `npm run fix`] auto-fix ESLint + Biome / Prettier
2. **Check** — [`pnpm check`] validate without modifying (for CI)
3. **Type check** — [`pnpm type-check`]
4. **Test** — [`pnpm test`]

### Proto / API Schema Changes

1. **Format** — [`buf format -w proto`]
2. **Lint** — [`buf lint proto`]
3. **Generate** — [`cd proto && buf generate`]
4. **Commit generated files** alongside the source change

## Build/Test Commands

> 依專案調整。範例：

### Backend

```bash
# Build
[build command]

# Run single test
[test runner with single-test syntax]

# Lint
[lint command]
```

### Frontend

```bash
pnpm --dir frontend i
pnpm --dir frontend dev
pnpm --dir frontend fix
pnpm --dir frontend check
pnpm --dir frontend type-check
pnpm --dir frontend test
```

### Database

```bash
# Connect to local dev DB
[psql / mysql / etc command]
```

## Code Style

### General

- Follow Google style guides for all languages
- Write clean, minimal code; fewer lines is better
- Prioritize simplicity for effective and maintainable software
- Only include comments that are essential to understanding functionality or convey non-obvious information

### Naming

- Use American English
- Avoid plurals like "xxxList"

### Imports

- Use organized imports (sorted by import path)

### Formatting

- Use linting/formatting tools before committing

### Frontend / UI design

- 任何前端產出（mockup / 元件 / 版面 / 樣式）動手前先過 [`docs/frontend-design-principles.md`](docs/frontend-design-principles.md)：**§A 普世核心**（刻意 > 出廠預設、token、a11y、動效、先研究、全狀態、響應式、複用）一律適用；**§B 美學 profile** 每專案挑一個（預設 `modern-SaaS-craft`）。
- 元件走語意 design token、禁硬編 hex；spacing 用 `gap-*`。產出後自問「這是不是出廠預設樣 / 有沒有貼品牌與 profile？」

### Error Handling

- Be explicit but concise about error cases

## Pull Request Guidelines

**Before running `gh pr create`, walk through [`docs/pre-pr-checklist.md`](docs/pre-pr-checklist.md).**

- **Code Review** — Follow [Google's Code Review Guideline](https://google.github.io/eng-practices/)
- **Author Responsibility** — Authors drive discussions, resolve comments, merge promptly
- **Description** — Clearly describe what the PR changes and why
- **Testing** — Include information about how the changes were tested

## Common Lint Rules

> 依專案語言調整。Go example:

- **Unused Parameters** — Prefix unused parameters with underscore
- **Modern Go Conventions** — Use `any` instead of `interface{}`
- **Confusing Naming** — Avoid similar names differing only by capitalization
- **Identical Branches** — Don't use if-else branches with identical code
- **Function Receivers** — Don't create unnecessary receivers
- **Proper Import Ordering** — Maintain correct grouping
- **Consistency** — Keep function signatures, naming, and patterns consistent

## Miscellaneous

> 把專案特有的「踩坑警告」放這裡。範例：
> - The database JSONB columns store JSON marshalled by `protojson.Marshal` in Go code, which produces camelCase keys (`task_run` becomes `taskRun`)
> - When modifying multiple files, run modifications in parallel whenever possible
