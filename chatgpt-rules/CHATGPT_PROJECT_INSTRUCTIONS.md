# ChatGPT / Codex Project Instructions

本文件是給 ChatGPT / Codex 在本專案工作的專案級規則。開始任何任務前，必須先理解本文件、根目錄 `AGENTS.md`，以及與任務相關的設計文件。

若本文件與系統訊息、開發者訊息、使用者最新明確要求衝突，遵守優先級更高或更新的要求，並在回覆中明確說出衝突點。若無法執行某條規則，必須說明原因、已採取的替代方案與殘留風險。

---

## 0. Project Identity

> Before filling this section, walk through `docs/pre-dev-decisions.md` with a human:
> 24 kickoff decisions (positioning, denominators, tenancy, licensing policy, visual
> authority, CI shape, collaboration gears). Each has a real-project cost attached.


- **Name**: `[PROJECT_NAME]`
- **Purpose**: `[一句話描述產品 / 系統做什麼]`
- **Languages**: `[Go / Python / TypeScript / etc]`
- **Runtime**: `[single binary / K8s / SaaS / etc]`
- **License**: `[MIT / Apache-2.0 / proprietary / TBD]`
- **Git remote**: `[origin URL or TBD]`
- **Current state**: `[greenfield / refactor / migration / maintenance]`

---

## 1. Non-Negotiable Agent Rules

### 1.1 Execution Discipline

- MUST inspect the existing code and project conventions before editing.
- MUST keep changes scoped to the user's request.
- MUST preserve user changes already present in the working tree.
- MUST NOT run destructive commands such as `git reset --hard`, `git checkout --`, broad deletes, or force pushes unless the user explicitly asks for that exact operation.
- MUST NOT use `--no-verify` to bypass git hooks.
- MUST NOT claim a task is complete unless the required format, lint, test, and build checks have either passed or been explicitly reported as unavailable with reasons.
- MUST report the exact commands run during verification and their result.
- MUST use `rg` / `rg --files` first for local search when available.
- MUST use concise comments only for non-obvious code.
- MUST avoid unrelated refactors, formatting churn, and dependency changes.

### 1.2 Stop And Ask

Stop and ask the user before proceeding when any of the following is true:

- A change modifies architecture, data model, public API, authentication, authorization, audit, billing, or production behavior.
- A change requires DB schema changes, migrations, or destructive data operations.
- Business logic is ambiguous and cannot be inferred safely from code or docs.
- The task requires adding a third-party dependency.
- Existing tests must be disabled, weakened, deleted, or bypassed.
- A large rename, deletion, file move, or cross-module rewrite is needed.
- Production deployment, production SQL, production data mutation, or credentials are involved.

Exception: if the user explicitly says the agent may decide, proceed only within the stated scope and document the decision.

### 1.3 Safety And Security

- MUST NOT hard-code secrets, API keys, passwords, tokens, private URLs, or credentials.
- MUST use environment variables or a secret manager for secrets.
- MUST use prepared statements or ORM parameter binding for SQL.
- MUST NOT build SQL by string concatenation using user-controlled data.
- MUST add or preserve audit logs for write operations where the project has audit logging. Audit logs should include actor, action, target, timestamp, and result.
- MUST include unit and integration tests for security-sensitive modules. Target coverage is greater than 80% for authentication, authorization, audit, and billing paths.

---

## 2. Project Architecture

> Rewrite this section for each project.

- Database schema is defined in `[path]`.
- Migration files are in `[path]`.
- Database table mappings are in `[path]`.
- Backend source is in `[path]`.
- Frontend source is in `[path]`.
- API schemas / proto files are in `[path]`.
- Module design docs are in `docs/modules/`.

---

## 3. Development Workflow

After code changes, run the workflow for every affected area. Repeat auto-fix and lint until zero issues when the tool may cap reported issues.

### 3.1 Backend Changes

1. **Format**: `[gofmt -w / cargo fmt / ruff format / etc]`
2. **Lint**: `[golangci-lint run / cargo clippy / ruff check / etc]`
3. **Auto-fix**: `[--fix flag if supported]`
4. **Test**: run relevant tests before committing
5. **Build**: confirm production-grade build succeeds
6. **Tidy deps**: after dependency changes, run `[go mod tidy / cargo update --workspace / etc]`

### 3.2 Frontend Changes

1. **Fix**: `[pnpm fix / npm run fix]`
2. **Check**: `[pnpm check]`
3. **Type check**: `[pnpm type-check]`
4. **Test**: `[pnpm test]`

Recommended default commands:

```bash
pnpm --dir frontend i
pnpm --dir frontend dev
pnpm --dir frontend fix
pnpm --dir frontend check
pnpm --dir frontend type-check
pnpm --dir frontend test
```

### 3.3 Proto / API Schema Changes

1. **Format**: `buf format -w proto`
2. **Lint**: `buf lint proto`
3. **Generate**: `cd proto && buf generate`
4. **Commit generated files** with the source schema change

### 3.4 Docs-Only Changes

For docs-only changes, tests and builds are not required unless the edited docs include generated examples or code that the project normally validates. The final response must explicitly say the change was docs-only.

---

## 4. Design Before Risky Implementation

For non-trivial modules or high-risk changes, do not implement first. Create or update `docs/modules/<module>.md` using `docs/modules/_template.md`.

Use this milestone flow:

- **M0**: write design doc, list open questions as `OQ-<MODULE>-<N>`, wait for user decision.
- **M1-M3**: implement scoped sub-tasks, one coherent commit per milestone when commits are requested.
- **M4**: docs cleanup, status update, and verification summary.

The design doc must cover:

- Goals and non-goals
- API / data model / state transitions
- Migration and compatibility plan
- Security model
- Observability
- Capacity / cost impact
- Rollout and rollback
- Open questions
- FMEA failure scenario review

### FMEA Failure Scenario Review

Before marking a feature complete or production-ready, produce a failure scenario review. For each entry point, external call, state transition, concurrency point, and deployment step, list:

- Failure mode
- Impact
- Severity: `P0`, `P1`, or `P2`
- Mitigation status: `mitigated`, `residual`, or `external gate`

No unmitigated `P0` may be marked production-ready. For small changes or hotfixes without a design doc, include a brief FMEA summary in the final response.

---

## 5. Frontend / UI Rules

Before producing any frontend mockup, component, layout, or style, read `docs/frontend-design-principles.md`.

MUST follow:

- Apply `docs/frontend-design-principles.md` §A universal core.
- Run §C design loop before implementation.
- Use the project-selected §B aesthetic profile. The profile MUST be chosen at project
  kickoff from the target users' mental model and measured competitor references
  (see `docs/pre-dev-decisions.md` §2) — never defaulted. A locked-in default was
  overturned in production once: users wanted "paper", the default gave them SaaS chrome.
- Use semantic design tokens; do not hard-code hex colors unless the design system explicitly requires it.
- Use `gap-*` for spacing in component groups.
- Build all expected states: loading, empty, error, disabled, hover, focus, active, and responsive behavior.
- Preserve accessibility: semantic HTML, keyboard navigation, focus states, labels, contrast, and reduced-motion handling.
- Avoid default-looking UI. The result must fit the product, brand, and chosen profile.
- Watch CSS specificity. Avoid rules where section, element, and utility selectors accidentally cancel padding or margin.

---

## 6. Code Style

- Follow Google style guides where applicable.
- Prefer clean, minimal, maintainable code.
- Use American English naming.
- Avoid vague names and plural suffixes like `xxxList` unless the type truly represents a collection.
- Sort and group imports according to language conventions.
- Be explicit but concise about error cases.
- Keep public interfaces stable unless the user approved a breaking change.
- Prefer existing project patterns and helper APIs over new abstractions.

---

## 7. Pull Request Rules

Before running `gh pr create`, walk through `docs/pre-pr-checklist.md`.

PR title format:

```text
<type>(<scope>): <description>
```

Examples:

```text
feat(risk): add CEL evaluator
fix(audit): handle nil context
```

PR description must include:

- Purpose
- What changed
- Testing performed
- Risk / impact
- Rollout or rollback notes when relevant

Follow Google's code review guidance: authors own clarity, timely replies, and resolving comments.

---

## 8. Git And Commit Rules

- MUST run `git status` before committing or staging.
- MUST NOT include unrelated files in commits.
- MUST NOT rewrite user changes.
- MUST NOT force-push `main`.
- MUST NOT use `--no-verify`.
- MUST commit generated files alongside proto / API schema source changes.
- Commit messages should follow the project convention in `[path or rule]`.

---

## 9. Definition Of Done

A task is done only when all applicable items are true:

- The requested behavior or document change is implemented.
- The diff is scoped and free of unrelated churn.
- Formatters were run for changed code.
- Linters passed, or failures are reported with exact blockers.
- Relevant tests passed, or unavailable tests are reported with reasons.
- Production build passed for code changes, or the reason it was not applicable is stated.
- Dependency tidy / lockfile updates were handled when dependencies changed.
- Generated files were updated when schemas changed.
- FMEA was added for high-risk or production-bound changes.
- Final response includes changed files and verification commands.

Never hide failures. If verification cannot be completed, say so plainly and list residual risk.

---

## 10. Build / Test Command Placeholders

Rewrite this section per project.

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

---

## 11. Universal Hardened Rules

Extracted 2026-09 from a real production project (3 months, solo + AI). Every rule
below was paid for. They are stack-independent — do not delete when customizing.

Claims and verification:

- When you write "the codebase has no X", you MUST include how you checked
  (the exact grep, file, date) in the same sentence. Premises go stale the day
  they are written; seven wrong premises were caught in a single session.
- A "not found" verdict requires two DIFFERENT lookups: exact name + loose stem.
  Two lookups using the same vocabulary (e.g. a competitor's terms against your
  own repo) count as one. Before saying "we don't have it", you MUST be able to
  say how the project DOES solve that need — if you can't, you don't understand
  the feature yet.
- Output of a proxy metric (script, heuristic, checklist) is not an answer.
  Spot-check real files before reporting. A check that returns exactly one hit
  is suspicious. A lopsided result (all zeros, all hits, identical numbers
  across different subjects) means the measuring stick is broken.
- Measurement probes fail silently: they return plausible-looking numbers.
  Self-checks need BOTH a positive control (something just shipped) and a
  negative control. Truncated tool output looks exactly like the end of a list —
  read the summary count, do not count grepped lines.

Delivery:

- If the task contains a universal quantifier ("100%", "all", "everything",
  "no leftovers"), the FIRST section of your report MUST be a gap table that
  splits the user's own words item by item into done / not done / partial.
  Write that table when you START, not when you finish.
- When comparing a build against a mockup, report ONLY the differences,
  starting with the count. Listing what matches is confirmation bias, not
  comparison.
- Before reporting "all green": the scope you ran MUST equal the CI scope;
  check the total test count (a 21-test green report looks identical to a
  2,245-test one); for background runs, "Running N tests" MUST match the final
  "N passed" — exit code 0, a "passed" status file, and zero failures can all
  be true while the run died halfway.
- Before shipping a feature, grep for its call sites. "Table, service,
  endpoint and tests all exist but nothing calls it" passes type checks and
  tests. After fixing something, grep for who still records the old state.

Rules and checks:

- A rule without an automated check WILL drift. Land the rule and its check in
  the same commit. The converse holds: CI also locks in wrong rules — changing
  the prose without the allowlist changes nothing.
- A check that exists is not a check that runs. Four failure shapes: the
  pre-ship list omits it; nobody runs the list; the command it names does not
  exist; it has never passed even once. The fix is a maintained "what runs
  before shipping" list — executed as a list, not from memory.
- Mutation-test new guards with PARTIAL degradation (change one value, drop one
  list item), not wholesale removal. Verify the mutation actually changed the
  file (`diff -q`) before trusting a green result.

Licensing and supply chain:

- Never trust the SPDX field alone: it returns NOASSERTION for real licenses,
  and rider clauses never appear in it. Read the LICENSE body.
- A non-compete clause can override a permissive main license. Its verb is
  "use to develop", not "copy" — downloading and reading IS use. When you need
  to learn from a competitor with such a clause, use official docs for
  behavior and a same-category MIT project for implementation.
- Prod/dev is a property of the deploy script line, not of the manifest
  section. To know whether a package ships, read how the image installs.

Frontend verification (see `docs/frontend-testing.md`):

- A frontend change is done only after driving a REAL browser through the user
  flow (Playwright; assert on a11y tree / DOM, screenshots as backup).
  "It renders" is not "it can be operated": schema, render, and operability are
  three layers, and the first two being green says nothing about the third.
- Flows walked manually MUST be frozen into Playwright specs that run in CI —
  and each spec MUST have passed at least once before commit. AI-driven browsing
  is for exploration only, never in CI.
- Every "it must block X" assertion needs its inverse ("legal X must pass") —
  otherwise block-everything also goes green. Assert the number, not just the
  keyword. Substring locators mis-hit; input values are properties that
  `hasText` cannot read.
- When a whole e2e suite goes red, isolate before diagnosing (45 reds once
  reduced to 4 real ones); count timeouts separately from failures; check
  whether the load is your own forgotten server, and whether the suite reused
  a foreign dev server (its env vars silently never applied).
- For layout complaints, measure surfaces and boxes first (background, box
  layers, container width) side by side — "everything present but wrong-looking"
  is more common than missing parts. Read source for settings, screenshots for
  overflow: a screenshot cannot show a variant behind `disabled`.

Security baseline (P0 from day one — see `docs/security-baseline.md` for the full list):

- Bind every value as a parameter; dynamic identifiers (table/column names) MUST be
  validated against a metadata allowlist, then quoted, then run under a least-privilege
  role. String concatenation into SQL is forbidden at every layer.
- Deny by default. Tenant scoping is NOT authorization: also verify this actor may
  touch this specific id (BOLA). Isolation tests ("A creates, B cannot read") run in CI,
  with at least two actors — a single-actor test structurally cannot catch this.
- Tests MUST NOT use privileged DB connections for security-sensitive services:
  a superuser bypasses RLS and grants, so a missing grant stays green. Five green
  integration tests once hid a 500 on the first real request.
- AI/LLM invariants: model emits structured intent (never raw SQL/code) → deterministic
  code compiles it against an allowlist → a permissioned human approves state changes
  → audit. Authorization is NEVER decided by the model. User data is untrusted input
  (indirect prompt injection); secrets/PII never enter prompts; LLM output is never
  rendered unencoded or executed.
- JWT: pass an algorithms allowlist, reject `alg:none`, verify exp/iss/aud. Money is
  decimal, never float. Audit/ledger data is append-only — corrections are reversals.
- Secrets never enter code or git, and are redacted from logs, error messages and
  LLM prompts. Migration role is separate from the app role.

Performance floor (stack-agnostic, day one — see `docs/performance-baseline.md`):

- Write three numbers before any optimisation talk: p95 target (read / write / background),
  max response payload, max outbound calls per request. Put them in CI as thresholds,
  not on a wall as slogans. A threshold encodes the RULE (`p95 < 300ms`), never the
  CURRENT NUMBER (`p95 < today's 287ms`) — the latter goes red on normal noise and
  then gets loosened into meaninglessness.
- Measurement scripts are wrong silently: probes return numbers that look perfectly
  normal. Self-check with BOTH a positive and a negative control — a negative control
  alone cannot catch "the probe never ran".
- N+1 is the most common bottleneck and is invisible at dev-sized data. Assert the
  QUERY COUNT in tests; code review does not catch it.
- Every outbound call needs a timeout: most clients default to waiting forever, so
  "unset" is not "a sensible default", it is betting the other side always answers.
  One deadline per request, propagated; retries bounded, backed off, jittered, and
  only for idempotent operations.
- Cache keys MUST carry every authorization dimension (tenant / user / role). A missing
  dimension is not a performance bug, it is cross-tenant disclosure. Write the
  invalidation strategy before writing the cache.
- No unbounded anything: queries, fan-out, queues. An unbounded queue trades latency
  for OOM. Pool size × instance count must stay under the database connection limit.

Stack rule attachment (`docs/stack-rules/<stack>.md`):

- After the stack is confirmed, one attachment applies. It states what the two floors
  above look like IN THAT STACK. No attachment yet → generate one against the fixed
  16 dimensions in `docs/stack-rules/_generator.md` (S1–S8 security, P1–P8 performance),
  then have a human review it. Freely-generated rules have no denominator: you cannot
  tell what is missing. Every dimension needs a verdict — a rule, "covered by X in this
  stack", or "not applicable + why". Blank is not a verdict.
- Every rule names its enforcement point (config flag / lint rule / CI job / grep guard).
  No enforcement point → it is a convention, not a P0. A rule without a check always drifts.

User-facing text:

- Error messages MUST tell a non-technical user what went wrong and what to do
  next. The biggest hole is the fallback: a translator ending in
  `return error.message` puts raw validator output on screen while looking
  handled. Fallbacks return a generic actionable sentence; raw text goes to
  logs.
- Destructive actions MUST state three things before the click: what will
  happen (itemized), whether it can be undone (with retention period), and
  what will NOT happen — the last one is actionable information, not a
  disclaimer.

---

## 12. Project-Specific Pitfalls

> Add project-specific warnings here.

- Example: JSONB columns store JSON marshalled by `protojson.Marshal`, which produces camelCase keys.
- Example: tables with composite primary keys must use the full primary key in `WHERE`, `JOIN`, `DELETE`, and `UPDATE` predicates.
- Example: all UI strings must live in locale files.
