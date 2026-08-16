#!/usr/bin/env bash
# Install only the adapters and scoped rules the target project needs.

set -euo pipefail

usage() {
  echo "Usage: bash install.sh [--tool cursor|claude|legacy|all] [--rules core|all|name,...] [--with-index-ignore]"
}

TOOL="${MCC_TOOL:-cursor}"
RULES="${MCC_RULES:-core}"
WITH_INDEX_IGNORE="${MCC_WITH_INDEX_IGNORE:-0}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tool) TOOL="${2:?--tool requires a value}"; shift 2 ;;
    --rules) RULES="${2:?--rules requires a value}"; shift 2 ;;
    --with-index-ignore) WITH_INDEX_IGNORE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$TOOL" in
  cursor|claude|legacy|all) ;;
  *) echo "Invalid tool: $TOOL" >&2; usage >&2; exit 2 ;;
esac

REPO_URL="${MCC_REPO_URL:-https://github.com/inboxpraveen/Minimize-Cursor-Cost}"
SRC_SUBDIR="lean-cursor"
TMP_DIR="$(mktemp -d)"
TARGET_DIR="$(pwd)"
added=0
skipped=0

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

if ! command -v git >/dev/null 2>&1; then
  echo "git is required but not found." >&2
  exit 1
fi

echo "Installing Minimize-Cursor-Cost ($TOOL) into: $TARGET_DIR"
git clone --depth=1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1
SRC="$TMP_DIR/$SRC_SUBDIR"

copy_if_missing() {
  local src="$1" dest="$2" label="$3"
  if [ -e "$dest" ]; then
    skipped=$((skipped+1))
    echo "  Skipping existing $label"
  else
    cp "$src" "$dest"
    added=$((added+1))
  fi
}

copy_rule() {
  local rule="$1"
  local src="$SRC/.cursor/rules/$rule.mdc"
  if [ ! -f "$src" ]; then
    echo "Unknown rule: $rule" >&2
    exit 2
  fi
  copy_if_missing "$src" "$TARGET_DIR/.cursor/rules/$rule.mdc" "rule: $rule.mdc"
}

copy_if_missing "$SRC/PROMPT_TEMPLATES.md" "$TARGET_DIR/PROMPT_TEMPLATES.md" "PROMPT_TEMPLATES.md"

case "$TOOL" in
  claude|all)
    copy_if_missing "$SRC/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md (project notes preserved)"
    ;;
esac

case "$TOOL" in
  legacy|all)
    copy_if_missing "$SRC/.cursorrules" "$TARGET_DIR/.cursorrules" ".cursorrules"
    ;;
esac

if [ "$TOOL" = "cursor" ] || [ "$TOOL" = "all" ]; then
  mkdir -p "$TARGET_DIR/.cursor/rules"
  copy_rule "core"
  copy_rule "agent-efficiency"

  if [ "$RULES" = "all" ]; then
    for file in "$SRC/.cursor/rules/"*.mdc; do
      rule="$(basename "$file" .mdc)"
      case "$rule" in core|agent-efficiency) continue ;; esac
      copy_rule "$rule"
    done
  elif [ -n "$RULES" ] && [ "$RULES" != "core" ]; then
    old_ifs="$IFS"; IFS=','
    for rule in $RULES; do
      rule="${rule//[[:space:]]/}"
      [ -n "$rule" ] && copy_rule "$rule"
    done
    IFS="$old_ifs"
  fi

  if [ "$WITH_INDEX_IGNORE" = "1" ]; then
    copy_if_missing "$SRC/.cursorindexingignore.example" "$TARGET_DIR/.cursorindexingignore" ".cursorindexingignore"
  fi
fi

echo "Installed: $added file(s); skipped existing: $skipped."
if [ "$TOOL" = "claude" ] || [ "$TOOL" = "all" ]; then
  echo "Next: fill in CLAUDE.md Project-Specific Notes if they are empty."
fi
