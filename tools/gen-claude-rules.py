#!/usr/bin/env python3
"""Generate lean-cursor/.claude/rules/*.md from lean-cursor/.cursor/rules/*.mdc.

Cursor scopes rules with `globs:`; Claude Code scopes them with `paths:`. The
`.mdc` files are the single source of truth — this script rewrites only the
frontmatter so both clients load the same rule text, and only when a matching
file is in context.

Always-active rules (`alwaysApply: true`) are not emitted: CLAUDE.md already
carries that content, and shipping it twice would put duplicate always-on
context in every session.

Usage:
    python tools/gen-claude-rules.py            # write files
    python tools/gen-claude-rules.py --check    # fail if files are stale
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "lean-cursor" / ".cursor" / "rules"
OUT_DIR = ROOT / "lean-cursor" / ".claude" / "rules"


def split_frontmatter(text: str) -> tuple[dict[str, str], str]:
    if not text.startswith("---\n"):
        raise ValueError("missing frontmatter")
    end = text.index("\n---\n", 3)
    fields: dict[str, str] = {}
    for line in text[4:end].splitlines():
        if ":" in line and not line.startswith((" ", "\t")):
            key, _, value = line.partition(":")
            fields[key.strip()] = value.strip()
    return fields, text[end + len("\n---\n") :].lstrip("\n")


def render(globs: list[str], body: str) -> str:
    paths = "\n".join(f'  - "{g}"' for g in globs)
    return f"---\npaths:\n{paths}\n---\n\n{body}"


def main() -> int:
    check = "--check" in sys.argv[1:]
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    expected: dict[Path, str] = {}
    for src in sorted(SRC_DIR.glob("*.mdc")):
        fields, body = split_frontmatter(src.read_text(encoding="utf-8"))
        if fields.get("alwaysApply") == "true":
            continue
        globs = json.loads(fields.get("globs") or "[]")
        if not globs:
            print(f"warning: {src.name} has no globs; skipped", file=sys.stderr)
            continue
        expected[OUT_DIR / f"{src.stem}.md"] = render(globs, body)

    stale = [
        path
        for path, content in expected.items()
        if not path.exists() or path.read_text(encoding="utf-8") != content
    ]
    orphans = [p for p in OUT_DIR.glob("*.md") if p not in expected]

    if check:
        for path in stale + orphans:
            print(f"stale: {path.relative_to(ROOT)}")
        if stale or orphans:
            print("Run: python tools/gen-claude-rules.py", file=sys.stderr)
            return 1
        print(f"{len(expected)} rule(s) up to date.")
        return 0

    for path, content in expected.items():
        with open(path, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(content)
    for path in orphans:
        path.unlink()
    print(f"Wrote {len(expected)} rule(s) to {OUT_DIR.relative_to(ROOT)}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
