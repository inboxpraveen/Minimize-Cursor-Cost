#!/usr/bin/env bash
# install.sh — Drop Minimize-Cursor-Cost rules into the current project.
# macOS / Linux / WSL.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.sh | bash
# or:
#   bash install.sh

set -euo pipefail

REPO_URL="https://github.com/inboxpraveen/Minimize-Cursor-Cost"
SRC_SUBDIR="lean-cursor"
TMP_DIR="$(mktemp -d)"
TARGET_DIR="$(pwd)"

echo "→ Installing Minimize-Cursor-Cost into: $TARGET_DIR"

# The repo is cloned into a system temp dir. Only the lean-cursor/ subtree is
# copied into your project — top-level repo files (assets/, README.md, LICENSE,
# install.*, CONTRIBUTING.md) never touch your project. The temp clone, including
# the assets/ folder, is wiped by this trap on script exit.
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

if ! command -v git >/dev/null 2>&1; then
  echo "✗ git is required but not found. Install git and re-run." >&2
  exit 1
fi

git clone --depth=1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1

SRC="$TMP_DIR/$SRC_SUBDIR"

# Backup any existing files we'd overwrite
backup() {
  local f="$1"
  if [ -e "$TARGET_DIR/$f" ]; then
    local bak="$TARGET_DIR/${f}.bak.$(date +%s)"
    echo "  • Backing up existing $f → ${bak##*/}"
    mv "$TARGET_DIR/$f" "$bak"
  fi
}

backup "CLAUDE.md"
backup ".cursorrules"
backup "PROMPT_TEMPLATES.md"

cp "$SRC/CLAUDE.md"           "$TARGET_DIR/CLAUDE.md"
cp "$SRC/.cursorrules"        "$TARGET_DIR/.cursorrules"
cp "$SRC/PROMPT_TEMPLATES.md" "$TARGET_DIR/PROMPT_TEMPLATES.md"

# Merge .cursor/rules: don't clobber user rules; only add ones that don't exist.
mkdir -p "$TARGET_DIR/.cursor/rules"
added=0; skipped=0
for f in "$SRC/.cursor/rules/"*.mdc; do
  name="$(basename "$f")"
  dest="$TARGET_DIR/.cursor/rules/$name"
  if [ -e "$dest" ]; then
    skipped=$((skipped+1))
    echo "  • Skipping existing rule: $name"
  else
    cp "$f" "$dest"
    added=$((added+1))
  fi
done

echo
echo "✓ Installed."
echo "  • CLAUDE.md, .cursorrules, PROMPT_TEMPLATES.md → project root"
echo "  • $added new rules added to .cursor/rules/   ($skipped existing skipped)"
echo "  • Temp clone (incl. assets/ and other repo files) will be removed on exit."
echo
echo "Next: open CLAUDE.md and fill in the 'Project-Specific Notes' section."
echo "      That single edit is the highest-ROI step."
