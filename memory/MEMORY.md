## Index

### User
- [User profile](user_role.md) — [一句話描述用戶角色 / 偏好]

### Execution mode（執行模式 — 兩個其中之一）
- ⭐ [企業級執行 — autonomous + rigor 雙高](feedback_enterprise_execution.md) — 當用戶執行帶 `--dangerously-skip-permissions` 或明說「企業級商用系統」時生效。批次推進 + 主動加深度（安全 / 容量 / 失效 / 觀測 / 成本 / 兼容六大 cross-cutting）。
- [一氣呵成 / 高吞吐](feedback_single_task_execution.md) — 個人專案 / prototype / 內部工具。批次推到自然斷點，不要每個 step 都停。

> 兩條 feedback 互斥 — 用戶說「企業級」就用前者，未指明就用後者。對話開頭明確一句即可切換。

### Collaboration preferences
- [No PR / no reviewer workflow](feedback_no_pr_workflow.md) — solo dev 直接 commit，不假裝走 PR ceremony / 不提 reviewer gating
- [溝通口吻偏好](feedback_communication_voice.md) — 簡潔、不行銷、不裝可愛；錯誤訊息 sober 不浮誇
- [前端 / 後端 commit 必分開](feedback_separate_frontend_backend.md) — 同時動前+後端必拆兩 commit；report 分段；design doc scope 也分
- ⭐ [只有 git push 需要明確同意](feedback_only_push_needs_consent.md) — code edit / commit / 本地實驗自由做，每次 `git push` 都要單獨問再執行

### Rules / hazards（read before editing）
- [模組設計流程](rule_module_design_flow.md) — non-trivial 模組必走 M0 design doc + OQ-N 給用戶裁定 → M1-M4 落地 → MODULES.md 標 ✅
- ⭐ [Cross-cutting checks](rule_cross_cutting_checks.md) — 任何 user-visible / data-touching commit 必過 security / observability / cost / compat 四檢。企業級執行模式下強制
- ⭐ [Cross-cutting concern 必 sweep outer shell](rule_outer_shell_sweep.md) — permission / audit / i18n / observability 必把 sidebar / banner / route / layout 一起 sweep，不只 endpoint / button 層
- [Commit message 格式](rule_commit_format.md) — `<type>(<scope>): <description>`；Co-Authored-By Claude 行**預設不加**（用戶明說要才加）
- [全綠才算完成](rule_full_green_check.md) — 每 task 結束跑完整 format + lint + build + test，repeat lint 直到 0 issues
- [修補 vs 重構決策架構](rule_refactor_vs_patch_decision.md) — 區分「設計缺陷 / sweep 紀律不夠 / 局部漏」三類；不要把任何反覆 BUG 都當設計缺陷要重構
- ⭐ [前端設計鐵則](feedback_frontend_design_principles.md) — 所有前端產出必過；§A 普世核心（刻意 > 出廠預設 / token / a11y / 動效 / 先研究 / 全狀態 / 響應式 / 複用）+ §B 美學 profile（預設 modern-SaaS-craft）；詳 `docs/frontend-design-principles.md`

### Production hygiene（有 prod 環境的專案才適用）
- [事先檢查 prod state 才 push](feedback_verify_prod_state_before_push.md) — schema / env / secret / IAM / infra 類 push 前必驗 prod 對應 state 已就緒
- [高風險 endpoint push 後必跑 prod smoke](feedback_smoke_test_after_push.md) — 新 endpoint / 改 auth / cron / webhook / schema / IAM push 完必 30 秒驗 routable + auth gate + log
- [發版通知 8 段式擴充模板](feedback_release_notification_format.md) — push to prod + smoke 過後自動採 8 段式（類型 / commit list / 內部通知 / 對外通知 / 部署 / smoke / rollback / 同類風險）
- [改 service 前必 grep tests 找相關 test files](feedback_grep_tests_before_push.md) — 改 service / class / function 前先 `grep -rn` 全 tests/ 找出所有 reference；不可只跑「同名」test file（同主題 test 常散落跨檔），避免 CI fail 浪費 build 額度

### Strategic decisions
- [ROI 評估必納 ops + governance 成本](feedback_roi_include_ops_governance.md) — 評估遷移 / 重構 / vendor / 模型替換不能只算直接金流；要算 ops 痛 / 中斷風險 / 合規 / lock-in

### Pitfalls（通用踩坑 — 改 schema / codegen / 建 package 前重讀）
- [codegen 不一定重生所有衍生檔](pitfall_generated_files_not_regenerated.md) — 改 proto / IDL / schema 後別假設 generator 更新全部；凍結手維護的 generated 檔要 grep + 手 patch，別貿然開 `clean:true`
- [嚴格 schema 的序列化欄位一壞炸整個 list](pitfall_serialized_column_breaks_whole_list.md) — JSONB strict unmarshal / protobuf 欄位一列壞炸整個列表；手 seed 要 field-by-field 對 schema，當心「看似 string 其實是物件 / enum / duration」的欄位
- [建新 package / 目錄前先查路徑撞名](pitfall_package_path_collision.md) — design doc 路徑是建議不是契約；新建 `internal/X/` 前 `ls` + grep 名稱，撞到改用帶意圖的 sub-package

### External / reference
- [Project Brain MCP](reference_brain.md) — `.brain/` 已內建（如有），任務開始 `get_context`、任務完成 `complete_task`、發現 Pitfall / Rule / Decision 即 `add_knowledge`
