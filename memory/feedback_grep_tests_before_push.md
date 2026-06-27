---
name: 改 service 前必 grep tests 找所有相關 test files
description: 改 service / class / function 前先 grep tests/ 找所有 reference 它的 test files；不可只跑「同名」的 test file，CI fail 浪費 build 額度
metadata:
  type: feedback
---

改任何 service / class / function 前，先 `grep -rn "<symbol>" tests/` 找出所有 reference 它的 test files；**全跑過 + 全綠**才 push。不可只跑「檔名同名」的 test file。

**Why:** Test 組織不一定 `test_<module>.py` 對應 `<module>.py` — 有時 X service 的 test 因主題關連散落在 Y test file（例：marketing service 的 test 可能在 test_treatment_service.py）。只跑「同名」test file 會漏掉這類同主題 test，push 後 CI 才抓到，浪費一次 build 額度 + 一輪信任損失。

跟 [[feedback_release_notification_format]] §「Sentinel 必跑 test pack」精神同類但不同維度 — Sentinel pack 是「不論改什麼，這幾條 lint-level test 都要跑」；本條是「改 X 就要 grep 找所有跟 X 相關的 test，可能跨檔案名」。

**How to apply：**

改任何 `src/services/<X>.py` 之前，跑：

```bash
grep -rn "<ClassName>\|<key_function_1>\|<key_function_2>" <repo>/tests/ 2>&1 | cut -d: -f1 | sort -u
```

例如改 `marketing_service.generate_drafts()`：

```bash
grep -rn "generate_drafts\|MarketingService" backend/tests/ | cut -d: -f1 | sort -u
# → tests/integration/test_marketing_api.py
# → tests/unit/test_treatment_service.py     ← 漏掉這個就 CI fail
# → tests/unit/test_llm_billing_coverage.py
```

所有結果都跑：

```bash
uv run pytest <all_files> -v --tb=short -x
```

**特別場景**：
- **改 model**（`User`, `Order`, etc.）→ grep model 名 + relevant fixture 名
- **改 API endpoint** → grep endpoint path + router function 名
- **rename class / function** → 同樣先 grep 找到所有 reference，rename 後跑那些 test
- **改共用 helper / middleware** → 影響面大，至少跑 `tests/unit/ tests/integration/ tests/security/` 全 sweep
- **改 LLM prompt / fallback** → grep test 用 placeholder / test mock LLM response 的 file

**反例（不要這樣做）**：
- ❌ 「改 `xxx_service.py` → 跑 `test_xxx_*.py`」— 假設檔名對齊
- ❌ 「上次跑那幾條 test 都過 → 應該夠了」— 沒重新 grep
- ❌ 「Sentinel 5 條都過了 → 應該 push 安全」— Sentinel 只 cover lint-level 主題，不 cover service 內部 logic
