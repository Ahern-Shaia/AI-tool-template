---
name: 特權測試連線會遮蔽安全機制
description: superuser 跑整合測試 ⇒ RLS 與 grant 都不執法;五條測試全綠而真請求 500
type: pitfall
---

整合測試用 superuser 連線建 service ⇒ **RLS 與 grant 對它都不執法** ——
少一條 grant 也是綠的、跨租戶洩漏也是綠的。實證:五條整合測試全綠,
而真的發請求是 `permission denied` → 500,整條路壞掉。

**修法**:安全敏感 service 在測試裡走與 prod 相同的**低權車道**
(建一個 NOSUPERUSER NOBYPASSRLS 的角色連線);為此立**棘輪**
(手動餵特權連線的測試檔數只能往下)。
⚠️ 反之亦然:一張**刻意沒有 RLS** 的表,不能為了測試方便補 grant 搬回 app 車道 ——
那會讓 app 讀到所有租戶。守衛寫成「app 角色對它不得有 SELECT」。
