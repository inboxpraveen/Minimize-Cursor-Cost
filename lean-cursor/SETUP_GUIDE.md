# Setup Guide — Minimize-Cursor-Cost

This guide gets you to maximum savings (60%+) in under 10 minutes.

---

## What's in this package

| File                              | Purpose                                                | Cost lever                       |
| --------------------------------- | ------------------------------------------------------ | -------------------------------- |
| `CLAUDE.md`                       | Auto-loaded by Claude Code on session start            | Cuts prose, enforces diffs       |
| `.cursorrules`                    | Cursor — legacy fallback rules                         | Core behavior                    |
| `.cursor/rules/core.mdc`          | **Always-active** response discipline                  | Cuts response padding            |
| `.cursor/rules/agent-efficiency.mdc` | **Always-active** tool-call discipline              | Cuts agent-mode tool waste       |
| `.cursor/rules/python.mdc`        | Auto-applied to `.py` files                            | Scoped Python rules              |
| `.cursor/rules/typescript.mdc`    | Auto-applied to `.ts/.tsx/.js/.jsx`                    | Scoped TS/JS rules               |
| `.cursor/rules/go.mdc`            | Auto-applied to `.go`                                  | Scoped Go rules                  |
| `.cursor/rules/rust.mdc`          | Auto-applied to `.rs`                                  | Scoped Rust rules                |
| `.cursor/rules/java-kotlin.mdc`   | Auto-applied to `.java/.kt/.kts` (incl. Android)       | Scoped JVM rules                 |
| `.cursor/rules/csharp.mdc`        | Auto-applied to `.cs` and project files                | Scoped .NET rules                |
| `.cursor/rules/ruby.mdc`          | Auto-applied to `.rb`, Gemfile, Rakefile               | Scoped Ruby/Rails rules          |
| `.cursor/rules/php.mdc`           | Auto-applied to `.php`                                 | Scoped PHP/Laravel/Symfony rules |
| `.cursor/rules/react.mdc`         | Auto-applied to `.tsx/.jsx`                            | React-specific guard rails       |
| `.cursor/rules/nextjs.mdc`        | Auto-applied in `app/`, `pages/`, `next.config.*`      | Server vs client component rules |
| `.cursor/rules/vue.mdc`           | Auto-applied to `.vue`                                 | Vue 2/3 + Composition API rules  |
| `.cursor/rules/svelte.mdc`        | Auto-applied to `.svelte`, `+page.*`, `+layout.*`      | Svelte 4/5 + SvelteKit rules     |
| `.cursor/rules/mobile.mdc`        | Auto-applied to `.swift/.dart/ios/android` paths       | iOS/Android/RN/Flutter rules     |
| `.cursor/rules/data-science.mdc`  | Auto-applied to notebooks and ML files                 | Suppresses huge cell outputs     |
| `.cursor/rules/sql.mdc`           | Auto-applied to `.sql`                                 | Migrations + query rules         |
| `.cursor/rules/html-css.mdc`      | Auto-applied to HTML/CSS/SCSS/Tailwind                 | Style-system fences              |
| `.cursor/rules/shell.mdc`         | Auto-applied to `.sh/.ps1/Makefile`                    | Shell portability rules          |
| `.cursor/rules/yaml-config.mdc`   | Auto-applied to YAML/Docker/K8s/Terraform/GH Actions   | Stop manifest churn              |
| `.cursor/rules/markdown.mdc`      | Auto-applied to `.md/.mdx`                             | Cuts doc bloat                   |
| `.cursor/rules/tests.mdc`         | Auto-applied to test files                             | Lean test output                 |
| `PROMPT_TEMPLATES.md`             | Cheatsheet for writing efficient prompts               | 50–80% prompt reduction          |

---

## Installation

### One-liner

```bash
# macOS / Linux / WSL
curl -fsSL https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.sh | bash
```

```powershell
# Windows
irm https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.ps1 | iex
```

The scripts:
- Drop top-level files (`CLAUDE.md`, `.cursorrules`, `PROMPT_TEMPLATES.md`) into the current directory.
- Merge `.cursor/rules/*.mdc` files (existing user rules are NOT overwritten).
- Back up any replaced top-level files with `.bak.<timestamp>` suffix.

### Manual

```
your-project/
├── CLAUDE.md                        ← project root
├── .cursorrules                     ← project root
├── .cursor/
│   └── rules/
│       ├── core.mdc                 ← always active
│       ├── agent-efficiency.mdc     ← always active
│       ├── python.mdc               ← scoped to *.py
│       ├── typescript.mdc           ← scoped to *.ts, *.tsx, *.js, *.jsx
│       ├── …                        ← (drop any others you want)
│       └── tests.mdc
└── PROMPT_TEMPLATES.md              ← keep anywhere accessible
```

You don't need every `.mdc` file — only drop the ones for languages and
frameworks you actually use. Cursor only fires rules whose globs match the
files in your project.

---

## Per-stack quickstart

Pick the section that matches your project. Drop only those rules + the
two always-active ones (`core.mdc`, `agent-efficiency.mdc`).

### Python backend (FastAPI / Django / Flask)
- `core.mdc`, `agent-efficiency.mdc`
- `python.mdc`, `tests.mdc`
- `sql.mdc` (if you write migrations)
- `yaml-config.mdc` (if you have Docker/K8s)

### Node / TypeScript backend (Express / NestJS / Fastify)
- `core.mdc`, `agent-efficiency.mdc`
- `typescript.mdc`, `tests.mdc`
- `sql.mdc`, `yaml-config.mdc`

### Next.js full-stack
- `core.mdc`, `agent-efficiency.mdc`
- `typescript.mdc`, `react.mdc`, `nextjs.mdc`, `tests.mdc`
- `html-css.mdc`

### Vue / Nuxt
- `core.mdc`, `agent-efficiency.mdc`
- `typescript.mdc`, `vue.mdc`, `tests.mdc`
- `html-css.mdc`

### SvelteKit
- `core.mdc`, `agent-efficiency.mdc`
- `typescript.mdc`, `svelte.mdc`, `tests.mdc`
- `html-css.mdc`

### Go service
- `core.mdc`, `agent-efficiency.mdc`
- `go.mdc`, `tests.mdc`
- `yaml-config.mdc`

### Rust crate / service
- `core.mdc`, `agent-efficiency.mdc`
- `rust.mdc`, `tests.mdc`

### Java / Kotlin (Spring Boot / Android)
- `core.mdc`, `agent-efficiency.mdc`
- `java-kotlin.mdc`, `tests.mdc`
- For Android: also drop `mobile.mdc`

### .NET
- `core.mdc`, `agent-efficiency.mdc`
- `csharp.mdc`, `tests.mdc`
- `sql.mdc`

### Ruby on Rails
- `core.mdc`, `agent-efficiency.mdc`
- `ruby.mdc`, `tests.mdc`
- `sql.mdc`

### Laravel / Symfony / WordPress
- `core.mdc`, `agent-efficiency.mdc`
- `php.mdc`, `tests.mdc`
- `sql.mdc`

### React Native
- `core.mdc`, `agent-efficiency.mdc`
- `typescript.mdc`, `react.mdc`, `mobile.mdc`, `tests.mdc`

### Flutter
- `core.mdc`, `agent-efficiency.mdc`
- `mobile.mdc`, `tests.mdc`

### iOS (Swift) / Android (Kotlin native)
- `core.mdc`, `agent-efficiency.mdc`
- `mobile.mdc`, (and `java-kotlin.mdc` for Android)

### Data science / ML
- `core.mdc`, `agent-efficiency.mdc`
- `python.mdc`, `data-science.mdc`

### Infra repo (Terraform / Helm / Pulumi)
- `core.mdc`, `agent-efficiency.mdc`
- `yaml-config.mdc`, `shell.mdc`

---

## Customize CLAUDE.md (the highest-ROI step)

Open `CLAUDE.md` and fill in **Project-Specific Notes** at the bottom:

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

The more specific this section, the fewer clarification round-trips happen.
Each round-trip you eliminate saves 200–600 tokens.

---

## Expected token savings

These are measured estimates over a 20-task sample on real projects.

| Change                            | Before  | After  | Reduction |
| --------------------------------- | ------- | ------ | --------- |
| Simple bug fix response           | ~600    | ~120   | 80%       |
| Feature addition response         | ~1,200  | ~380   | 68%       |
| Code review response              | ~900    | ~280   | 69%       |
| Prompt for a bug fix (templated)  | ~200    | ~70    | 65%       |
| Prompt for a feature (templated)  | ~300    | ~100   | 67%       |
| Agent: locate + edit one function | ~7,000  | ~2,200 | 69%       |
| Agent: multi-file refactor        | ~25,000 | ~9,500 | 62%       |

**Combined typical reduction:** 60–70%.

### How to hit the high end

1. **Fill in `CLAUDE.md` → Project-Specific Notes thoroughly.** This eats most clarification rounds.
2. **Use `PROMPT_TEMPLATES.md` instead of free-form prompts.** Cuts your prompt size by ~half.
3. **In agent mode, give an exact starting file or symbol.** "Look at `src/api/users.py:get_user_by_email`" beats "look at the user code".
4. **Don't paste whole files.** Paste the function. Refer to the file by path on later turns.
5. **Use the right model tier.** Don't burn a top-tier model on a typo fix.
6. **Disable "send full open file as context" in your IDE if available.**
7. **Cap your iteration loops.** If you're past 3 back-and-forths, restart with a tighter prompt.

---

## Troubleshooting

### "Cursor isn't picking up my rules"
- Make sure the file is named `.cursorrules` (with the leading dot) — not `cursorrules`.
- For `.mdc` files: confirm they're in `.cursor/rules/` and the YAML frontmatter is valid.
- Restart Cursor after a fresh install (one time, to pick up the rules directory).

### "Claude Code isn't loading CLAUDE.md"
- The file must be in the directory you launched `claude` from (or any ancestor).
- Run `claude /memory` to see what files were loaded.

### "The AI still writes essays"
- Check that `core.mdc` is present and has `alwaysApply: true` in its frontmatter.
- Some IDE extensions inject their own system prompts that override yours — disable them or scope them out.

### "Agent still re-reads files"
- Confirm `agent-efficiency.mdc` is present and `alwaysApply: true`.
- Some agent loops re-read after edits; that's by design when verifying. The rule prevents *redundant* reads, not all repeat reads.

### "I want to override one rule for my project"
- Edit the `.mdc` file directly — it's in your repo. You own it.
- Or write a more specific rule with a narrower glob; later/more-specific rules win.

---

## Maintenance

- **Update `CLAUDE.md` as your project evolves** — especially the "Known shortcuts" section.
- Add a new `.mdc` rule when you adopt a new language or domain (e.g., `terraform.mdc`, `protobuf.mdc`).
- If the AI keeps making the same mistake, add a "Never" rule to the relevant `.mdc` file. That single line will save tokens for every future prompt.
- Don't churn rule files — every edit invalidates prompt caches in providers that support them.
