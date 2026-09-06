# Setup Guide — Minimize-Cursor-Cost

This guide gets the rules installed and tuned in under 10 minutes. For what the
savings actually measure, see [Expected token savings](#expected-token-savings)
below — the published figures are historical and the current rules are being
re-measured against the
[cost-per-accepted-change benchmark](../benchmarks/README.md).

---

## What's in this package

| File                              | Purpose                                                | Cost lever                       |
| --------------------------------- | ------------------------------------------------------ | -------------------------------- |
| `AGENTS.md`                       | Cross-tool standard — Cursor, Codex, Copilot, Windsurf, Zed, Aider… | Cuts prose, enforces diffs |
| `CLAUDE.md`                       | Auto-loaded by Claude Code on session start            | Cuts prose, enforces diffs       |
| `.claude/rules/*.md`              | Claude Code path-scoped rules (`paths:` frontmatter)   | Scoped rules load only on match  |
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
| `.cursorindexingignore.example`   | Optional generated/vendor index exclusions             | Cuts retrieval noise             |

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

The default installs Cursor's `core.mdc`, `agent-efficiency.mdc`, and
`PROMPT_TEMPLATES.md`. Existing files are never overwritten.

```bash
bash install.sh --tool cursor --rules python,tests --with-index-ignore
bash install.sh --tool claude --rules python,tests
bash install.sh --tool agents
bash install.sh --tool legacy
```

```powershell
.\install.ps1 -Tool cursor -Rules 'python,tests' -WithIndexIgnore
.\install.ps1 -Tool claude -Rules 'python,tests'
.\install.ps1 -Tool agents
.\install.ps1 -Tool legacy
```

`--rules` applies to both `cursor` (installs `.mdc`) and `claude` (installs the
matching `.claude/rules/*.md`). The per-stack lists further down use the same
rule names for either client.

Use `--rules all` / `-Rules all` only when you want every scoped rule — each one
you don't need is context you pay for on every cache miss. Use `--tool all` /
`-Tool all` only for projects intentionally shared across all supported clients;
otherwise it adds duplicate behavioral context.

### Manual

Pick **one** always-on adapter, then add only the scoped rules your stack uses.

Cursor:

```
your-project/
├── .cursor/
│   └── rules/
│       ├── core.mdc                 ← always active
│       ├── agent-efficiency.mdc     ← always active
│       ├── python.mdc               ← scoped to *.py
│       └── tests.mdc                ← (drop any others you want)
└── PROMPT_TEMPLATES.md              ← keep anywhere accessible
```

Claude Code:

```
your-project/
├── CLAUDE.md                        ← project root, always loaded
├── .claude/
│   └── rules/
│       ├── python.md                ← loads when Claude reads a *.py file
│       └── tests.md
└── PROMPT_TEMPLATES.md
```

Any other agent:

```
your-project/
├── AGENTS.md                        ← project root
└── PROMPT_TEMPLATES.md
```

You don't need every rule file. Install only matching languages/frameworks;
fewer applicable rules means less context and fewer conflicting instructions.

### Context exclusions

Copy `.cursorindexingignore.example` to `.cursorindexingignore`, then remove
patterns your project needs indexed. Use it for generated output, dependencies,
caches, and large derived data. Use `.cursorignore` only when content should
also be unavailable to Cursor features; it is not a security boundary for
terminal commands or MCP tools.

---

## Per-stack quickstart

Pick the section that matches your project and install only those rules, plus
one always-on adapter: for Cursor that's `core.mdc` + `agent-efficiency.mdc`,
for Claude Code it's `CLAUDE.md`, for anything else it's `AGENTS.md`. The rule
names below are identical across clients — `--rules python,tests` installs
`python.mdc`/`tests.mdc` for Cursor and `python.md`/`tests.md` for Claude Code.

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

## Customize your adapter (the highest-ROI step)

Open whichever adapter you installed — `CLAUDE.md` or `AGENTS.md` — and fill in
**Project-Specific Notes** at the bottom:

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

⚠️ **These numbers are historical.** They come from the old 20-task sample run
against the pre-adaptive rules, and they count response and tool-result tokens
only — no retries, no correction turns, no verification. They do **not** measure
the current rules. New figures have to pass the
[cost-per-accepted-change benchmark](../benchmarks/README.md), which keeps failed
runs in the data and requires acceptance rate to hold. Read the table as a map of
where the waste sits, not as what you'll get.

| Change                            | Before  | After  | Reduction |
| --------------------------------- | ------- | ------ | --------- |
| Simple bug fix response           | ~600    | ~120   | 80%       |
| Feature addition response         | ~1,200  | ~380   | 68%       |
| Code review response              | ~900    | ~280   | 69%       |
| Prompt for a bug fix (templated)  | ~200    | ~70    | 65%       |
| Prompt for a feature (templated)  | ~300    | ~100   | 67%       |
| Agent: locate + edit one function | ~7,000  | ~2,200 | 69%       |
| Agent: multi-file refactor        | ~25,000 | ~9,500 | 62%       |

**Historical combined reduction:** 60–70%.

### How to get the most out of it

1. **Fill in `CLAUDE.md` → Project-Specific Notes thoroughly.** This eats most clarification rounds.
2. **Use `PROMPT_TEMPLATES.md` instead of free-form prompts.** Cuts your prompt size by ~half.
3. **In agent mode, give an exact starting file or symbol.** "Look at `src/api/users.py:get_user_by_email`" beats "look at the user code".
4. **Don't paste whole files.** Paste the function. Refer to the file by path on later turns.
5. **Pick the model and effort deliberately.** Drop the reasoning/effort setting
   one notch before dropping to a weaker model — it cuts tool calls, which is
   most of the bill. Don't burn a top-tier model on a typo; prices across current
   models span roughly 20×. On Cursor, check which credit pool you're drawing
   from. Details in `PROMPT_TEMPLATES.md` § Advanced cost levers.
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
- Run `/context` inside a session and check the **Memory files** list — that
  shows what actually loaded. `/memory` lists and opens the files for editing.
- Claude Code does **not** read `AGENTS.md`. If that's your canonical file, add
  a `CLAUDE.md` whose first line is `@AGENTS.md`, which imports it at session
  start. (A symlink also works, but needs Administrator or Developer Mode on
  Windows.)
- Keep `CLAUDE.md` under ~200 lines. Longer files consume more context and
  adherence drops. `/doctor` proposes trims for a checked-in `CLAUDE.md`.

### "My `.claude/rules/` files never fire"
- Each file needs `paths:` frontmatter with glob patterns. A rule with no
  `paths` field loads unconditionally — which is usually not what you want for a
  language rule.
- Path-scoped rules trigger when Claude *reads* a matching file, not on every
  tool call. Point Claude at a matching file and re-check `/context`.
- Don't copy `core`/`agent-efficiency` into `.claude/rules/` — `CLAUDE.md`
  already carries that content, and duplicating it doubles your always-on cost.

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

- **Update your adapter as your project evolves** — especially the "Known
  shortcuts" section.
- Add a new `.mdc` rule when you adopt a new language or domain (e.g.,
  `terraform.mdc`, `protobuf.mdc`). If you also use Claude Code, regenerate the
  scoped copies with `python tools/gen-claude-rules.py` rather than maintaining
  two files by hand.
- Claude Code's auto memory records corrections you repeat. If it keeps saving
  the same correction, that correction belongs in `CLAUDE.md` instead.
- If the AI keeps making the same mistake, add a "Never" rule to the relevant `.mdc` file. That single line will save tokens for every future prompt.
- Don't churn rule files. Caching matches on the prefix, so one changed byte
  means you pay full input price on the next request. Batch your rule edits and
  keep them out of the middle of a task.
