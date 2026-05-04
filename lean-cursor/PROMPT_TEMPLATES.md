# Prompt Templates — Token-Efficient Patterns
# Copy-paste these instead of writing free-form prompts.
# Each template is designed to produce a precise, scoped response.

The single biggest win on the prompt side: stop writing essays. Replace
free-form prose with one of the structured templates below. They cut prompt
size by 50–80% and produce tighter outputs because the model knows exactly
what shape of answer is wanted.

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

### 1. Chunk by file, not by feature
A "build login + signup + password reset" prompt is 3 features × N files. Send
them as 3 separate sessions; the model loses focus past file #2 and starts
re-reading.

### 2. Pin context once, refer by path after
On turn 1, paste the relevant function. On every turn after, refer to it as
`{file}:{function}` — the model already has it.

### 3. Cap your own iteration loops
Set a personal rule: max 3 back-and-forths per task. If you're past 3, the
prompt was too vague. Restart with a tighter spec.

### 4. Choose the right model tier
- One-line edits, format-only changes → fast/cheap model.
- Multi-file refactor → mid-tier reasoning model.
- Architecture, novel debugging → top-tier reasoning model.
- Don't burn the top tier on a typo.

### 5. Disable "always show full file" features
Most IDEs have a setting to send the whole open file as context. Turn it off,
or scope to selection. A 1,500-line file pasted on every turn is a 1,500-token
tax per turn.

### 6. Avoid asking "what do you think?"
Open-ended questions invite essays. Ask "yes or no?", "option A or B?", or
"in one sentence, why?".

### 7. Use prompt caching where supported
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
