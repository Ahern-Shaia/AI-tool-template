#!/usr/bin/env bash
# Deploy claude-starter into the current directory (new project root).
#
# Usage:
#   cd /path/to/new-project
#   bash ~/Documents/AI-tools/claude-starter/setup.sh
#
# What it does:
#   1. Copies CLAUDE.md + AGENTS.md into project root
#   2. Copies every docs/*.md that CLAUDE.md / AGENTS.md actually reference
#      (baselines, checklists, design principles, module template)
#   3. Detects the tech stack from manifests and copies the matching
#      docs/stack-rules/<stack>.md attachment (+ the generator spec for the rest)
#   4. Seeds ~/.claude/projects/<encoded-pwd>/memory/ with feedback + rule files
#   5. Prints the [PLACEHOLDER] spots that need user editing

set -euo pipefail

STARTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

if [ "$STARTER_DIR" = "$PROJECT_DIR" ]; then
  echo "ERROR: Run this script from your NEW project root, not from the starter dir." >&2
  echo "       cd /path/to/new-project && bash $STARTER_DIR/setup.sh" >&2
  exit 1
fi

echo "==> Deploying claude-starter into: $PROJECT_DIR"
echo

# ---------------------------------------------------------------------------
# 1. Core project files
# ---------------------------------------------------------------------------
copy_if_absent() {
  local src="$1"
  local dst="$2"
  if [ -f "$dst" ]; then
    echo "  SKIP $dst (already exists — diff manually if you want to merge)"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  COPY $dst"
  fi
}

echo "[1/4] Copying project-level files..."
copy_if_absent "$STARTER_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
copy_if_absent "$STARTER_DIR/AGENTS.md" "$PROJECT_DIR/AGENTS.md"

# Every doc referenced by CLAUDE.md / AGENTS.md must land in the project,
# otherwise a rule points at a file that does not exist.
# scripts/check-docs-wired.sh enforces this list stays complete.
copy_if_absent "$STARTER_DIR/docs/pre-dev-decisions.md"          "$PROJECT_DIR/docs/pre-dev-decisions.md"
copy_if_absent "$STARTER_DIR/docs/security-baseline.md"          "$PROJECT_DIR/docs/security-baseline.md"
copy_if_absent "$STARTER_DIR/docs/performance-baseline.md"       "$PROJECT_DIR/docs/performance-baseline.md"
copy_if_absent "$STARTER_DIR/docs/frontend-design-principles.md" "$PROJECT_DIR/docs/frontend-design-principles.md"
copy_if_absent "$STARTER_DIR/docs/frontend-testing.md"           "$PROJECT_DIR/docs/frontend-testing.md"
copy_if_absent "$STARTER_DIR/docs/pre-pr-checklist.md"           "$PROJECT_DIR/docs/pre-pr-checklist.md"
copy_if_absent "$STARTER_DIR/docs/cleanup-plan.md"               "$PROJECT_DIR/docs/cleanup-plan.md"
copy_if_absent "$STARTER_DIR/docs/modules/_template.md"          "$PROJECT_DIR/docs/modules/_template.md"

# ---------------------------------------------------------------------------
# 2. Tech-stack rule attachments
# ---------------------------------------------------------------------------
# Available attachments. Adding a new docs/stack-rules/<x>.md means adding it
# here too — check-docs-wired.sh fails the build if you forget.
STACK_FILES=( "typescript-nestjs.md" "python.md" "go.md" "react-nextjs.md" )

matched=()
add_stack() {
  local f="$1"
  local s
  for s in ${matched[@]+"${matched[@]}"}; do
    [ "$s" = "$f" ] && return 0
  done
  matched+=("$f")
}

echo
echo "[2/4] Detecting tech stack..."

[ -f "$PROJECT_DIR/go.mod" ] && add_stack "go.md"

if [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/requirements.txt" ] \
   || [ -f "$PROJECT_DIR/setup.py" ] || [ -f "$PROJECT_DIR/Pipfile" ]; then
  add_stack "python.md"
fi

# package.json may live at root or one level down (frontend/, apps/web/, ...)
while IFS= read -r pj; do
  [ -n "$pj" ] || continue
  grep -q '"next"'         "$pj" && add_stack "react-nextjs.md"
  grep -q '"react"'        "$pj" && add_stack "react-nextjs.md"
  grep -q '"@nestjs/core"' "$pj" && add_stack "typescript-nestjs.md"
  grep -q '"typescript"'   "$pj" && add_stack "typescript-nestjs.md"
done < <(find "$PROJECT_DIR" -maxdepth 3 -name package.json \
           -not -path '*/node_modules/*' 2>/dev/null || true)

# Manifests we recognise but have no pre-written attachment for.
unmatched=()
for m in Cargo.toml pom.xml build.gradle build.gradle.kts Gemfile composer.json mix.exs; do
  [ -f "$PROJECT_DIR/$m" ] && unmatched+=("$m")
done

# The generator spec always ships — it is the fallback path for any stack.
copy_if_absent "$STARTER_DIR/docs/stack-rules/_generator.md" "$PROJECT_DIR/docs/stack-rules/_generator.md"

if [ ${#matched[@]} -eq 0 ]; then
  echo "  (no known manifest matched)"
else
  for f in "${matched[@]}"; do
    copy_if_absent "$STARTER_DIR/docs/stack-rules/$f" "$PROJECT_DIR/docs/stack-rules/$f"
  done
fi

if [ ${#unmatched[@]} -gt 0 ] || [ ${#matched[@]} -eq 0 ]; then
  echo
  echo "  ⚠️  沒有現成附件的棧${unmatched[0]+：${unmatched[*]}}"
  echo "      → 照 docs/stack-rules/_generator.md 生成一份，由人 review 後生效"
  echo "      → 生成完把檔名加進本腳本的 STACK_FILES，否則它是孤兒"
fi

# ---------------------------------------------------------------------------
# 3. Memory seed
# ---------------------------------------------------------------------------
# Claude Code encodes project path by replacing / with - and removing leading /
ENCODED_PATH="$(echo "$PROJECT_DIR" | sed 's|^/||; s|/|-|g')"
MEMORY_DIR="$HOME/.claude/projects/-$ENCODED_PATH/memory"

echo
echo "[3/4] Seeding memory: $MEMORY_DIR"
mkdir -p "$MEMORY_DIR"
for f in "$STARTER_DIR"/memory/*.md; do
  base="$(basename "$f")"
  if [ -f "$MEMORY_DIR/$base" ]; then
    echo "  SKIP $MEMORY_DIR/$base (already exists)"
  else
    cp "$f" "$MEMORY_DIR/$base"
    echo "  SEED $base"
  fi
done

# ---------------------------------------------------------------------------
# 4. Placeholder report
# ---------------------------------------------------------------------------
echo
echo "[4/4] Placeholders that need editing:"
echo
PLACEHOLDERS=(
  "[PROJECT_NAME]"
  "[PHASE / STATE]"
  "[一句話描述產品 / 系統做什麼]"
  "[Go / Python / TypeScript / etc]"
  "[origin URL or \"TBD\"]"
  "[語言 + 版本]"
  "[DB / cache / queue]"
  "[依專案調整]"
  "[替換]"
  "[填名]"
)

for p in "${PLACEHOLDERS[@]}"; do
  hits=$(grep -rln --include='*.md' -F "$p" "$PROJECT_DIR/CLAUDE.md" "$PROJECT_DIR/AGENTS.md" "$PROJECT_DIR/docs/" 2>/dev/null | head -5 || true)
  if [ -n "$hits" ]; then
    echo "  $p"
    while IFS= read -r line; do
      echo "    in: $line"
    done <<< "$hits"
  fi
done

echo
echo "==> Done."
echo
echo "Next steps:"
echo "  1. Edit CLAUDE.md (§0 identity, §1.3 hard rules, §2 stack, §4 layout)"
echo "  2. Edit AGENTS.md (replace [bracket] placeholders with real commands)"
echo "  3. 走一遍 docs/pre-dev-decisions.md（開工前 25 格），答案寫回 CLAUDE.md"
echo "  4. 寫 docs/security-baseline.md §0 威脅模型前三名"
echo "     + docs/performance-baseline.md §0 三個數字（p95 / payload 上限 / 外呼次數上限）"
echo "  5. 確認 docs/stack-rules/ 裡的附件就是你這個專案的棧；缺的照 _generator.md 生成"
echo "  6. Edit memory/user_role.md with your own profile"
echo "  7. Pick execution mode:"
echo
echo "     Mode A (personal / prototype / internal tools):"
echo "       claude"
echo "       〈沿用 claude-starter 工作風格 — 一氣呵成、不走 PR ceremony〉"
echo
echo "     Mode B (enterprise / commercial system): [recommended for production-grade]"
echo "       claude --dangerously-skip-permissions"
echo "       〈企業級商用系統開發 — 跑完整 cross-cutting 檢查 (security / observability / cost / compat)，design doc 必含六大企業章節〉"
echo
echo "  8. Start a small module to validate: it should write M0 design doc first"
