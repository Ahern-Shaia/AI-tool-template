#!/usr/bin/env bash
# setup.sh 的冒煙測試：用四個假專案驗「技術棧偵測 → 帶上對應附件」真的成立。
#
# 為什麼存在：偵測邏輯錯了不會有任何錯誤訊息 —— 只是某個專案永遠拿不到它的棧規則，
# 而輸出看起來完全正常。這種失效只有斷言抓得到。
#
# 用法：bash scripts/smoke-setup.sh   （0 = 全過）

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
pass_n=0

# run_case <name> <expected-csv|-> <setup-commands...>
run_case() {
  local name="$1"; shift
  local expected="$1"; shift
  local dir="$TMP/$name"
  mkdir -p "$dir"
  ( cd "$dir" && eval "$@" )
  ( cd "$dir" && HOME="$dir/home" bash "$REPO_DIR/setup.sh" >"$dir/out.txt" 2>&1 ) \
    || { echo "  ❌ $name: setup.sh 非零退出"; sed -n '1,5p' "$dir/out.txt"; fail=1; return; }

  local got
  # pipefail 下 grep 無命中會讓整條管線回 1，這裡「沒有附件」是合法結果，故吞掉
  got="$(cd "$dir" && { ls docs/stack-rules 2>/dev/null || true; } | grep -v '^_generator.md$' | sort | tr '\n' ',' | sed 's/,$//' || true)"
  [ -z "$got" ] && got="-"

  if [ "$got" = "$expected" ]; then
    echo "  ✅ $name  ->  $got"
    pass_n=$((pass_n + 1))
  else
    echo "  ❌ $name  期望 [$expected]  實得 [$got]"
    fail=1
  fi

  # _generator.md 一律要在（任何棧的 fallback 路徑）
  if [ ! -f "$dir/docs/stack-rules/_generator.md" ]; then
    echo "  ❌ $name: _generator.md 沒被部署"
    fail=1
  fi
  # 被鐵則引用的地板一律要在
  local d
  for d in security-baseline.md performance-baseline.md pre-dev-decisions.md \
           frontend-design-principles.md frontend-testing.md; do
    if [ ! -f "$dir/docs/$d" ]; then
      echo "  ❌ $name: docs/$d 沒被部署（R18/R19/R20 會指向不存在的檔）"
      fail=1
    fi
  done
}

echo "== setup.sh 技術棧偵測冒煙測試 =="

run_case "empty"        "-"                             "true"
run_case "go"           "go.md"                         "echo 'module x' > go.mod"
run_case "python"       "python.md"                     "touch pyproject.toml"
run_case "python-req"   "python.md"                     "touch requirements.txt"
run_case "next-nested"  "react-nextjs.md"               "mkdir -p frontend && printf '{\"dependencies\":{\"next\":\"^15\",\"react\":\"^19\"}}' > frontend/package.json"
run_case "nest"         "typescript-nestjs.md"          "printf '{\"dependencies\":{\"@nestjs/core\":\"^10\"}}' > package.json"
run_case "nest+next"    "react-nextjs.md,typescript-nestjs.md" \
  "printf '{\"dependencies\":{\"@nestjs/core\":\"^10\"}}' > package.json && mkdir -p web && printf '{\"dependencies\":{\"next\":\"^15\"}}' > web/package.json"
run_case "go+python"    "go.md,python.md"               "echo 'module x' > go.mod && touch pyproject.toml"

# 未知棧要印出生成器指引，而不是安靜略過
echo
echo "== 未知棧的 fallback 指引 =="
d="$TMP/rust"; mkdir -p "$d"; touch "$d/Cargo.toml"
( cd "$d" && HOME="$d/home" bash "$REPO_DIR/setup.sh" >"$d/out.txt" 2>&1 )
if grep -q "_generator.md" "$d/out.txt" && grep -q "Cargo.toml" "$d/out.txt"; then
  echo "  ✅ rust: 有印出「照 _generator.md 生成」並點名 Cargo.toml"
  pass_n=$((pass_n + 1))
else
  echo "  ❌ rust: 未知棧沒有印出生成器指引"
  fail=1
fi

echo
echo "通過 $pass_n 項。"
if [ "$fail" -ne 0 ]; then
  echo "冒煙測試有紅 —— 修好再 commit。"
fi
exit "$fail"
