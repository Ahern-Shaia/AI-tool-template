---
name: codegen 不一定重生所有衍生檔
description: 改 proto / IDL / schema 後，別假設 `buf generate`（或任何 codegen）會更新每個衍生檔；有些 generated 檔是手維護的（plugin 沒 vendored / clean=false / 部分產生），改 field 後要 grep generated 樹手動 patch，否則 build 紅。
type: pitfall
---

改 proto / GraphQL / OpenAPI / ORM schema 的 field 後，**不要假設 code generator 會一次更新所有衍生檔**。常見有一類 generated 檔實際是「凍結 + 手維護」的：對應 plugin 沒 vendored、generator 設 `clean: false` 保留舊檔、或只跑部分 codegen。改 field 後這些檔仍引用舊 field，編譯就紅在一個你以為是自動生成、不會手動碰的檔案上。

**Why:**
- generator 的 config 常為了保護某些檔而關掉 clean / 留某 plugin entry comment 掉 → 那些檔脫離 codegen 生命週期，變成手維護
- 移除 / reserve 一個 field 時，主 generated 檔乾淨更新了，但凍結檔還在比對 / 引用該 field
- build 失敗訊息會指向那個凍結檔（`X.Foo undefined`），容易誤判成「codegen 壞了」而去重跑 generator，其實 generator 根本不碰它

**具體案例（Argus）：** `backend/generated-go/v1/*_equal.pb.go` 由 upstream `protoc-gen-go-equal` plugin 產生，但該 plugin 沒 vendored、`buf.gen.yaml` 把 entry comment 掉、且 `clean: true` 故意關閉以保留這些檔。某次 reserve 一個 proto field 後，主 `.pb.go` 乾淨移除該 field，但 `_equal.pb.go` 仍 `x.Foo != y.Foo` → backend build 紅。修法是手動編輯凍結檔刪掉比對 block。

**How to apply:**
- 任何 proto / schema field 的 add / remove / reserve checklist，加一條：`grep -rn "\b<FieldName>\b" <generated-tree>` 找出所有引用，手動 patch 凍結檔
- 加 field → 比照鄰近 block 插入對應比對 / 序列化邏輯；移除 field → 刪掉對應 block
- 別為了「自動化」而貿然打開 generator 的 `clean: true` 或反註解缺失的 plugin entry — 缺的 binary 不在 PATH，會反而 wipe 掉整批手維護檔，炸到無關模組。要恢復 plugin 是另一個獨立 task
- 先確認哪些 generated 檔是「真自動」哪些是「凍結手維護」，把後者寫進該模組的 onboarding note
