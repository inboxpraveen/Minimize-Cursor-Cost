# Contributing

Thanks for considering a contribution. This project lives or dies by how
broadly it covers real stacks, so new language/framework rules are the most
valuable PRs.

---

## Quick start

1. Fork and clone.
2. Add or edit a `.mdc` file under `lean-cursor/.cursor/rules/`.
3. Run `python tools/gen-claude-rules.py` to refresh the Claude Code copies in
   `lean-cursor/.claude/rules/`, and commit them. Never hand-edit those files —
   the `.mdc` is the single source of truth.
4. Update `README.md` (Supported languages table) and `SETUP_GUIDE.md` (per-stack quickstart) if you added a new file.
5. If the change affects always-on behavior, mirror it in `lean-cursor/CLAUDE.md`,
   `lean-cursor/AGENTS.md`, and `lean-cursor/.cursorrules` — these are condensed
   adapters of the same rules and drift between them is a bug.
6. Open a PR with a one-paragraph description of what waste this rule eliminates.

Check your work with `python tools/gen-claude-rules.py --check`, which fails if
any generated rule is stale or orphaned. It needs Python 3.7+ and nothing else.

---

## What makes a good rule

The bar is simple: **the rule must remove a real, recurring source of token
waste.** It is not a code style guide.

### Good rule examples
- "Don't add `if __name__ == '__main__'` unless asked." — prevents a recurring 5-line addition.
- "Don't switch a function component to a class component (or vice versa)." — prevents whole-file rewrites.
- "Don't reprint generated files (`.g.dart`, build outputs)." — prevents 1k+ token dumps.
- "Match existing test framework: JUnit 4 / JUnit 5 / Kotest. Don't switch." — prevents migration sprawl.

### Bad rule examples (please don't)
- "Use 4 spaces." — that's a linter/formatter's job.
- "Write good code." — too vague to act on.
- "Always use TypeScript." — opinion, not waste-prevention.
- "Add JSDoc to every function." — inflates output.

### Rule-writing checklist
Each rule should be:

- [ ] Actionable: the model can follow it without judgment calls.
- [ ] Token-saving: it either trims output, prevents drift, or shortens iteration.
- [ ] Stack-specific: belongs in the most-specific scope (e.g., `nextjs.mdc`, not `core.mdc`).
- [ ] Stable: doesn't bake in a fad that'll be obsolete in 6 months.
- [ ] Aligned with the existing tone (terse, imperative, no preamble).

---

## File format

```markdown
---
description: Rules applied when working in <language/framework> files
globs: ["**/*.<ext>", "**/*.<ext2>"]
alwaysApply: false
---

# <Name> Rules

## <Section>
- Bullet rule
- Bullet rule

## Never
- Don't do X
- Don't do Y
```

The generator emits the Claude Code equivalent, rewriting `globs:` to `paths:`:

```markdown
---
paths:
  - "**/*.<ext>"
---

# <Name> Rules
...
```

Conventions:
- `alwaysApply: false` for language/framework-specific rules. Only these are
  generated into `.claude/rules/`; always-on content lives in `CLAUDE.md`, and
  shipping it twice would put duplicate rules in every session.
- `alwaysApply: true` only for cross-cutting rules (we have two: `core.mdc` and `agent-efficiency.mdc`).
- Globs must actually match the files the rule claims to cover. A rule that
  never fires is worse than no rule — it looks like coverage and isn't.
- Keep each rule file < ~150 lines. Beyond that, split it. (Cursor's own
  guidance is < 500; ours is tighter because every matched rule is context.)
- The two always-on files are the ones loaded on every request. Treat any
  addition there as expensive, and check it isn't already stated in the other.
- Use `## Never` as the last section for hard prohibitions — it's the most-quoted section across the project.
- Match the existing voice: imperative, no "please", no exclamation marks.

---

## Adding a new language

Example: adding Elixir.

1. Create `lean-cursor/.cursor/rules/elixir.mdc`:

```markdown
---
description: Rules applied when working in Elixir files
globs: ["**/*.ex", "**/*.exs"]
alwaysApply: false
---

# Elixir Rules

## Style
- Match existing formatter (mix format).
- Don't reformat unrelated lines.

## Output
- Single-function change → show only that function.
- Module change → show only the changed function(s). Use `# ... rest of module unchanged`.

## Pattern matching
- Match existing style for guards (`when` clauses) and multi-clause functions.
- Don't introduce `with` chains where simple pattern matching works.

## Never
- Don't introduce GenServers / Supervisors unless asked.
- Don't add @moduledoc / @doc unless siblings have them.
- Don't switch from `Task.async` to `Stream` (or vice versa) as a side-effect.
```

2. Run `python tools/gen-claude-rules.py` and commit `lean-cursor/.claude/rules/elixir.md`.
3. Update `README.md` — add a row to the language table.
4. Update `lean-cursor/SETUP_GUIDE.md` — add a per-stack quickstart line if relevant.
5. Open a PR titled `Add Elixir rules`.

---

## Adding a new framework

Same as a language, but think about whether to write a separate file or extend
an existing one. As a guideline:

- New file when: the framework has its own file extensions, distinct paradigms, or both.
- Extend existing when: it's an add-on (e.g., extending `react.mdc` for a UI library is usually overkill — write a project-local rule instead).

---

## Improving an existing rule

- Be specific in the PR description: which prompt or scenario produced waste, and how the new rule prevents it.
- One change per PR — don't bundle unrelated rule edits.
- If you remove a rule, explain what was over-restrictive about it.

---

## Tests

Rule behavior is probabilistic, so validate cost and quality together:

1. Choose the matching task in [`benchmarks/scenarios.json`](benchmarks/scenarios.json).
2. Freeze the repository commit, prompt, model, settings, and acceptance check.
3. Run `current` and proposed `adaptive` profiles at least three times each.
4. Keep failed runs and summarize them with:

```bash
python benchmarks/summarize.py benchmarks/results.jsonl
```

Core/agent changes and published savings claims must cover all five scenarios.
Scoped language rules may run only their relevant scenario, but must show that
acceptance quality did not fall. Attach the result data or report to the PR.

---

## Code of conduct

Be kind. Critique rules, not people. If you disagree with a rule, propose a
specific replacement instead of asking for it to be removed.

---

## License

By contributing, you agree your contribution is licensed under [Apache 2.0](LICENSE).
