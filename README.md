# Minimize-Cursor-Cost

> Drop-in AI rules for Cursor, Claude Code, Codex, Copilot, Windsurf, and any
> other agent that reads `AGENTS.md` — designed to reduce token usage without
> reducing accepted-change quality.

No fluff in your AI's responses. No tutorials when you asked for a fix. No
full-file rewrites when a 5-line patch will do. No re-reading the same file
six times in a single chat.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
![Languages: 14+](https://img.shields.io/badge/languages-14%2B-brightgreen)
![Frameworks: 10+](https://img.shields.io/badge/frameworks-10%2B-brightgreen)
![Setup time: 60s](https://img.shields.io/badge/setup-60s-orange)

<img src="./assets/Main-Diagram.png" alt="Logo">

---

## TL;DR

```bash
# macOS / Linux / WSL
curl -fsSL https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.sh | bash
```

```powershell
# Windows
irm https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.ps1 | iex
```

The default installs only Cursor's two core rules plus prompt templates. Choose
tool and stack adapters explicitly when you need more — `--tool agents` for the
cross-tool `AGENTS.md`, `--tool claude` for Claude Code.

---

## What's included

```
lean-cursor/
├── AGENTS.md                           # Cross-tool standard — Cursor, Codex, Copilot, Windsurf, Zed…
├── CLAUDE.md                           # Auto-loaded by Claude Code on session start
├── .cursorrules                        # Cursor — legacy fallback rules
├── .claude/
│   └── rules/                          # Same scoped rules, Claude Code `paths:` format
│       └── *.md                        # Generated from .cursor/rules/*.mdc
├── .cursor/
│   └── rules/
│       ├── core.mdc                    # 🔥 Always-active response discipline
│       ├── agent-efficiency.mdc        # 🔥 Always-active tool-call discipline
│       │
│       ├── python.mdc                  # *.py
│       ├── typescript.mdc              # *.ts, *.tsx, *.js, *.jsx
│       ├── go.mdc                      # *.go
│       ├── rust.mdc                    # *.rs
│       ├── java-kotlin.mdc             # *.java, *.kt, *.kts
│       ├── csharp.mdc                  # *.cs, *.csproj, *.sln
│       ├── ruby.mdc                    # *.rb, Gemfile, Rakefile
│       ├── php.mdc                     # *.php
│       │
│       ├── react.mdc                   # *.tsx, *.jsx (component layer)
│       ├── nextjs.mdc                  # app/, pages/, middleware.ts, next.config.*
│       ├── vue.mdc                     # *.vue
│       ├── svelte.mdc                  # *.svelte, +page.*, +layout.*
│       ├── mobile.mdc                  # Swift, Kotlin Android, RN, Flutter
│       ├── data-science.mdc            # *.ipynb, notebooks/, ML files
│       │
│       ├── sql.mdc                     # *.sql + migrations
│       ├── html-css.mdc                # *.html, *.css, *.scss, Tailwind
│       ├── shell.mdc                   # *.sh, *.ps1, Makefile
│       ├── yaml-config.mdc             # Docker, K8s, Terraform, GH Actions
│       ├── markdown.mdc                # *.md, *.mdx
│       └── tests.mdc                   # *.test.*, *.spec.*, test_*.py
│
├── PROMPT_TEMPLATES.md                 # Copy-paste prompt patterns
├── .cursorindexingignore.example       # Optional generated/vendor exclusions
└── SETUP_GUIDE.md                      # Per-stack quickstarts + troubleshooting

tools/
└── gen-claude-rules.py                 # Regenerates .claude/rules/ from .cursor/rules/
```

---

## How the rules reduce cost

The first version of this project focused on **response-side** savings —
diffs over rewrites, no preamble, scoped explanations. That covers about half
of the waste.

The other half lives in **agent mode**, where the AI uses tools (read files,
search, run commands) and pipes the results back into context. A single
`read_file` of a 1,000-line file can cost more than the entire response. A
"let me look around the repo first" instinct can burn 5–10k tokens before any
work happens.

This release adds rules that attack agent-mode waste directly:

- **`agent-efficiency.mdc`** — bans re-reading files, re-listing directories,
  and serial tool calls when parallel works.
- **Search-before-read** discipline — use `grep` for known symbols instead of
  reading whole files speculatively.
- **No build/test/lint after every edit** — only on risky changes or on user request.
- **Stop-when-done** — no "for safety" verification rounds, no summary of what
  the diff already shows.
- **Targeted reads** for files > 500 lines — never load the whole file just to
  find one function.

It also trims the rules you pay for on *every* request:

- **Scoped rules for Claude Code, not just Cursor.** Claude Code reads
  path-scoped rules from `.claude/rules/*.md`, which only load when you touch a
  matching file. All 20 language rules now ship in that format too, so a Python
  project stops carrying React rules around.
- **One adapter, not four.** `CLAUDE.md`, `AGENTS.md` and `.cursorrules` say the
  same things. Install two and you send those rules twice. The installer picks
  one by default.
- **Install only matching rules.** A Vue rule in a Go repo is pure overhead.

The adaptive rules now optimize cost per accepted change, including retries and
verification. Current savings will be published after the new benchmark reaches
the required sample size.

---

## Previous benchmark (pre-adaptive rules)

| Task                              | No rules       | Previous pack | Historical reduction |
| --------------------------------- | -------------- | ------------- | -------------------- |
| Simple bug fix (response)         | ~600 tokens    | ~120 tokens   | **80%**              |
| Feature addition (response)       | ~1,200 tokens  | ~380 tokens   | **68%**              |
| Code review (response)            | ~900 tokens    | ~280 tokens   | **69%**              |
| Bug fix (your prompt, templated)  | ~200 tokens    | ~70 tokens    | **65%**              |
| Agent: locate + edit one function | ~7,000 tokens  | ~2,200 tokens | **69%**              |
| Agent: multi-file refactor        | ~25,000 tokens | ~9,500 tokens | **62%**              |

These figures came from the previous 20-task token-I/O sample and are retained
only as historical results; they do not measure the adaptive rules. New results
must pass the [cost-per-accepted-change benchmark](benchmarks/README.md), which
includes failed runs, correction turns, verification, and quality regressions.

The biggest single win is still **diff output vs full-file rewrite**: a
200-line file rewrite costs ~2,000 tokens, the patch for the same change costs
~200.

---

## Model routing — the other half of the bill

Rules decide how many tokens a task spends. The model decides what each token
costs — and that gap has grown a lot. List prices per million tokens, **as of
2026-09-06**; check the sources before you rely on them:

| Model                  | Input | Output | Cached input |
| ---------------------- | ----- | ------ | ------------ |
| Cursor Composer 2.5    | $0.50 | $2.50  | $0.20        |
| Claude Haiku 4.5       | $1    | $5     | see docs     |
| Claude Sonnet 5        | $2    | $10    | see docs     |
| Cursor Grok 4.6 / 4.5  | $2    | $6     | $0.50        |
| Claude Opus 5          | $5    | $25    | see docs     |
| OpenAI GPT-6 Astra     | $10   | $50    | $1           |

Anthropic prices cache reads and cache writes separately per model — check the
pricing page rather than assuming a ratio.

Sources: [Anthropic pricing](https://claude.com/pricing#api) ·
[Cursor models & pricing](https://cursor.com/docs/models-and-pricing) ·
[OpenAI GPT-6 Astra](https://openai.com/index/gpt-6-astra/)

That's a 20× spread from top to bottom. Three habits follow — these are yours
to apply, not something a rule file can do for you:

1. **Turn effort down before you turn the model down.** Most models now have a
   reasoning/effort setting. One notch down on a good model usually beats
   switching to a weaker one, and it cuts the number of tool calls.
2. **Don't run the top tier on typo fixes.** Save it for architecture and
   debugging you can't reason through yourself.
3. **Keep your rule files still.** Cached input is 2–10× cheaper than fresh
   input, but caching matches on the prefix — edit `CLAUDE.md` mid-task and you
   pay full price for the whole thing again.

Cursor splits usage into two pools: its own models (Composer 2.5, Grok) come
with a generous allowance, while Claude, GPT and Gemini bill against a separate
pool at API rates. Which pool your long agent sessions land in is the single
biggest thing on your Cursor bill.

[`PROMPT_TEMPLATES.md`](lean-cursor/PROMPT_TEMPLATES.md) § Advanced cost levers
has the longer version.

---

## Supported languages & stacks

| Language / stack       | File rule                  |
| ---------------------- | -------------------------- |
| Python                 | `python.mdc`               |
| TypeScript / JavaScript| `typescript.mdc`           |
| Go                     | `go.mdc`                   |
| Rust                   | `rust.mdc`                 |
| Java / Kotlin (+ Android) | `java-kotlin.mdc`       |
| C# / .NET              | `csharp.mdc`               |
| Ruby (+ Rails)         | `ruby.mdc`                 |
| PHP (+ Laravel/Symfony/WP) | `php.mdc`              |
| SQL (+ migrations)     | `sql.mdc`                  |
| HTML / CSS / SCSS / Tailwind | `html-css.mdc`       |
| Shell / Bash / PowerShell | `shell.mdc`             |
| Markdown / MDX         | `markdown.mdc`             |

| Framework / domain     | File rule                  |
| ---------------------- | -------------------------- |
| React                  | `react.mdc`                |
| Next.js (App + Pages)  | `nextjs.mdc`               |
| Vue (2 + 3)            | `vue.mdc`                  |
| Svelte / SvelteKit     | `svelte.mdc`               |
| Mobile (Swift, Kotlin Android, React Native, Flutter) | `mobile.mdc` |
| Data science / Jupyter / ML | `data-science.mdc`    |
| Docker / K8s / Terraform / GH Actions | `yaml-config.mdc` |
| Tests (Jest, Vitest, pytest, RSpec…) | `tests.mdc` |

Don't see your stack? See [Adding your own language rules](#adding-your-own-language-rules) below — it's three lines of YAML.

---

## Installation

The rules themselves are plain text — they work anywhere your editor does. Only
the installers care about your OS:

| | Runs on | Needs |
| --- | --- | --- |
| `install.sh` | macOS, Linux, WSL, Git Bash | `git`, bash |
| `install.ps1` | Windows PowerShell 5.1+, or PowerShell 7 on macOS/Linux | `git` |

Or skip both and copy the files by hand (Option 2). Contributors regenerating
`.claude/rules/` also need Python 3.7+.

### Option 1 — One-liner (recommended)

```bash
# macOS / Linux / WSL
curl -fsSL https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.sh | bash
```

```powershell
# Windows (PowerShell 5+ or 7+)
irm https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.ps1 | iex
```

Defaults install `PROMPT_TEMPLATES.md`, `core.mdc`, and
`agent-efficiency.mdc` for Cursor. Existing files are skipped, so customized
rules and `CLAUDE.md` project notes survive reinstalls.

Selective examples:

```bash
curl -fsSL https://raw.githubusercontent.com/inboxpraveen/Minimize-Cursor-Cost/main/install.sh |
  bash -s -- --tool cursor --rules typescript,react,tests --with-index-ignore

bash install.sh --tool claude --rules python,tests
bash install.sh --tool agents
bash install.sh --tool legacy
bash install.sh --tool all --rules all
```

```powershell
.\install.ps1 -Tool cursor -Rules 'typescript,react,tests' -WithIndexIgnore
.\install.ps1 -Tool claude -Rules 'python,tests'
.\install.ps1 -Tool agents
.\install.ps1 -Tool legacy
.\install.ps1 -Tool all -Rules all
```

| `--tool`   | Installs                                                      |
| ---------- | ------------------------------------------------------------- |
| `cursor`   | `.cursor/rules/*.mdc` (default)                                |
| `claude`   | `CLAUDE.md` + `.claude/rules/*.md` for any rules you name      |
| `agents`   | `AGENTS.md` — read natively by Cursor, Codex, Copilot, Windsurf, Zed, Aider and others |
| `legacy`   | `.cursorrules`                                                 |
| `all`      | All four — only for a repo genuinely shared across all of them |

`--rules` accepts `core`, `all`, or comma-separated rule names, and applies to
both `cursor` and `claude`. Every mode also installs `PROMPT_TEMPLATES.md`.
Both scripts clone to a temporary directory and remove it on exit.

Stick to one adapter. `--tool all` sends the same rules three or four times
over.

### Option 2 — Manual

The repo's top-level `assets/`, `install.*`, `LICENSE`, `README.md`, and
`CONTRIBUTING.md` are *not* meant to be installed — only the contents of
`lean-cursor/` go into your project. The `rm -rf` / `Remove-Item` line at the
end wipes the temp clone, including the `assets/` folder.

**macOS / Linux / WSL:**

```bash
git clone https://github.com/inboxpraveen/Minimize-Cursor-Cost lean-cursor-tmp
cp lean-cursor-tmp/lean-cursor/PROMPT_TEMPLATES.md .
# Cursor:
cp -r lean-cursor-tmp/lean-cursor/.cursor .
# Or Claude Code (CLAUDE.md + the scoped rules your stack uses):
cp lean-cursor-tmp/lean-cursor/CLAUDE.md .
mkdir -p .claude/rules && cp lean-cursor-tmp/lean-cursor/.claude/rules/python.md .claude/rules/
# Or any AGENTS.md-aware agent (Codex, Copilot, Windsurf, Zed, Aider…):
cp lean-cursor-tmp/lean-cursor/AGENTS.md .
# Or a legacy .cursorrules client:
cp lean-cursor-tmp/lean-cursor/.cursorrules .
rm -rf lean-cursor-tmp                             # removes the clone, incl. assets/
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/inboxpraveen/Minimize-Cursor-Cost lean-cursor-tmp
Copy-Item lean-cursor-tmp\lean-cursor\PROMPT_TEMPLATES.md  .
# Cursor:
Copy-Item lean-cursor-tmp\lean-cursor\.cursor . -Recurse
# Or Claude Code (CLAUDE.md + the scoped rules your stack uses):
Copy-Item lean-cursor-tmp\lean-cursor\CLAUDE.md .
New-Item -ItemType Directory .claude\rules -Force | Out-Null
Copy-Item lean-cursor-tmp\lean-cursor\.claude\rules\python.md .claude\rules\
# Or any AGENTS.md-aware agent (Codex, Copilot, Windsurf, Zed, Aider…):
Copy-Item lean-cursor-tmp\lean-cursor\AGENTS.md .
# Or a legacy .cursorrules client:
Copy-Item lean-cursor-tmp\lean-cursor\.cursorrules .
Remove-Item lean-cursor-tmp -Recurse -Force                # removes the clone, incl. assets\
```

Choose one adapter unless the same repository is intentionally used by
multiple clients.

### Option 3 — Pick & choose

Just download the `.mdc` files you want from `lean-cursor/.cursor/rules/`
and drop them into your project's `.cursor/rules/`.

---

## Setup (2 minutes — the highest-ROI step)

Open whichever adapter you installed — `CLAUDE.md` or `AGENTS.md` — and fill in
the **Project-Specific Notes** section at the bottom:

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
- Auth checks via `requireUser()` in `src/auth/guard.ts`
```

This eliminates entire clarification loops. Every "where do I…?" question
the AI doesn't have to ask is 200–600 tokens saved per turn.

---

## How it works

### Three layers

**1. An always-on adapter** — one of `AGENTS.md`, `CLAUDE.md`, or
`.cursor/rules/{core,agent-efficiency}.mdc`. Holds the behavioral rules plus
your project context, and is loaded on every request. Pick one; installing
several puts the same rules in context two or three times.

**2. Scoped rules** — `.cursor/rules/*.mdc` (Cursor, `globs:`) and
`.claude/rules/*.md` (Claude Code, `paths:`). Both are generated from the same
source and load only when a matching file is in context, so a Go service never
carries Vue rules. `.cursorrules` is a legacy adapter with no scoping, installed
separately to avoid duplicate always-on context in Cursor.

**3. `PROMPT_TEMPLATES.md`** — The human side. Copy the relevant template
before each prompt to cut padding and get a tighter answer back. It also holds
the levers only you can pull: model tier, effort, caching, iteration caps.

### Always-active core rules

- Responses start with the answer — no preamble, no sign-off
- Edits are diffs by default, not full-file rewrites
- Max 2 alternatives when options exist, with a stated recommendation
- One clarifying question at a time, not a list
- Scope guard: > 3 files unprompted → AI pauses and asks where to start
- **Agent mode:** never re-read files, batch independent calls, no speculative exploration
- **Build/test/lint:** only on risky changes or on user request — not after every edit

---

## Adding your own language rules

Duplicate any `.mdc` file and adjust the glob. Cursor only reads `.mdc` files
in `.cursor/rules/` — a plain `.md` there is ignored (except `AGENTS.md`):

```markdown
---
description: Elixir file rules
globs: ["**/*.ex", "**/*.exs"]
alwaysApply: false
---

# Elixir Rules
- Show only changed functions
- Match existing pattern-matching style
- Don't introduce new GenServers unless asked
- Don't add @moduledoc unless siblings have them
```

Drop it in `.cursor/rules/`. Done — Cursor picks it up on the next prompt.

For the Claude Code copy, run the generator instead of hand-writing a second
file — it rewrites `globs:` to Claude Code's `paths:` and keeps the rule text
identical:

```bash
python tools/gen-claude-rules.py          # write .claude/rules/*.md
python tools/gen-claude-rules.py --check  # fail if they are stale
```

If you write rules for a stack that's not yet covered, please consider
[contributing them back](CONTRIBUTING.md).

---

## Compatibility

`AGENTS.md` is the file most agents now read. Use `--tool agents` unless your
client has something better.

| Tool                     | Install with   | Notes                                                                 |
| ------------------------ | -------------- | --------------------------------------------------------------------- |
| **Cursor**               | `cursor`       | `.cursor/rules/*.mdc` is the canonical format and the only one with glob scoping. Cursor also reads a root `AGENTS.md`; `.cursorrules` still works as a legacy fallback. |
| **Claude Code**          | `claude`       | `CLAUDE.md` auto-loads; `.claude/rules/*.md` with `paths:` load on matching files. Claude Code does **not** read `AGENTS.md` — bridge it with a `@AGENTS.md` line in `CLAUDE.md`. |
| **OpenAI Codex**         | `agents`       | Native `AGENTS.md`.                                                    |
| **GitHub Copilot**       | `agents`       | The coding agent reads `AGENTS.md`; the IDE extension also reads `.github/copilot-instructions.md`. |
| **Windsurf**             | `agents`       | Native `AGENTS.md`. Workspace rules moved to `.devin/rules/` after the Cognition acquisition; `.windsurf/rules/` and `.windsurfrules` are still read. |
| **Zed / Amp / Jules / Junie / Factory** | `agents` | Native `AGENTS.md`.                                        |
| **Gemini CLI**           | `agents`       | Native `AGENTS.md`.                                                    |
| **Aider**                | `agents`       | Native `AGENTS.md`; or pass any adapter with `--read`.                 |
| **Cline / Roo**          | `agents`       | Safest path is a `.clinerules/` directory — copy `AGENTS.md` in as `.clinerules/lean.md`. Check current Cline docs for `AGENTS.md` support. |
| **Continue.dev**         | `agents`       | Add the file via `customRules` config.                                 |

Client behavior changes often — if a row looks wrong, check that tool's current
docs and please [open a PR](CONTRIBUTING.md).

---

## FAQ

**Q: Will this work on an existing project with custom rules?**
Yes. Installers skip every existing rule and top-level adapter. Customized
`CLAUDE.md` project notes are preserved rather than replaced.

**Q: Will the AI feel "less helpful" after I install this?**
You'll lose: emoji-laden congratulations, "Great question!", multi-paragraph
recaps of what you already know, and the model rewriting your whole file when
you asked it to fix a typo. You'll keep: the actual code and answers.

**Q: Does this work outside Cursor?**
Yes. `AGENTS.md` is read natively by Codex, Copilot, Windsurf, Zed, Aider,
Gemini CLI and ~25 other agents; Claude Code reads `CLAUDE.md` and
`.claude/rules/`. The `.mdc` glob format is Cursor-specific, but the rule
*content* is just markdown — you can paste it into any system prompt.

**Q: `AGENTS.md` or `CLAUDE.md`? Do I need both?**
Pick one. If your repo already has an `AGENTS.md` and you also use Claude Code,
don't duplicate it — add a `CLAUDE.md` containing `@AGENTS.md` plus any
Claude-specific lines. Claude Code expands the import at session start.

**Q: Which model should I use to keep costs down?**
See [Model routing](#model-routing--the-other-half-of-the-bill). Short version:
drop the reasoning/effort setting one notch before dropping to a weaker model,
and don't run top-tier models on typo fixes — the price spread across current
models is about 20×.

**Q: Will rules conflict with my organization's coding standards?**
The rules in this repo are about *AI behavior* (don't ramble, don't rewrite
files), not about *code style* (where braces go). They're orthogonal to your
linter / formatter / style guide.

**Q: How do I measure my own savings?**
Most providers show token usage in their dashboard (Anthropic Console,
OpenAI usage page, Cursor settings). Track a week before installing, a week
after, controlling for the same kinds of tasks.

**Q: One of the rules is wrong for my project. How do I override?**
Either edit the `.mdc` file directly (it's in your repo now), or add a more
specific rule with a narrower glob — Cursor's later/more-specific rules win.

**Q: Does this affect the quality of generated code?**
The rules are designed to preserve quality, but any hard context or verification
limit can cause regressions. The benchmark requires acceptance rate to remain
flat while tokens per accepted change decrease.

---

## Contributing

PRs welcome — especially new language/framework rules. See [CONTRIBUTING.md](CONTRIBUTING.md).

The bar for a new rule file: it should remove a real, recurring source of
token waste in that ecosystem. "Don't add `if __name__ == '__main__'` unless
asked" is good. "Use 4 spaces" is not (that's a linter's job).

---

## License

[Apache 2.0](LICENSE)
