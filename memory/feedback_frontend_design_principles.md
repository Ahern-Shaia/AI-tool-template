---
name: frontend-design-principles
description: 前端設計鐵則 — §A 普世核心（刻意>出廠預設 / token / a11y / 動效不破壞 / 先研究）一律適用 + §B 美學 profile 每專案挑一個；詳見 docs/frontend-design-principles.md
metadata:
  node_type: memory
  type: feedback
---

前端**所有**設計（mockup / 元件 / 版面 / 截圖 / 樣式）動手前先過鐵則；完整版見專案 `docs/frontend-design-principles.md`。**兩層**：

**§A 普世核心（不分專案 / 不分風格，一律適用）**
1. **刻意 > 出廠預設** — 不出貨「套元件庫 demo / 樣板」的成品；每畫面要能答「為什麼長這樣」且貼品牌與目標族群。（「看起來像 AI 生成樣板」是這條的失敗態。）
2. **token 紀律** — 語意 token 唯一真實來源、禁硬編 hex。
3. **a11y** — 對比 / focus / 觸控；**狀態不只靠顏色**（色 + icon / 文字）；錯誤行內持久。
4. **動效不破壞體驗** — 不瞬間彈出 / 消失、只動 opacity + translate/scale、尊重 `prefers-reduced-motion`。
5. **先研究再設計（向上設計）** — 看 ≥3 競品 / 頂尖產品，綜合強項 + 修掉共同弱點做更好的（不是抄 / 取平均）。
6. **全狀態設計** — empty / loading / error / null / 無權限 / 離線 / 溢位 都要設計，不只 happy path（沒設計的狀態 = 醜預設 = 看起來壞掉）。
7. **響應式 / 自適應** — 為範圍設計（手機 ↔ 寬桌機都可用、內容 reflow）；觸控 ≥44–48px、無 hover-only 關鍵操作；適配不只縮放。
8. **先複用再發明** — 新元件前先找現有可複用 / 組合；避免近似重複，防風格碎裂。

**§B 美學 profile（每專案挑一個 / 自訂）** — 決定「哪一種好看」：密度 / 漸層與否 / 形狀 / 深度 / 色彩性格 / 動效個性 + avoid-list。預設 profile = **modern-SaaS-craft**（層疊陰影、實色非漸層、不用純黑灰、高密度…）。換 profile 不動 §A。

**Why**：用戶要求「前端所有設計都要記住」；且**已釐清**——核心通用，但具體「去 AI 感手法」是特定審美（house style），不該當通則，故拆兩層。
**How to apply**：每次前端先過 §A + 確認該專案採用的 §B profile；產出後自問「這是不是出廠預設樣 / 有沒有貼品牌與 profile？」。普世原則 append §A、風格原則 append 對應 profile。
