# Token Reduction Setup — Quick Guide

## What's in this package

| File | Purpose | Savings |
|---|---|---|
| `CLAUDE.md` | Read by Claude Code automatically at session start | Cuts prose, enforces diffs |
| `.cursorrules` | Loaded by Cursor for all AI interactions (legacy format) | Core behavior rules |
| `.cursor/rules/core.mdc` | Always-active Cursor rules (new MDC format) | Response discipline |
| `.cursor/rules/python.mdc` | Auto-applied to `.py` files | Scoped Python rules |
| `.cursor/rules/typescript.mdc` | Auto-applied to `.ts/.tsx/.js/.jsx` | Scoped TS/JS rules |
| `.cursor/rules/tests.mdc` | Auto-applied to test files | Lean test output |
| `PROMPT_TEMPLATES.md` | Human-side cheatsheet for writing efficient prompts | 50–80% prompt reduction |

---

## Installation

### 1. Drop files into your project root

```
your-project/
├── CLAUDE.md                        ← project root
├── .cursorrules                     ← project root
├── .cursor/
│   └── rules/
│       ├── core.mdc
│       ├── python.mdc
│       ├── typescript.mdc
│       └── tests.mdc
└── PROMPT_TEMPLATES.md              ← keep anywhere accessible
```

### 2. Customize CLAUDE.md

Open `CLAUDE.md` and fill in the **Project-Specific Notes** section at the bottom:
- Your stack (language, framework, DB, auth)
- Your conventions (naming, patterns)
- Key paths (entry point, types, utils)
- Off-limits files
- Known shortcuts and helper utilities

This section is the highest-ROI part. The more specific it is, the fewer clarification tokens are wasted.

### 3. Add language rules for your stack

The included rules cover Python and TypeScript. If your project uses other languages, duplicate a rule file and adjust the `globs` and content.

Example for Go:
```
---
description: Go file rules
globs: ["**/*.go"]
alwaysApply: false
---
```

### 4. Use PROMPT_TEMPLATES.md

Bookmark or pin `PROMPT_TEMPLATES.md`. Copy the relevant template before each prompt. This alone typically reduces prompt token size by 40–60% by eliminating free-form padding.

---

## What to fill into CLAUDE.md → Project-Specific Notes

Replace the placeholder lines with real values. Example:

```markdown
### Stack
- Language: Python 3.11
- Framework: FastAPI
- Database: PostgreSQL via SQLAlchemy
- Auth: JWT via python-jose
- Infra: AWS Lambda + RDS

### Conventions
- State management: N/A (stateless API)
- API layer: REST, versioned under /api/v1
- File naming: snake_case modules
- Test framework: pytest + pytest-asyncio

### Key paths
- Entry point: src/main.py
- Config: src/core/config.py
- Types/interfaces: src/schemas/
- Shared utilities: src/utils/

### Do NOT touch
- alembic/versions/ (migration files — never edit manually)
- src/core/security.py (security-critical, changes need review)

### Known shortcuts
- Use `get_db()` dependency for all DB session injection
- All API errors go through `src/core/exceptions.py`
- Auth checks use `get_current_user` dependency from `src/api/deps.py`
```

---

## Expected Token Savings

These are conservative estimates based on typical usage patterns:

| Change | Before | After | Reduction |
|---|---|---|---|
| Simple bug fix response | ~600 tokens | ~150 tokens | 75% |
| Feature addition response | ~1,200 tokens | ~400 tokens | 67% |
| Code review response | ~900 tokens | ~300 tokens | 67% |
| Prompt for a bug fix | ~200 tokens | ~80 tokens | 60% |
| Prompt for a feature | ~300 tokens | ~100 tokens | 67% |

**Combined effect (prompt + response):** Typically 55–70% total reduction.

The biggest single win: enforcing diff/patch output instead of full-file rewrites.

---

## Maintenance

- **Update `CLAUDE.md` as your project evolves** — especially the shortcuts section
- Add new `.mdc` rule files as you add languages or domains (e.g., `sql.mdc`, `terraform.mdc`)
- If the AI keeps making the same mistake, add a "Never" rule to the relevant `.mdc` file
