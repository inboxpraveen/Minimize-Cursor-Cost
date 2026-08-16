# CLAUDE.md — Lean Project Rules

Optimize cost per accepted change, not response length. Preserve correctness
while avoiding duplicated context, speculative work, and unnecessary prose.

## Response and Scope

- Start with the answer or edit. No preamble, affirmation, recap, or sign-off.
- Show patches with 3–5 context lines. Show a full file only when new, under
  40 lines, or explicitly requested.
- Ask one blocking question only when a fact cannot be inferred or checked.
- Do not expand beyond the user's scope. Execute explicitly large work in
  bounded phases.
- Present at most two alternatives and recommend one.

## Silent Reuse-First Gate

Before tools or edits, check whether the supplied context is sufficient and
whether an existing helper, type, pattern, dependency, fixture, or file can be
reused. Prefer the smallest safe edit and cheapest acceptance check. Do not
narrate this checklist or ask the user to make decisions that code can answer.

## Evidence and Tools

- Start from the named file, symbol, or exact error.
- Search exact strings before semantic exploration; read matching ranges, not
  whole large files.
- Reuse session context; batch independent tools; do not re-read by habit.
- Limit search and command output to relevant failures and stack frames.
- Exclude generated, vendored, minified, lock, build, and cache files.
- Stop widening when repeated searches produce no new evidence.

## Code and Verification

- Match nearby language, naming, formatting, error handling, types, and
  abstractions.
- Do not add dependencies, files, tests, logging, comments, or refactors beyond
  the task or surrounding baseline.
- Text/comment/format-only edits need no check unless requested.
- Normal code gets the cheapest targeted check when available.
- Bug fixes, public APIs, auth, migrations, and config require the smallest
  relevant test, lint, parse, or validation check.
- Stop when the acceptance check passes and no unrelated code changed. Report a
  repeated failure without new evidence instead of looping.

## Cache and Model Use

Keep this file stable and task-specific context late. Use a fast model for
deterministic bounded work and stronger reasoning for ambiguous architecture or
novel debugging; a cheap model that causes retries is not cheaper.

---

## PROJECT-SPECIFIC NOTES

> ⬇️ Fill in the section below for your project. These are loaded every session
> and produce the highest ROI of any single change you can make.

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
- (e.g., "auth checks via `requireUser()` in `src/auth/guard.ts`")
