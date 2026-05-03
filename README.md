# Minimize-Cursor-Cost
Drop-in AI rules for Cursor and Claude Code that cut project token usage by 50%+.

No fluff, no tutorials in your responses, no full-file rewrites when a patch will do.

------

## What's included

```
lean-cursor/
├── CLAUDE.md                        # Auto-loaded by Claude Code
├── .cursorrules                     # Cursor rules — all files (legacy format)
├── .cursor/
│   └── rules/
│       ├── core.mdc                 # Always-active response discipline
│       ├── python.mdc               # Applied to *.py files
│       ├── typescript.mdc           # Applied to *.ts *.tsx *.js *.jsx
│       └── tests.mdc                # Applied to test files
└── PROMPT_TEMPLATES.md              # Copy-paste prompt patterns for efficient input
```

------

## Installation

```bash
# In your project root
git clone https://github.com/YOUR_USERNAME/lean-cursor.git lean-cursor-tmp
cp lean-cursor-tmp/CLAUDE.md .
cp lean-cursor-tmp/.cursorrules .
cp -r lean-cursor-tmp/.cursor .
cp lean-cursor-tmp/PROMPT_TEMPLATES.md .
rm -rf lean-cursor-tmp
```

Or just download and copy manually — there's nothing to install.

------

## Setup (5 minutes)

Open `CLAUDE.md` and fill in the **Project-Specific Notes** section at the bottom:

```markdown
### Stack
- Language: Python 3.11
- Framework: FastAPI
- Database: PostgreSQL via SQLAlchemy

### Key paths
- Entry point: src/main.py
- Types: src/schemas/
- Shared utilities: src/utils/

### Known shortcuts
- Use `get_db()` for all DB session injection
- All API errors go through `src/core/exceptions.py`
```

This is the highest-ROI step. Project-specific shortcuts eliminate entire clarification loops.

------

## How it works

### Three layers

**1. `CLAUDE.md`** — Picked up automatically by Claude Code on session start. Enforces response discipline, sets diff-first output, and holds your project context.

**2. `.cursorrules` + `.cursor/rules/\*.mdc`** — Cursor reads these on every request. The `.mdc` files are scoped by file glob, so Python rules only fire on `.py` files and so on.

**3. `PROMPT_TEMPLATES.md`** — The human side. Copy the relevant template before each prompt to eliminate padding and produce tighter outputs.

### Core rules (applied everywhere)

- Responses start with the answer — no preamble, no sign-off
- Edits are diffs by default, not full-file rewrites
- Max 2 alternatives when options exist, with a stated recommendation
- One clarifying question at a time, not a list
- Scope guard: if a task touches >3 files unprompted, AI pauses and asks where to start

------

## Token savings

| Task                 | Without rules | With rules  | Reduction |
| -------------------- | ------------- | ----------- | --------- |
| Simple bug fix       | ~600 tokens   | ~150 tokens | 75%       |
| Feature addition     | ~1,200 tokens | ~400 tokens | 67%       |
| Code review          | ~900 tokens   | ~300 tokens | 67%       |
| Prompt for a bug fix | ~200 tokens   | ~80 tokens  | 60%       |

The single biggest win: **diff output vs full-file rewrite**. A 200-line file rewrite costs ~2,000 tokens. A patch for the same change costs ~200.

------

## Adding your own language rules

Duplicate any `.mdc` file and adjust the glob:

```markdown
---
description: Go file rules
globs: ["**/*.go"]
alwaysApply: false
---

# Go Rules
- Show only changed functions
- Match existing error handling style (errors.New vs fmt.Errorf)
- Don't add godoc unless the file already has it
```

------

## Using PROMPT_TEMPLATES.md

Instead of writing free-form prompts, copy a template:

**Bug fix:**

```
Bug in `src/api/users.py` → `get_user_by_email()`

Error:
sqlalchemy.exc.NoResultFound: No row was found for one()

Expected: return None when user not found
Actual: raises exception

Relevant code:
[paste the function]
```

**Feature:**

```
Add rate limiting to `src/middleware/auth.py`.

Requirements:
- 100 requests/minute per IP
- Return 429 with Retry-After header

Existing pattern to follow: `log_request()` in same file.
Do not touch anything outside this file.
```

Structured input → structured output → fewer tokens on both sides.

------

## Compatibility

| Tool           | Support                                                      |
| -------------- | ------------------------------------------------------------ |
| Cursor         | ✅ `.cursorrules` + `.cursor/rules/*.mdc`                     |
| Claude Code    | ✅ `CLAUDE.md`                                                |
| GitHub Copilot | Partial — `.cursorrules` ignored, but `CLAUDE.md` works as a reference |
| Windsurf       | ✅ Reads `.cursorrules`                                       |

------

## License

Apache 2.0
