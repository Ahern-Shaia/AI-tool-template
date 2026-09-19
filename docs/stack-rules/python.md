# Python 規則(技術棧附件 —— Python 專案直接用,其他棧略過)

> 對齊 `security-baseline.md` / `performance-baseline.md` 兩塊地板;這裡**只寫「在 Python 上長什麼樣」**,
> 不重述地板。分級:**P0 = CI 擋** · **P1 = review 擋** · **P2 = 慣例**。
>
> **來源與查證狀態**:ruff 規則集(含 bandit `S` 族、flake8-bugbear `B` 族、`ASYNC` 族)、
> mypy strict 選項、Pydantic v2、Django/FastAPI 官方 deployment checklist ——
> 依撰寫時知識整理,**連結與規則 ID 待回查**;ruff 規則碼會隨版本增刪,
> 採用前對著專案安裝的 ruff / mypy 版本確認一次。

## 型別與工具(強制)
- [P0] `mypy --strict`(或 pyright `strict`)進 CI,新碼零 `# type: ignore` 無理由豁免
- [P0] 禁 `Any` 逃逸:外部資料進來先驗證再進型別系統(見下「邊界」)
  · 執法:mypy `disallow_any_explicit` / `warn_return_any`
- [P0] ruff 開到含 `E,F,B,S,ASYNC,DTZ,RUF` 規則族;format 用 ruff format
- [P1] public 函式標完整簽名;`from __future__ import annotations` 或新版語法統一一種

## 語言陷阱(型別檢查擋不住的那些)
- [P0] 🔴 **可變預設參數** `def f(x=[])` / `={}` —— 所有呼叫共用同一個物件
  · 執法:ruff `B006`(FastAPI 的 `Depends()` 需 `B008` 白名單,單獨設定)
- [P0] 🔴 **靜默吞錯**:`except Exception: pass` 與裸 `except:` 全禁;要吞必須寫理由 + 記 log
  · 執法:ruff `BLE001` + `E722` + `S110`
- [P0] **`assert` 在 `python -O` 下會被整條拿掉** —— 禁用 assert 做執行期驗證/授權檢查,
  只能在測試裡用 · 執法:ruff `S101`(測試目錄豁免)
- [P1] 迴圈裡的 closure 是**晚綁定**(抓的是變數不是值);要固定就用預設參數或 `functools.partial`
- [P1] `datetime` 一律 **timezone-aware**(`datetime.now(timezone.utc)`),禁 naive datetime
  · 執法:ruff `DTZ` 族
- [P1] 金額用 `Decimal`,禁 `float`;`Decimal` 不要從 float 建(`Decimal(0.1)` 已經錯了),
  從 `str` 建
- [P2] 類別屬性是可變物件時所有實例共用 —— dataclass 用 `field(default_factory=...)`

## 邊界驗證
- [P0] **所有外部輸入用 Pydantic v2 驗證**(HTTP body / query / webhook / 檔案 / 第三方回應),
  禁把 `request.json()` 的 dict 直接往下傳
- [P0] **環境變數走 pydantic-settings 開機 fail-fast 驗證**,禁散落 `os.environ[...]`
  · 執法:grep 守衛擋非設定模組的 `os.environ` / `os.getenv`
- [P0] 回應也走 schema(response_model / serializer),**禁直接回 ORM 物件**
  (over-fetch 洩漏 + N+1 觸發點)
- [P1] 驗證要分層:Pydantic 管「形狀對不對」,業務規則(額度、狀態機)管在 service 層

## 安全
- [P0] SQL 一律參數綁定;禁 f-string / `%` 拼 SQL,`text()` / `.raw()` / `.extra()` 也要綁參數
  · 執法:ruff `S608`
- [P0] `subprocess` 禁 `shell=True` 拼字串,用參數陣列 · 執法:ruff `S602`/`S603`/`S604`
- [P0] **禁對不可信輸入反序列化**:`pickle`(`S301`)/ `yaml.load` 用 `safe_load`(`S506`)/
  禁 `eval`/`exec`(`S307`)
- [P0] 雜湊:密碼 Argon2/bcrypt;禁 md5/sha1 作安全用途 · 執法:ruff `S324`
- [P0] **HTTP client 一律帶 timeout**(`requests` 預設無限等) · 執法:ruff `S113`
- [P0] Django:`DEBUG=False` + `ALLOWED_HOSTS` 明列 + `SECRET_KEY` 走 secret 管理;
  上線前跑 `manage.py check --deploy`
  FastAPI:authz 走 dependency(`Depends`)統一執法,禁在每個 handler 自己 if
- [P0] 相依:鎖檔(`uv.lock` / `poetry.lock` / `requirements.txt` + hash)+ 安裝用
  `--frozen` / `--require-hashes`;**`pip-audit` 進 CI**(門檻切在正式相依鏈,見地板 §7)

## 效能
- [P0] 🔴 **ORM N+1**:Django `select_related`(join)/ `prefetch_related`(額外查詢);
  SQLAlchemy `selectinload` / `joinedload`。預設 lazy loading 在小資料量看不出來
  · 執法:關鍵流程測試 **assert query 數**(`django_assert_num_queries` /
    SQLAlchemy event counter),不是靠 review
- [P0] 列表一律有 limit + cursor 分頁;禁 `Model.objects.all()` 無切片直接迭代
- [P0] 🔴 **async 路徑禁同步阻塞呼叫**:`requests` / `time.sleep` / 同步 DB driver /
  檔案 IO 進 `async def` 會卡住整個事件迴圈 —— 要嘛用 async 版,要嘛丟 `run_in_executor`
  · 執法:ruff `ASYNC` 規則族 + 開發期開 `asyncio` debug mode(會警告慢回呼)
- [P0] 🔴 **worker 模型的乘法**:`worker 數 × 每 worker 連線池上限 × 實例數 < DB max_connections`。
  gunicorn 開 8 workers 每個池 10 條,兩台就是 160 條 —— 這個乘法沒算過,擴容當天會連不上
- [P1] CPU-bound 走 process pool(GIL);IO-bound 才用 thread / async
- [P1] 大資料用 generator / `iterator()` 串流,不要整張表進 list
- [P1] 熱路徑避免在迴圈裡重複建正規表達式 / 重複 import / 重複建 client

## CI-fail 禁令清單
可變預設參數 · 裸 `except` / `except: pass` · 執行期用 `assert` · naive datetime ·
float 存金額 · f-string 拼 SQL · `shell=True` · `pickle`/`eval`/`yaml.load` 吃不可信輸入 ·
無 timeout 的 HTTP 呼叫 · 散落的 `os.environ` · 直接回 ORM 物件 ·
無切片的全表查詢 · async 函式裡的同步阻塞呼叫 · mypy strict 未過 ·
`pip-audit` 有未修漏洞 · Django `DEBUG=True` 進 prod 設定
