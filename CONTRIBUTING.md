# Contributing

Thanks for considering a contribution. This project lives or dies by how
broadly it covers real stacks, so new language/framework rules are the most
valuable PRs.

---

## Quick start

1. Fork and clone.
2. Add or edit a `.mdc` file under `lean-cursor/.cursor/rules/`.
3. Update `README.md` (Supported languages table) and `SETUP_GUIDE.md` (per-stack quickstart) if you added a new file.
4. Open a PR with a one-paragraph description of what waste this rule eliminates.

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

Conventions:
- `alwaysApply: false` for language/framework-specific rules.
- `alwaysApply: true` only for cross-cutting rules (we have two: `core.mdc` and `agent-efficiency.mdc`).
- Keep each rule file < ~150 lines. Beyond that, split it.
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

2. Update `README.md` — add a row to the language table.
3. Update `lean-cursor/SETUP_GUIDE.md` — add a per-stack quickstart line if relevant.
4. Open a PR titled `Add Elixir rules`.

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
