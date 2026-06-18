---
name: 嚴格 schema 的序列化欄位一壞炸整個 list
description: 存序列化結構（JSONB 走 strict unmarshal / protobuf / Any）的欄位，只要一列格式不對，反序列化錯誤會炸掉「整個 list query」不只那一列。手動 seed / insert 時要 field-by-field 對 schema，特別注意「看似 string 其實是巢狀 message / enum / duration」的欄位。
type: pitfall
---

某些欄位雖然底層是 JSONB / text，但 backend 讀取時走 **strict 反序列化**（`protojson.Unmarshal` 到固定 message、ORM struct binding 等）。這類欄位不是 free-form blob：只要其中一列 JSON 不合 schema，list / search query 在分頁前就 unmarshal 失敗，**整個列表變空 + 500**，不是只跳過壞的那一列。手動 seed、寫測試 fixture、或外部系統灌資料時最容易踩。

**Why:**
- 反序列化錯誤在 row-mapping 階段 bubble up，早於 pagination / filter → 一顆老鼠屎壞整鍋
- 最坑的是「看起來像 string、其實是結構」的欄位：例如一個 `status` 欄位 proto 型別是 `google.rpc.Status`（物件），你直覺塞 `"SUCCESS"`（字串）就炸；duration 欄位要 `"3.5s"` 不是任意字串；enum 要用 enum 名
- 序列化常是 camelCase（protojson）而非 schema 的 snake_case，手寫 JSON 容易 key 對不上

**具體案例（Argus）：** `audit_log.payload` 是 JSONB，但 backend 用 `protojson.Unmarshal` 讀成 `store.AuditLog`。seed script 把 `status` 寫成字串 `"SUCCESS"`，但 proto 型別是 `google.rpc.Status` → `/compliance-reports`、`/audit-log`、`/monitoring` 全部 500、列表全空，錯誤訊息 `proto: syntax error: unexpected token "SUCCESS"`。正確：`status` 給空物件 `{}`（= code 0 = 成功），失敗給 `{"code": 7, "message": "..."}`。

**How to apply:**
- 手刻這類欄位的 JSON 前，先打開對應 schema / proto 定義 field-by-field 對照，別憑直覺
- 重點檢查非-string 型別欄位：巢狀 message（給物件不是字串）、enum（給 enum 名）、duration / timestamp（給特定格式）、Any（不確定就省略）
- 記住序列化大小寫慣例（protojson camelCase）→ key 逐字對
- 留一份「正確 shape」的 canonical seed / fixture 當範本，新 seed 從它改不要從零拼
- 灌完馬上開對應頁面 smoke 一次，確認列表渲染得出來
