# Prompt Templates — Token-Efficient Patterns
# Copy-paste these instead of writing free-form prompts.
# Each template is designed to produce a precise, scoped response.

---

## 🐛 BUG FIX

```
Bug in `{file_path}` → `{function_name}()`

Error:
{paste exact error message}

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

**What this gets you:** New code only, matching existing patterns. No boilerplate prose.

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

## 💬 QUICK QUESTION

```
In `{file_path}`: {one direct question}?
```

No context fluff. One question = one answer.

---

## 🚀 BEST PRACTICES FOR LOW TOKEN USAGE

| DO | DON'T |
|---|---|
| Paste only the relevant function | Paste the whole file |
| State expected vs actual | Describe the bug vaguely |
| Reference existing pattern | Ask to "make it clean" |
| Ask for diff output | Ask for full file rewrite |
| One task per message | Bundle 5 tasks in one prompt |
| Paste exact error text | Paraphrase the error |
| Specify the file path | Say "in my project" |
| Use templates above | Write free-form essays |

---

## 🔢 ROUGH TOKEN COSTS (GPT-4 / Claude Sonnet scale)

| Content | ~Tokens |
|---|---|
| 1 line of code | 10–20 |
| 1 function (20 lines) | 150–250 |
| 1 file (200 lines) | 1,500–2,500 |
| Full file rewrite response | 1,000–3,000 |
| Diff response (same change) | 100–400 |
| "Refactor everything" | 5,000–20,000 |

**Lesson:** A diff saves 3–10× tokens over a full rewrite. Always ask for diffs.
