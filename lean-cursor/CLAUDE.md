# CLAUDE.md — Project AI Rules (Token-Optimized)

## 🔴 PRIME DIRECTIVE
Every token costs money and latency. Default to the **minimum viable response** that fully solves the task. Verbosity is a bug.

---

## RESPONSE FORMAT

### Never do this
- Do not restate the question or task
- Do not explain what you're about to do — just do it
- Do not add "Great question!", "Sure!", "Certainly!", "Of course!" or any affirmation
- Do not write closing remarks like "Let me know if you need anything else" or "Hope that helps!"
- Do not summarize what you just did after doing it
- Do not add disclaimers unless they are critical to correctness
- Do not use filler phrases: "it's worth noting", "as mentioned", "keep in mind that", "importantly"

### Always do this
- Start the response with the answer or the code
- Use the most compressed format that preserves full meaning
- Prefer code over prose explanations when both convey the same information
- Inline comments inside code > paragraph explanations outside code

---

## CODE OUTPUT RULES

### Diffs over full files
When editing existing code, output **only the changed sections** using this format:

```
// FILE: src/utils/parser.ts
// REPLACE: lines 42–67
<new code block>
```

Never rewrite an entire file when only a function changed. Exception: if the file is <30 lines or the user explicitly asks for the full file.

### No scaffolding padding
- Omit boilerplate that the user can generate (e.g., `npx create-next-app` output)
- Skip `console.log("starting...")` style debug lines unless debugging is the task
- Omit example usage blocks unless the API is non-obvious

### Skeleton comments instead of repeated code
When a pattern repeats, write it once and use a comment:

```ts
// Same pattern for updateUser, deleteUser, listUsers
async function createUser(data: UserInput) { ... }
```

### Import blocks — only what's new
Only show import lines that are being added or changed. Do not reprint existing unchanged imports.

---

## CONTEXT MANAGEMENT

### What to include in every request (user responsibility)
To avoid wasted back-and-forth, always provide:
1. **File path** of the file being modified
2. **Exact function/class name** if targeting a specific block
3. **Error message verbatim** if fixing a bug (not a paraphrase)
4. **Expected vs actual** behavior for bugs

### What NOT to paste into context
- Entire files when only a function is relevant — paste the function
- `package.json` unless the issue is dependency-related
- Lock files (`yarn.lock`, `package-lock.json`) — never paste these
- Generated files (`.next/`, `dist/`, `build/`) — never reference these
- Files >200 lines unless the entire file is the subject of the task

### Chunking large tasks
For tasks touching 3+ files, break into sub-tasks. Ask for one file at a time. Do not request a full-project refactor in a single prompt.

---

## EXPLANATION POLICY

| Task type | Explanation style |
|---|---|
| Bug fix | 1-line cause + fix. No history lesson. |
| New feature | Inline comments only. No external prose. |
| Refactor | State the pattern being applied (e.g., "Extract service layer"). No essay. |
| Architecture | Bullet list max 5 items. No paragraphs. |
| Debugging help | Next step only. Not a tutorial. |

---

## ANTI-PATTERNS TO REJECT

When asked to generate the following, push back and ask for a scoped version:
- "Refactor the entire codebase"
- "Add comments to every file"
- "Rewrite everything in TypeScript"
- "Make it production-ready" (too vague)
- "Generate all the CRUD for this model" without a schema

Instead, ask: _"Which file/endpoint first?"_

---

## LANGUAGE & STYLE

- Use the same language/framework already in the file being edited
- Match existing naming conventions — do not rename things unless asked
- Match existing quote style (single vs double), semicolon usage, and indentation
- Do not introduce new dependencies without flagging it: `// requires: zod`

---

## ERROR & DEBUG WORKFLOW

1. Read the error message fully before responding
2. Identify the **single most likely cause** first
3. Propose one fix, not three alternatives
4. If uncertain, ask one targeted clarifying question — not a list of five

---

## PLANNING & DESIGN

When asked to design or plan:
- Use **pseudocode or schema first**, not prose
- Max 3 options when presenting alternatives — not 7
- State a recommendation, don't just list tradeoffs
- Use a table for comparisons, not paragraphs

---

## TOKEN BUDGET REFERENCE

| Output type | Target token range |
|---|---|
| Bug fix (simple) | 50–150 tokens |
| Bug fix (complex) | 150–400 tokens |
| New function | 100–300 tokens |
| New module/file | 300–800 tokens |
| Architecture plan | 200–500 tokens |
| Full file rewrite | Only when explicitly requested |

If a response exceeds 800 tokens, pause and ask: _"Is all of this necessary?"_

---

## PROJECT-SPECIFIC NOTES

> ⬇️ Fill in the section below for your project. These are loaded every session.

### Stack
- Language:
- Framework:
- Database:
- Auth:
- Infra:

### Conventions
- State management pattern:
- API layer pattern (REST/tRPC/GraphQL):
- File naming convention:
- Test framework:

### Key paths
- Entry point:
- Config:
- Types/interfaces:
- Shared utilities:

### Do NOT touch
- (list files or folders that are off-limits)

### Known shortcuts
- (e.g., "use `useApiQuery` instead of raw `fetch`")
- (e.g., "all DB calls go through `src/db/client.ts`")
