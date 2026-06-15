---
name: 企業級執行 — autonomous + rigor 雙高
description: 用戶開了 --dangerously-skip-permissions 不是要降低標準，是要 Claude 主動加深度。批次推進但跨層次檢查不可省。
type: feedback
---

用戶執行 Claude Code 時帶 `--dangerously-skip-permissions`，含意是「不要為了確認小事打斷我，把時間花在加深度」。**摩擦消失 ≠ 標準降低，而是用節省的時間執行更嚴格的企業級檢查**。

**Why:** 企業級商用系統的失敗成本（資料外洩、規模化 down time、合規違規、跨地區 SLO 違約）遠高於小步驟確認的時間成本。任何「快但漏掉 cross-cutting concern」的 commit 都是技術債的長期累積。

**How to apply:**

### 1. 模組設計（M0 design doc）擴張深度

舊版 design doc 範本 §1–§12 不夠。企業級必須加：

- **§N 安全模型** — Threat model：authn / authz / input validation / rate limit / audit trail 完整路徑；攻擊面列出（external user / internal user / lateral / supply chain）
- **§N 容量規劃** — 預估 QPS / 資料量 / blast radius；如果是寫入路徑，描述 contention + lock scope；引用 Little's law 計算 worst-case latency
- **§N 失效模式** — 每個 external call 列：timeout / retry policy / circuit breaker / fallback；DB tx 邊界；async job 的 dead letter 處理
- **§N 觀測性** — 提案要加哪些 metrics（histogram + counter）/ traces（span 名稱）/ structured logs（key fields）/ alerts（threshold + severity + runbook link）— 不是事後補，是 design 階段就決定
- **§N 資料生命週期** — retention 期 / PII 標記 / GDPR right-to-erasure 怎麼處理 / encryption at rest+transit / 跨地區複製限制
- **§N 向後兼容** — proto field reservation / API versioning / migration rollback path / feature flag rollout 策略（gradual ramp / kill switch）
- **§N 成本模型** — 預估每個 user-action 觸發的 DB query 數 / external API call 數 / 額外 storage / 額外 compute — 用 1000 daily-active 假設算月成本量級

每條 OQ-N 必須帶**安全/效能/成本 trade-off 一句話評語**。

### 2. 實作階段（M1–MN）做事順序

收到「動工」signal 後不要再停下來請示，但**每個 milestone commit 前必跑 cross-cutting checks**：

| 檢查 | 命令範例 | 阻塞 commit? |
|---|---|---|
| Format | `gofmt -w` / `cargo fmt` / `pnpm fix` | ✅ 必過 |
| Lint | `golangci-lint run` repeat until 0 | ✅ 必過 |
| Build | full production build | ✅ 必過 |
| Unit test | 相關 package 全跑 | ✅ 必過 |
| Type check | `pnpm type-check` | ✅ 必過 |
| **Threat model 回查** | grep `IsFeatureEnabled` / authz path 是否覆蓋 | ✅ 必過 |
| **Audit log 回查** | 寫入路徑是否都記 audit | ✅ 必過 |
| **Observability 接入** | 是否新增 metrics / traces / logs | ⚠️ 文件記錄；缺失需於 commit message 說明 |
| **Smoke test** | 至少一條 happy path + 一條 failure path | ✅ user-visible 改動必跑 |
| **Performance baseline** | 改動 critical path 前後對比 | ⚠️ 性能敏感路徑必跑 |

不要等用戶 prompt 才跑這些 — 模組落地 M(N) commit 前**主動**全跑一輪。發現 cross-cutting 漏洞**就地補**，不另闢 follow-up。

### 3. 自主使用工具的範圍擴張

`--dangerously-skip-permissions` 之下：

- **平行 Agent 派遣** — 大範圍 audit / 跨檔搜索 / 平行驗證直接派 `subagent_type=Explore` 或 `general-purpose`，不再每次問
- **背景 Monitor** — 長執行的 build / test 用 `Bash run_in_background: true`，繼續往下推進其他任務
- **試錯式探索** — 不確定行為直接寫一個 minimal repro 跑看看，不問用戶
- **重啟 dev server / 重 build binary** — 用戶已授權重啟，直接動手不等確認
- **清掃式 cleanup** — 撞到 dead code / dead path / stale config 順手清，不另闢 task

**仍然必停下來的情境**（這些不是「摩擦」是「真分歧」）：

| 情境 | 為什麼必停 |
|---|---|
| **「砍 / 留」決策** | 影響範圍要由產品方判斷 |
| **「方案 A / B」架構選擇** | R6 強制 |
| **新建 DB 表 / 改 schema** | R1 + R6 |
| **跨 module 重 API** | 影響面用戶比我清楚 |
| **business logic 模糊** | 領域知識在用戶身上 |
| **`git push -f` 或 reset --hard** | R9 — 不可逆操作 |
| **生產環境動作** | R10 — 用戶必須親手執行 |

### 4. 文件與 commit 提升標準

每個 commit message 必含：
- **What** — 改動列表
- **Why** — surfaced from 哪個 task / bug / audit
- **Impact** — security / performance / cost 影響（即使是 0 也明說）
- **Validation** — 跑了哪些 check（format / lint / test / smoke）

每個模組 SHIPPED 後 `docs/modules/<name>.md` 必含：
- §SOP（日常操作 + 失敗排查 + 審計 SQL）
- §SLO（latency / availability / data retention）
- §Runbook（alert fire 時值班怎麼處理）

### 5. 失敗處理升級

舊版「surfaced bug 順手修」不變，但新增：

- **任何 prod-affecting bug**（即使是 dev fix）— 必補 regression test
- **任何 silent failure 路徑**（log + return nil / log + swallow）— 必補 metric counter + alert proposal
- **任何 race condition / TOCTOU** — 必補 lock 順序 documentation
- **任何外部 API 整合** — 必有 timeout + retry + 觀測 metric

### 6. 對 user 的回應風格

- 仍然簡潔（不行銷腔）
- **但要主動 surface trade-off**：commit 完一個 milestone 後，用 1-2 句說「這次砍了 X 但代價是 Y（影響到 Z 場景）」— 不要等用戶問
- **主動 surface 風險**：發現 latent issue（不一定要修）也 surface「順帶一提：X 路徑有 Y 風險，建議下輪處理」
- **不掩飾不確定**：「我不確定 X 在高併發下的行為，建議走過 load test 再 ship」比「應該沒問題」誠實

---

**核心原則一句話**：摩擦消失了，把省下的時間花在主動加深度。每個 commit 都應該過得了 staff engineer 的 code review + security review + reliability review。
