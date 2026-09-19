#!/usr/bin/env bash
# 守衛：擋住「規則指向一個不會被部署 / 不存在 / 沒人引用的檔」。
#
# 為什麼存在：本 repo 曾同時發生三種漂移 ——
#   ① CLAUDE.md R18 說「docs/security-baseline.md 全文是 P0」，而 setup.sh 不複製它
#      → 新專案套完模板，那條鐵則指向一個不存在的檔
#   ② docs/typescript-nestjs-rules.md（今為 docs/stack-rules/typescript-nestjs.md）
#      只被 README 的目錄樹畫到，沒有任何鐵則引用、
#      setup.sh 也不複製 → 孤兒
#   ③ 新增棧附件卻忘了加進 setup.sh 的 STACK_FILES → 永遠不會被部署
#
# 用法：bash scripts/check-docs-wired.sh   （0 = 全過，1 = 有漂移）

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

fail=0
err() { echo "  ❌ $*"; fail=1; }
ok()  { echo "  ✅ $*"; }

REF_SOURCES=(CLAUDE.md AGENTS.md README.md)

# 蒐集三份入口文件提到的 docs 路徑（含 <placeholder> 的泛指路徑抓不到，這是刻意的）
refs="$(grep -ho 'docs/[A-Za-z0-9/_.-]*\.md' "${REF_SOURCES[@]}" | sort -u)"

echo "== [1/4] 引用的檔是否存在 =="
while IFS= read -r r; do
  [ -n "$r" ] || continue
  if [ -f "$r" ]; then ok "$r"; else err "引用了不存在的檔：${r}（出現在 ${REF_SOURCES[*]}）"; fi
done <<< "$refs"

echo
echo "== [2/4] 引用的檔是否真的會被 setup.sh 部署 =="
# 🔴 只看 copy_if_absent 那幾行，不是整份 setup.sh ——
# 否則 Next-steps 的說明文字提到某個檔名，就會讓「忘了複製它」看起來是綠的
# （突變測試抓到的真漏：拿掉 performance-baseline 的複製行，守衛原本照樣全綠）
deployed="$(grep '^copy_if_absent' setup.sh | grep -o 'docs/[A-Za-z0-9/_.-]*\.md' | sort -u)"
while IFS= read -r r; do
  [ -n "$r" ] || continue
  case "$r" in
    docs/stack-rules/*) continue ;;   # 棧附件是條件複製，在 [4/4] 單獨檢查
  esac
  if echo "$deployed" | grep -qxF "$r"; then ok "$r"; else err "被引用但 setup.sh 不部署：$r"; fi
done <<< "$refs"

echo
echo "== [3/4] 有沒有沒人引用的孤兒 doc =="
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if echo "$refs" | grep -qxF "$f"; then ok "$f"; else err "孤兒：$f 沒有任何入口文件引用它"; fi
done <<< "$(find docs -name '*.md' -not -path 'docs/stack-rules/*' | sort)"

echo
echo "== [4/4] 棧附件是否接進 setup.sh 的 STACK_FILES =="
# 🔴 只看 STACK_FILES 那一行，不是整份 setup.sh ——
# 否則偵測邏輯裡的 add_stack "go.md" 會讓「STACK_FILES 漏了 go.md」看起來是綠的
# （突變測試抓到的第二個真漏）
stack_files_line="$(grep '^STACK_FILES=' setup.sh || true)"
[ -n "$stack_files_line" ] || err "setup.sh 找不到 STACK_FILES 宣告"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  b="$(basename "$f")"
  if [ "$b" = "_generator.md" ]; then
    if grep -qF "stack-rules/_generator.md" setup.sh; then ok "${b}（無條件部署）"
    else err "生成器規格沒被 setup.sh 複製：$f"; fi
    continue
  fi
  if echo "$stack_files_line" | grep -qF "\"$b\""; then ok "$b"
  else err "棧附件沒進 setup.sh 的 STACK_FILES：${f}（它永遠不會被部署）"; fi
done <<< "$(find docs/stack-rules -name '*.md' | sort)"

echo
if [ "$fail" -eq 0 ]; then
  echo "全過：文件、鐵則、部署腳本三者對得上。"
else
  echo "有漂移 —— 修好再 commit（規則與接線同一個 commit）。"
fi
exit "$fail"
