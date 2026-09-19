# TypeScript / NestJS 規則(技術棧附件 —— TS 專案直接用,其他棧略過)

> 從真實專案的 AGENTS 抄出、去專案化。綜整 Google TS Style、
> typescript-eslint strict-type-checked、NestJS 官方 + 企業指南。

## tsconfig(強制)
- [P0] `strict` · `noUncheckedIndexedAccess`(`arr[i]` → `T | undefined`)· `noFallthroughCasesInSwitch`
- [P1] `noImplicitOverride` · `noImplicitReturns` · `isolatedModules` + `verbatimModuleSyntax` · `exactOptionalPropertyTypes`(最後開)
- [P2] `noUnusedLocals` / `noUnusedParameters`(未用參數前綴 `_`)

## 型別紀律
- [P0] 禁 `any` → `unknown` + narrowing;禁 non-null `!` → 明確檢查
- [P1] 避免 `as`;不得已加理由註解,雙轉只走 `as unknown as T`
- [P1] exported / public method 標回傳型別;不重賦值標 `readonly`;型別用 `import type`

## 型別建模
- [P0] 狀態用 **discriminated union** + `never` 預設做 exhaustiveness check(新 case 未處理即編譯錯)
- [P0] 所有外部邊界(HTTP body / DB row / env)用 **Zod 驗證 + `z.infer`**
- [P1] domain ID 用 branded type 防跨模組混用;union-of-literals 優於 `enum`,禁 `const enum`
- [P0] 只 throw `Error` 子類;`catch` 為 `unknown` 先 narrow;禁靜默吞錯(空 catch 需理由)
- [P0] 禁 floating promise
- [P1] 具名 export 禁 default;app code 禁 barrel file(循環依賴 + 破 tree-shaking)

## NestJS
- [P0] 依 feature 分模組;只透過 `exports` 曝露窄 API;**CI 用 dependency-cruiser/madge 擋跨模組 import + 循環依賴(不靠自律)**
- [P0] 只用 constructor injection。🔴 **`emitDecoratorMetadata` 沒開的專案,`@Inject()` 一個都不能省** —— 省了 tsc 綠、單元測試綠(手動 new 不走 DI),只有真的發請求才 500;慣例要有守衛執法
- [P0] 薄 controller → service(業務/交易)→ repository(只查詢);禁 controller 直呼 repo
- [P0] 全域 `ValidationPipe { whitelist, forbidNonWhitelisted, transform }`(擋 mass-assignment);req/res DTO 分離,**禁回傳 DB entity**
- [P0] Guard 管 authz · Interceptor 管 logging · Pipe 管驗證 · Filter 管錯誤(統一錯誤信封 code/message/correlationId);Guard 不放業務邏輯
- [P0] `@nestjs/config` + 開機 schema 驗證 fail-fast;禁散落 `process.env`
- [P0] Helmet + CORS allowlist + throttler;參數化查詢 everywhere
- [P0] service 單元測試 + e2e 對真 Postgres(testcontainers,跑真 RLS/migration)

## 效能(通用形狀)
- [P0] N+1 防護:dataloader / 正確 join(關聯載入是最常見瓶頸)
- [P1] metadata/權限/config 熱路徑快取,變更時失效;cursor 分頁;回應 DTO 只回需要欄(兼防 over-fetch 洩漏);重計算走背景 worker 不擋請求
- [P1] feature flag / kill switch:風險功能不 deploy 即關

## CI-fail 禁令清單
`any` · non-null `!` · 無說明 `as` · default export · `const enum` · `var` ·
`==`(除 `== null`)· app barrel file · floating promise · 循環依賴 ·
散落 `process.env` · fat controller · 回傳 DB entity · 空 catch ·
未白名單的動態 identifier · float 存金額 · 無 scope 的跨租戶查詢
