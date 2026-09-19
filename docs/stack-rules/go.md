# Go 規則(技術棧附件 —— Go 專案直接用,其他棧略過)

> 對齊 `security-baseline.md` / `performance-baseline.md` 兩塊地板;這裡**只寫「在 Go 上長什麼樣」**,
> 不重述地板。分級:**P0 = CI 擋** · **P1 = review 擋** · **P2 = 慣例**。
>
> **來源與查證狀態**:Effective Go、Go Code Review Comments、`database/sql` 官方文件、
> golangci-lint 規則集、gosec 規則編號 —— 依撰寫時知識整理,**連結與規則 ID 待回查**。
> lint ID 會隨版本改名,採用前對著專案實際安裝的 golangci-lint / gosec 版本確認一次。

## 語言陷阱(Go 特有,型別系統擋不住)
- [P0] 每個回傳的 error 都要處理;wrap 用 `%w` 保留鏈;禁 `_ = f()` 吞錯
  · 執法:`errcheck`(golangci-lint 內建)
- [P0] **並發讀寫 map 直接 crash**;共享狀態要鎖或 channel · 執法:CI 一律 `go test -race`
- [P0] **interface 的 nil 陷阱**:`var p *T = nil` 塞進 `error` 介面後 `err != nil` 為真。
  禁「回傳具體型別的 nil 指標當 error」· 執法:回傳型別一律宣告為 `error`,review 擋
- [P0] **slice aliasing**:`append` 可能就地改到別人的底層陣列。要獨立就 `slices.Clone` / `copy`
- [P1] `defer` 累積到**函式**結束不是迴圈結束 → 迴圈體抽成小函式 · 執法:`revive`
- [P1] **迴圈變數捕獲**:Go 1.22 起每次迭代一個新變數,但**看的是 `go.mod` 的 go 版本** ——
  低於 1.22 的專案仍是舊行為 · 執法:`go vet` 的 `loopclosure` + 檢查 go.mod
- [P1] map 迭代順序隨機,不可依賴;要穩定輸出就排序 key
- [P1] `time.Time` 比較用 `Equal()` 不用 `==`(單調鐘 + Location 會讓 `==` 反直覺)
- [P1] 整數轉型前檢查範圍(`int` 寬度依平台) · 執法:gosec 的整數轉換規則(G109/G115,視版本)
- [P2] panic 不當控制流;`recover` 只放在 goroutine 邊界與 HTTP middleware

## 並發(Go 最貴的一區)
- [P0] **每個 `go` 都要答得出「它什麼時候結束、誰在等它」**。答不出來就是洩漏
  · 執法:測試用 `goleak`(`TestMain` 掛 `VerifyTestMain`)
- [P0] **fan-out 要有上限**:`errgroup.Group` + `SetLimit()`;禁 `for ... { go f() }` 無界開協程
- [P0] **`context` 一路傳遞**,每個外呼帶 deadline;`context.Background()`/`TODO()` 只出現在
  進程入口與測試 · 執法:`contextcheck` + `noctx`
- [P0] `select` 一律帶 `case <-ctx.Done()`,否則取消訊號到不了
- [P1] channel 誰寫誰關,禁關別人的 channel;`WaitGroup.Add` 在 `go` 之前
- [P1] 無界 channel / 無界佇列 = 把延遲換成 OOM(地板 §7 背壓)

## HTTP / 網路
- [P0] 🔴 **`http.Client` 的零值 `Timeout` 是無限**。禁用 `http.Get` / `http.DefaultClient`,
  只能走專案自己包好逾時與 Transport 的 client · 執法:grep 守衛擋 `http.Get(` / `http.DefaultClient`
- [P0] 🔴 **`http.Server` 的四個 timeout 零值也全是無限**:`ReadHeaderTimeout`(擋 Slowloris)/
  `ReadTimeout` / `WriteTimeout` / `IdleTimeout` 全設 · 執法:gosec G112
- [P0] 回應 body **一定 `defer resp.Body.Close()` 且讀完**(沒讀完的連線不會被重用,
  高併發下變成每請求一條新連線)
- [P0] **`net/http/pprof` 一被 import 就註冊到 `DefaultServeMux`** —— 禁掛在對外 mux,
  只開內網埠 · 執法:grep 守衛擋對外 mux 用 `DefaultServeMux`
- [P1] 使用者提供的 URL 走白名單 + 禁 redirect(地板 §5 SSRF):自訂 `CheckRedirect` 直接回錯

## 資料庫
- [P0] **`sql.DB` 是連線池不是連線**:`SetMaxOpenConns` / `SetMaxIdleConns` /
  `SetConnMaxLifetime` 三個都要設,且 `MaxOpenConns × 實例數 < DB max_connections`
- [P0] 參數化 `$1` / `?`;禁 `fmt.Sprintf` 拼 SQL · 執法:gosec G201/G202
- [P0] **`rows` 必 `Close()` 且必檢查 `rows.Err()`** —— 迴圈正常結束不代表沒出錯
  · 執法:`sqlclosecheck` + `rowserrcheck`
- [P0] `QueryRow` 之後要分辨 `sql.ErrNoRows`(那是「查無」不是「壞了」)
- [P0] 金額用 decimal 套件,禁 `float64`(地板同條)
- [P1] 交易:取得 tx 後立刻 `defer tx.Rollback()`(commit 後的 rollback 是 no-op);
  **交易裡禁做 HTTP 外呼**

## 安全
- [P0] token / nonce / ID 用 `crypto/rand`,禁 `math/rand` · 執法:gosec G404
- [P0] 執行外部程式用參數陣列,禁拼 shell 字串 · 執法:gosec G204
- [P0] 使用者控制的路徑做 `filepath.Clean` + 前綴檢查(擋路徑遍歷) · 執法:gosec G304
- [P0] 回 client 的錯誤不帶內部細節(地板:統一錯誤信封 code/message/correlationId)
- [P0] 相依:`go mod verify` + **`govulncheck` 進 CI**;升級後 `go mod tidy`

## 效能
- [P0] **N+1 在 Go 通常是手寫的迴圈查詢**(沒有 ORM 幫你藏,所以更容易看見也更容易寫出來):
  一次撈回來在記憶體組裝 · 執法:測試 assert query 數
- [P0] 列表查詢一律有 limit + cursor 分頁;大結果集用 `rows.Next()` 串流處理,
  不要先 `[]T` 全載
- [P1] 預配置容量:`make([]T, 0, n)`;字串拼接用 `strings.Builder` 不用 `+=`
- [P1] 大 struct 傳指標、小 struct 傳值;懷疑逃逸就跑 `go build -gcflags=-m`
- [P1] `sync.Pool` 只用在**量過**的熱路徑(它不是通用優化,用錯反而更慢)
- [P1] 關鍵路徑寫 `testing.B` benchmark 進 repo,回歸用 `benchstat` 比對兩次結果

## CI-fail 禁令清單
未處理的 error · `_ =` 吞錯 · 沒有 `-race` 的測試 · 無上限 `go` fan-out ·
`context.TODO()` 出現在非入口 · `http.Get` / `http.DefaultClient` ·
沒設四個 timeout 的 `http.Server` · 未 `Close` 的 `rows` · 未檢查的 `rows.Err()` ·
`fmt.Sprintf` 拼 SQL · `math/rand` 產 token · 對外 mux 掛 `DefaultServeMux`(pprof) ·
沒設上限的連線池 · float 存金額 · 無 limit 的列表查詢 · `govulncheck` 有未修漏洞
