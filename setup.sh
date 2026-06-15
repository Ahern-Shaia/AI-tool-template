#!/usr/bin/env bash
# Deploy claude-starter into the current directory (new project root).
#
# Usage:
#   cd /path/to/new-project
#   bash ~/Documents/AI-tools/claude-starter/setup.sh
#
# What it does:
#   1. Copies CLAUDE.md + AGENTS.md into project root
#   2. Copies docs/{pre-pr-checklist,cleanup-plan}.md + docs/modules/_template.md
#   3. Seeds ~/.claude/projects/<encoded-pwd>/memory/ with feedback + rule files
#   4. Prints the [PLACEHOLDER] spots that need user editing

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

echo "[1/3] Copying project-level files..."
copy_if_absent "$STARTER_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
copy_if_absent "$STARTER_DIR/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
copy_if_absent "$STARTER_DIR/docs/pre-pr-checklist.md" "$PROJECT_DIR/docs/pre-pr-checklist.md"
copy_if_absent "$STARTER_DIR/docs/cleanup-plan.md" "$PROJECT_DIR/docs/cleanup-plan.md"
copy_if_absent "$STARTER_DIR/docs/modules/_template.md" "$PROJECT_DIR/docs/modules/_template.md"

# ---------------------------------------------------------------------------
# 2. Memory seed
# ---------------------------------------------------------------------------
# Claude Code encodes project path by replacing / with - and removing leading /
ENCODED_PATH="$(echo "$PROJECT_DIR" | sed 's|^/||; s|/|-|g')"
MEMORY_DIR="$HOME/.claude/projects/-$ENCODED_PATH/memory"

echo
echo "[2/3] Seeding memory: $MEMORY_DIR"
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
# 3. Placeholder report
# ---------------------------------------------------------------------------
echo
echo "[3/3] Placeholders that need editing:"
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
echo "  3. Edit memory/user_role.md with your own profile"
echo "  4. Pick execution mode:"
echo
echo "     Mode A (personal / prototype / internal tools):"
echo "       claude"
echo "       〈沿用 claude-starter 工作風格 — 一氣呵成、不走 PR ceremony〉"
echo
echo "     Mode B (enterprise / commercial system): [recommended for production-grade]"
echo "       claude --dangerously-skip-permissions"
echo "       〈企業級商用系統開發 — 跑完整 cross-cutting 檢查 (security / observability / cost / compat)，design doc 必含六大企業章節〉"
echo
echo "  5. Start a small module to validate: it should write M0 design doc first"
