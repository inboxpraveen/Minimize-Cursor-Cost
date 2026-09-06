#!/usr/bin/env bash
# Install only the adapters and scoped rules the target project needs.

set -euo pipefail

usage() {
  echo "Usage: bash install.sh [--tool cursor|claude|agents|legacy|all] [--rules core|all|name,...] [--with-index-ignore]"
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
  cursor|claude|agents|legacy|all) ;;
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

case "$TOOL" in
  agents|legacy)
    [ "$RULES" != "core" ] && echo "Note: --rules is ignored for --tool $TOOL." >&2
    ;;
esac
if [ "$WITH_INDEX_IGNORE" = "1" ] && [ "$TOOL" != "cursor" ] && [ "$TOOL" != "all" ]; then
  echo "Note: --with-index-ignore is ignored for --tool $TOOL." >&2
fi

echo "Installing Minimize-Cursor-Cost ($TOOL) into: $TARGET_DIR"
if ! git clone --depth=1 --quiet "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1; then
  echo "git clone failed for $REPO_URL" >&2
  exit 1
fi
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

# $1 = rule name, $2 = cursor|claude
copy_rule() {
  local rule="$1" flavor="$2" src dest
  if [ "$flavor" = "claude" ]; then
    src="$SRC/.claude/rules/$rule.md"
    dest="$TARGET_DIR/.claude/rules/$rule.md"
  else
    src="$SRC/.cursor/rules/$rule.mdc"
    dest="$TARGET_DIR/.cursor/rules/$rule.mdc"
  fi
  if [ ! -f "$src" ]; then
    echo "Unknown rule for $flavor: $rule" >&2
    exit 2
  fi
  copy_if_missing "$src" "$dest" "$flavor rule: $(basename "$src")"
}

# $1 = cursor|claude — installs the rules named by $RULES
install_scoped_rules() {
  local flavor="$1" dir ext rule file
  if [ "$flavor" = "claude" ]; then
    dir="$SRC/.claude/rules"; ext="md"
  else
    dir="$SRC/.cursor/rules"; ext="mdc"
  fi

  if [ "$RULES" = "all" ]; then
    for file in "$dir/"*."$ext"; do
      rule="$(basename "$file" ".$ext")"
      case "$rule" in core|agent-efficiency) continue ;; esac
      copy_rule "$rule" "$flavor"
    done
  elif [ -n "$RULES" ] && [ "$RULES" != "core" ]; then
    old_ifs="$IFS"; IFS=','
    for rule in $RULES; do
      rule="$(printf '%s' "$rule" | tr -d '[:space:]')"
      [ -n "$rule" ] && copy_rule "$rule" "$flavor"
    done
    IFS="$old_ifs"
  fi
}

copy_if_missing "$SRC/PROMPT_TEMPLATES.md" "$TARGET_DIR/PROMPT_TEMPLATES.md" "PROMPT_TEMPLATES.md"

case "$TOOL" in
  claude|all)
    copy_if_missing "$SRC/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md (project notes preserved)"
    if [ "$RULES" != "core" ]; then
      mkdir -p "$TARGET_DIR/.claude/rules"
      install_scoped_rules claude
    fi
    ;;
esac

case "$TOOL" in
  agents|all)
    copy_if_missing "$SRC/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md (project notes preserved)"
    ;;
esac

case "$TOOL" in
  legacy|all)
    copy_if_missing "$SRC/.cursorrules" "$TARGET_DIR/.cursorrules" ".cursorrules"
    ;;
esac

if [ "$TOOL" = "cursor" ] || [ "$TOOL" = "all" ]; then
  mkdir -p "$TARGET_DIR/.cursor/rules"
  copy_rule "core" cursor
  copy_rule "agent-efficiency" cursor
  install_scoped_rules cursor

  if [ "$WITH_INDEX_IGNORE" = "1" ]; then
    copy_if_missing "$SRC/.cursorindexingignore.example" "$TARGET_DIR/.cursorindexingignore" ".cursorindexingignore"
  fi
fi

echo "Installed: $added file(s); skipped existing: $skipped."
case "$TOOL" in
  claude|agents|all)
    echo "Next: fill in the Project-Specific Notes section if it is empty."
    ;;
esac
