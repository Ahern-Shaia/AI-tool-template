# 前端設計原則（核心 + 美學 profile）

> 模板檔。任何前端產出（mockup / 元件 / 版面 / 截圖 / 樣式）**動手前先過這份**。分兩層：
> - **§A 普世核心** — 不分專案、不分風格，永遠適用（定義「什麼叫好」）。
> - **§B 美學 profile** — 每個專案挑一個（或自訂），決定「哪一種好看」。預設 `modern-SaaS-craft`。
>
> 產出後自問：「這是不是出廠預設樣？有沒有貼這個專案的品牌與選定 profile？」

---

## A. 普世核心（universal — 一律適用）

### A1. 刻意 > 出廠預設
不出貨「直接套元件庫 demo / 樣板」的成品。每個畫面都要能回答「**為什麼長這樣**」，且貼合**這個產品的品牌與目標族群**。
> 「看起來像 AI 生成樣板 / 千篇一律」是這條的**失敗態**。但「什麼具體長相算 AI 感」會隨時間與風格變動 —— 具體 avoid-list 放對應 profile（§B），不當普世通則。

### A2. Design token 紀律
- **token 是唯一真實來源**：色 / radius / shadow / spacing / font / motion 全走語意 token。
- **禁硬編 hex / px 魔數**；一律語意 token（`primary` / `surface` / `ink` / `line` / `ok` / `warn` / `danger` / `info`…）。
- （Tailwind 專案）spacing 用 `gap-*`，避免 `space-x/y-*`。

### A3. 無障礙基線（a11y）
- 對比 AA 4.5:1（重點目標 AAA 7:1）；內文 ≥16px；觸控 ≥44–48px。
- 明顯 focus ring、鍵盤可達。
- **狀態不能只靠顏色** = 色 + icon / 文字 / 形狀（WCAG 1.4.1）。
- 錯誤**行內持久**顯示，不只 toast 一閃。

### A4. 動效不破壞體驗
- 元件出現 / 消失**不瞬間彈出或消失**；過場只動 `opacity` + `translate` / `scale`，不抖 layout。
- **尊重 `prefers-reduced-motion`**（開啟時只 fade、不位移）。
- 具體時長 / 曲線 / 動效**個性**（活潑 or 克制）屬 profile（§B）。

### A5. 先研究、再設計（向上設計）
做新元件 / 版面前先做一輪參考研究，目標是**綜合 + 差異化** —— 不是抄、不是取平均：
1. 抓 **≥3 個**同領域 / 鄰域參考；每個記下「**做對的 1–2 點 + 最弱 / 做錯的 1 點**」。
2. 你的設計 = **贏過最強者的強項 + 修掉大家共同的弱點**。這就是「向上設計」。
   > 例：競品狀態全只靠顏色 → 你補 icon + 文字 + 形狀，那一條就是向上。
3. 把「參考對象 / 吸收的優點 / 我們怎麼更好 / 落地對照」記進專案設計 doc —— 讓決策可回溯，不是憑感覺。

### A6. 設計所有狀態（不只 happy path）
一個畫面 / 元件的**每一種狀態**都要刻意設計。沒設計的狀態會掉回框架醜預設（空白 / 原始錯誤 / 版面跳動）—— 這是 UI 看起來壞掉、半成品、出廠預設樣的**頭號來源**。逐項過：
- **empty**：無資料 / 搜尋無結果 → 說明 + 一個主要行動，不是一片空白。
- **loading**：skeleton 對齊最終版面（別用擋畫面 spinner、別讓資料到了才跳版）。
- **error**：講清楚 + 可重試，**行內持久**（見 A3）。
- **少 vs 多 / 溢位**：1 筆 vs 海量、超長文字 / 名字 → 截斷 / 換行 / 捲動。
- **null / 缺欄位**：fallback，不是破圖或 `undefined`。
- **無權限 / 鎖定**：說明為何看不到，不是直接消失或報錯。
- **離線 / 過期**：標示資料時間 / 同步狀態（行動 + 即時資料場景）。
- **disabled / 唯讀**：處理中的按鈕、唯讀表單。

### A7. 響應式 / 自適應
為一個**範圍**設計，不是為你自己的螢幕。最小（手機）到最大（寬桌機）都要可用、內容自然 reflow，不破版 / 不意外橫捲（寬資料表等刻意例外除外）。
- **斷點看內容、不看裝置**：版面撐不住了才換。
- **適配不只縮放**：必要時改版面（側欄 → 頂部 nav / 抽屜），不是把桌機版等比縮小。
- **觸控 vs 滑鼠**：觸控目標 ≥44–48px（見 A3）；**不可有 hover-only 的關鍵操作**（觸控沒有 hover）。
- **流式優先**：fluid grid / `min()` / `clamp()` 勝過硬編 px 寬。
- 真的在各斷點驗一遍（至少手機 + 桌機），不是改一次就算。

### A8. 先複用再發明
做新元件 / pattern 前，先找**現有的**能不能複用 / 組合 / 延伸。隨手造新元件是風格碎裂主因 —— 同個東西三種樣子，產品就顯得沒人管。
- 先搜現有元件 / pattern / token；能組合就別新造。
- 避免「9 成像」的近似重複（兩顆幾乎一樣的按鈕）→ 收斂成一個。
- 真要新造：用既有 token、對齊既有 pattern，放在**可重用**位置並納入設計系統，不是一次性 snowflake。
- 新增 pattern 是**刻意決策**，不是意外。

---

## B. 美學 profile（每專案挑一個 / 自訂）

> profile 決定密度、形狀語言、色彩性格、是否用漸層、深度（陰影）、字體性格、動效個性、avoid-list。
> **換 profile 不影響 §A。** 一個 profile 至少定義這 8 項；正式採用前依 §A5 研究補齊。

### B0. 預設 profile：`modern-SaaS-craft`（高質感儀表板）
適用：B2B / SaaS / dashboard / 數據密集工具。吸收 Linear / Stripe / Vercel-Geist / Radix / Raycast / Attio。
- **密度**：偏高、資訊密、編輯級排版。
- **色彩**：克制；**不用純黑 / 純灰**（帶色調 ink / hairline）；飽和色只點在重點。
- **深度**：**層疊陰影（shadow-as-border）** —— hairline ring + 柔和高度疊進**單一 box-shadow**，取代「1px border + 平面 shadow」。
- **填充**：**實色非漸層**；主按鈕實色 + 頂部內 highlight + 按壓 `translateY` + tinted focus ring。
- **形狀**：中性圓角；pill badge（淡底同色深字 + 前導 dot + tabular 數字）。
- **列表 / 卡片**：surface 階梯、hover 抬升、hairline 列分隔（**非斑馬紋**）、skeleton shimmer。
- **動效**：micro 100–150ms / enter 150–200ms / exit 更快；進 ease-out、出 ease-in。
- **avoid-list（此 profile，會隨時間更新）**：通用置中孤卡、預設元件庫 demo 長相、紫漸層 / 發光、「**左色條 + 淡底 + 小 icon**」的樣板 alert、零層次。

### B1. 其他 profile（用到再依 §A5 展開）
只列「性格 + 對 B0 的關鍵差異」，採用前研究補齊：
- **`playful-consumer`**（C 端 / 社群 / 兒童）：低密度、大圓角、**可用漸層 / 鮮色**、動效更彈跳有個性、插畫感。
- **`editorial-content`**（內容 / 媒體 / 品牌站）：版面與字體主導、留白大、強對比標題、圖文節奏；元件感弱。
- **`minimal`**（極簡工具 / wellness）：低密度、大量留白、近乎無陰影、單色階、動效極淡。
- **`brutalist-expressive`**（作品集 / 創意品牌）：刻意高對比、硬邊、原色、可破格 —— 「故意不精緻」也是立場。

> **自訂 profile**：複製 B0 的 8 項結構逐項改寫，存進專案設計 doc，於 CLAUDE.md / 此檔註明本專案採用哪個 profile。

---

## 主要參考來源（起手清單）
- 設計系統 / token：Geist、Stripe、Raycast 的 DESIGN.md（awesome-design-md）、Radix Themes `shadow.css`。
- 無障礙 / 動效：WCAG 2.2、Nielsen Norman Group、Material 3 motion tokens、Apple HIG motion、MDN `prefers-reduced-motion`。

---

> 新原則：**普世的** append §A；**風格的** append 對應 profile。對應記憶 `memory/feedback_frontend_design_principles.md`。
