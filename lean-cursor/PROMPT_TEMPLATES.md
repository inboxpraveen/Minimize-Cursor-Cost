# Prompt Templates — Token-Efficient Patterns
# Copy-paste these instead of writing free-form prompts.
# Each template is designed to produce a precise, scoped response.

The single biggest win on the prompt side: stop writing essays. Replace
free-form prose with one of the structured templates below. They cut prompt
size by 50–80% and produce tighter outputs because the model knows exactly
what shape of answer is wanted.

---

## DEFAULT TASK CONTRACT

Use this when no specialized template fits:

```
Goal: {one sentence}
Scope: {file, symbol, or bounded area}
Evidence: {exact error, relevant code, or existing pattern}
Expected: {observable behavior}
Check: {smallest acceptance test}
Non-goals: {what must not change}
Stop when: the check passes and no unrelated code changed
```

Omit fields that add no information. Do not ask the agent to repeat this
contract or narrate its plan.

---

## 🐛 BUG FIX

```
Bug in `{file_path}` → `{function_name}()`

Error:
{paste exact error message verbatim}

Expected: {one line}
Actual: {one line}

Relevant code:
{paste the function or 10–20 lines max}
```

**What this gets you:** Root cause in 1 sentence + minimal fix. No tutorial.

---

## ✨ ADD FEATURE

```
Add `{feature name}` to `{file_path}`.

Requirements:
- {bullet 1}
- {bullet 2}

Existing pattern to follow: `{existing_function_name}` in same file.
Do not touch anything outside this file.
```

**What this gets you:** New code only, matching existing patterns. No prose.

---

## ♻️ REFACTOR

```
Refactor `{function/class}` in `{file_path}`.

Goal: {one line — e.g., "extract DB logic from controller"}
Do not change behavior or rename public interfaces.
Show diff only.
```

---

## 🧪 WRITE TESTS

```
Write tests for `{function_name}` in `{file_path}`.

Cases to cover:
- {case 1}
- {case 2}
- {edge case}

Test file: `{test_file_path}` — match existing style.
```

---

## 🏗️ NEW FILE / MODULE

```
Create `{file_path}`.

Purpose: {one sentence}
Exports: {list function/class names}
Inputs/outputs: {brief schema or type}
Dependencies allowed: {list or "existing project deps only"}
```

---

## 🔍 EXPLAIN CODE

```
Explain `{function_name}` in `{file_path}`.
Level: {junior | senior | one-liner}
```

Use "one-liner" to get a single sentence. Use "senior" to skip basics.

---

## 🏛️ ARCHITECTURE / DESIGN

```
Design: {feature name}

Constraints:
- Stack: {language/framework}
- Must integrate with: {existing system}
- Must NOT: {constraint}

Format: bullet list or table. No essays.
Recommend one approach.
```

---

## 🔄 REVIEW CODE

```
Review `{file_path or paste code}`.

Focus only on: {bugs | performance | security | style}
Skip: {anything not in focus}
Format: inline comments or numbered list. No summaries.
```

---

## 📦 DEPENDENCY / UPGRADE

```
I need to {add | upgrade | replace} `{package}`.

Reason: {one line}
Show only: changed config files + any breaking call-sites.
```

---

## 🔁 MIGRATION (DB / framework version)

```
Migrate `{file or table}` from `{from}` to `{to}`.

Constraints:
- Backwards-compatible: {yes/no}
- Reversible: {yes/no}

Show: only the migration file + any updated call-sites.
```

---

## 🐞 STACK TRACE TRIAGE

```
Stack trace (last frame in my code first):
{paste trace — at most 30 lines}

What I tried:
- {one line}

Question: root cause + fix in `{file_path}`.
```

Pasting only the bottom-of-stack frames in your own code, not the full trace,
saves hundreds of tokens with no information loss.

---

## 🧹 CLEANUP / REMOVE

```
Remove `{thing}` from `{file_path}`.

Also remove: dead imports, unused helpers it depended on (only if no other caller).
Do NOT: rename anything, reformat, or add new abstractions.
```

---

## 🔌 INTEGRATE EXTERNAL API

```
Integrate `{API name}` in `{file_path}`.

Endpoints to call: {list}
Auth: {bearer | api key | oauth}
Error handling: match existing pattern in `{nearby_file}`.
Don't add a new HTTP client — use the existing `{http_client_var}`.
```

---

## 💬 QUICK QUESTION

```
In `{file_path}`: {one direct question}?
```

No context fluff. One question = one answer.

---

## 🚀 BEST PRACTICES FOR LOW TOKEN USAGE

| DO                                | DON'T                              |
|-----------------------------------|------------------------------------|
| Paste only the relevant function  | Paste the whole file               |
| State expected vs actual          | Describe the bug vaguely           |
| Reference existing pattern        | Ask to "make it clean"             |
| Ask for diff output               | Ask for full file rewrite          |
| One task per message              | Bundle 5 tasks in one prompt       |
| Paste exact error text            | Paraphrase the error               |
| Specify the file path             | Say "in my project"                |
| Use templates above               | Write free-form essays             |
| Mention the existing function to mirror | Let the model invent a pattern |

---

## 🧠 ADVANCED COST LEVERS

These compound on top of the templates above and unlock the path from ~50% to
~60–70% total reduction.

### 1. Keep one bounded task per chat
Keep related multi-file work together, but start a new chat when the goal
changes. Give the exact starting file, symbol, diff, or error; attach folders
or codebase-wide context only when the task genuinely spans them.

### 2. Reuse context already in the chat
Paste a relevant function or error once, then refer to `{file}:{symbol}`.
Do not resend terminal history, generated output, or unchanged files.

### 3. Cap your own iteration loops
Set a personal rule: max 3 back-and-forths per task. If you're past 3, the
prompt was too vague. Restart with a tighter spec.

### 4. Choose the right model tier
- One-line edits, format-only changes → fast/cheap model.
- Multi-file refactor → mid-tier reasoning model.
- Architecture, novel debugging → top-tier reasoning model.
- Don't burn the top tier on a typo.

### 5. Choose the cheapest capable mode
- Read-only answer or explanation → Ask.
- Bounded implementation with known scope → Agent.
- Ambiguous or multi-system design → Plan, then Agent.
- Reproducible difficult failure → Debug.

Do not use Agent when no tools or edits are needed. For large work, resolve
ambiguity once with a strong model, then execute bounded steps cheaply.

### 6. Control automatic context
Most IDEs have a setting to send the whole open file as context. Turn it off,
or scope to selection. Inspect Cursor's context indicator and disable unused
MCP servers. Prefer `.cursorindexingignore` for generated/index noise;
`.cursorignore` is not a security boundary for terminal or MCP access.

### 7. Avoid asking "what do you think?"
Open-ended questions invite essays. Ask "yes or no?", "option A or B?", or
"in one sentence, why?".

### 8. Use prompt caching where supported
Tools like Claude / Cursor cache stable prefixes. Keep `CLAUDE.md` + rules
stable; put the volatile task at the end of the message. Re-edit your rule
files only when actually improving them.

---

## 🔢 ROUGH TOKEN COSTS (GPT-4 / Claude / Gemini scale)

| Content                            | ~Tokens   |
|------------------------------------|-----------|
| 1 line of code                     | 10–20     |
| 1 function (20 lines)              | 150–250   |
| 1 file (200 lines)                 | 1,500–2,500 |
| Full file rewrite response         | 1,000–3,000 |
| Diff response (same change)        | 100–400   |
| `read_file` of 1k-line file (agent)| 5,000–8,000 |
| Full repo grep response            | 2,000–10,000+ |
| "Refactor everything"              | 5,000–20,000 |

**Lesson 1:** A diff saves 3–10× tokens over a full rewrite.
**Lesson 2:** A targeted read saves 5–20× tokens over a "read the whole file".
**Lesson 3:** Asking for "the whole project" is the most expensive prompt you can write.
