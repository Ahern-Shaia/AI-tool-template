# React / Next.js 規則(技術棧附件 —— 前端是 React/Next 就用,其他棧略過)

> 分工:**視覺規則**看 `frontend-design-principles.md`(§A 普世核心 + §B 美學 profile)·
> **驗證迴圈**看 `frontend-testing.md`(真實瀏覽器走過才算完成)· **本檔只寫安全與效能**。
> 對齊 `security-baseline.md` / `performance-baseline.md` 兩塊地板,不重述。
> 分級:**P0 = CI 擋** · **P1 = review 擋** · **P2 = 慣例**。
>
> **來源與查證狀態**:React 官方文件、Next.js App Router 與 deployment 文件、
> eslint-plugin-react / jsx-a11y 規則集、web.dev Core Web Vitals ——
> 依撰寫時知識整理,**連結與規則 ID 待回查**。
> 🔴 Next.js 的**預設值(尤其快取)跨主版本改過數次**,採用前對著專案實際版本確認一次。

## 安全(Next.js 最容易失守的一區)
- [P0] 🔴 **Server Action / Route Handler 是公開端點**。任何人都能直接 POST ——
  「只有我的 UI 會呼叫它」不是保護。**每一個都要自己做 authn + authz + 輸入驗證**,
  和寫一支對外 API 完全一樣 · 執法:action/handler 一律走共用的
  `requireUser()` / `requirePermission()` 包裝,grep 守衛擋沒包裝的匯出
- [P0] 🔴 **傳給 client component 的 props 會被序列化進 HTML payload** ——
  使用者按「檢視原始碼」就看得到。禁把整個 user 物件 / DB row 傳下去
  (密碼雜湊、內部旗標、其他租戶欄位都在裡面) · 執法:只傳明列欄位的 DTO
- [P0] **`NEXT_PUBLIC_` 前綴 = 編譯進 bundle 的公開值**,禁放任何 secret
  · 執法:grep 守衛掃 `NEXT_PUBLIC_.*(KEY|SECRET|TOKEN|PASSWORD)`
- [P0] **server-only 模組禁被 client 端 import**:用 `server-only` 套件在**建置期**就擋下來,
  不要靠自律
- [P0] 🔴 **middleware 不是授權的唯一防線** —— `matcher` 沒涵蓋到的路徑直接繞過,
  而漏一條不會有任何錯誤。**authz 要做在資料存取那一層**,middleware 只當第一道
- [P0] 🔴 **快取會把 A 的資料端給 B**:使用者相關的請求一律明寫 `cache: 'no-store'` /
  `revalidate: 0`,`unstable_cache` 的 key **必須含使用者/租戶維度**(地板 §4 同一條)
  · 執法:資料存取包裝統一設定,禁在頁面散落裸 `fetch`
- [P0] `dangerouslySetInnerHTML` 一律先消毒 · 執法:eslint `react/no-danger`
- [P0] `href` / `src` 吃使用者輸入要擋 `javascript:` 協議 · 執法:eslint `react/jsx-no-script-url`
- [P0] `next/image` 的 `remotePatterns` 用白名單,禁 `**`(否則你的網域變成別人的圖片代理)
- [P1] 設定 CSP 與安全標頭(`next.config` headers 或反向代理),`frame-ancestors` 擋點擊劫持

## 效能
- [P0] **bundle 預算進 CI**,超過就紅(`size-limit` / `@next/bundle-analyzer` 門檻)。
  沒有門檻的 bundle 只會單向長大
- [P0] 🔴 **`'use client'` 放在哪決定 bundle 有多大**:標在頂層 = 整棵子樹進 client bundle。
  **往葉子推**,互動最小單位才標
- [P0] **禁整包 import 圖示/工具庫**(`import * as Icons from ...` / barrel file):
  tree-shaking 救不回來 · 執法:eslint `no-restricted-imports` 擋 barrel 路徑
- [P0] 圖片走 `next/image` 且給**明確尺寸**(擋 CLS);字體走 `next/font`
  (擋 FOUT,且不對第三方發請求)
- [P0] **資料抓取禁 waterfall**:同層的多個請求 `Promise.all` 平行,不要序列 `await`
- [P0] **四態分開**(載入 / 空 / 錯誤 / 有資料)——「載入中」與「空的」長得一樣是真實的坑
- [P1] 資料抓取優先 server component / loader,不要 `useEffect` 抓完再渲染(多一趟來回 + 閃爍)
- [P1] **render 裡建新物件 / 陣列 / 函式當 memo 相依 ⇒ memo 全失效**(看起來優化了,其實每次都重算)
- [P1] 長清單虛擬化;大區塊用 `next/dynamic` 延後載入
- [P1] **Core Web Vitals 門檻進 CI**(LCP / INP / CLS),且量**中階裝置**不是你的筆電

## 正確性(React 特有)
- [P0] list 的 `key` 用穩定 ID,**禁用陣列 index**(重排/刪除會把狀態接到錯的列上)
- [P0] eslint `react-hooks/rules-of-hooks` + `exhaustive-deps` 不得關閉
- [P1] 受控 / 非受控元件不得中途切換(`value` 從 `undefined` 變有值)
- [P1] 表單提交要擋重複送出(按鈕 disable + 伺服器端冪等,地板 §3)
- [P1] a11y:`jsx-a11y` 規則集打開;鍵盤走得完、focus 看得見(§A 普世核心)

## CI-fail 禁令清單
沒有 authz 包裝的 Server Action / Route Handler · 傳整個 DB row 給 client component ·
`NEXT_PUBLIC_` 帶 secret · client 端 import server-only 模組 ·
使用者資料走預設快取 / 快取 key 無使用者維度 · 未消毒的 `dangerouslySetInnerHTML` ·
`remotePatterns` 用 `**` · barrel / 整包 import · `'use client'` 標在頂層 ·
陣列 index 當 key · 關掉的 `exhaustive-deps` · 缺尺寸的圖片 ·
bundle 超過預算 · Core Web Vitals 低於門檻
