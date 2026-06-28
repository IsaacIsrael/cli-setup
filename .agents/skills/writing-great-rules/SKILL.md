---
name: writing-great-rules
description: Reference for writing Cursor rules and always-on guidance well — scope, binding, and predictable constraints.
disable-model-invocation: true
---

A **rule** is **persistent guidance** — constraints the agent carries without invocation. **Predictability** is the same root virtue as skills; the reach axis is **scope**, not invocation.

**Bold terms** are defined in [`GLOSSARY.md`](GLOSSARY.md). Shared levers — **information hierarchy**, **progressive disclosure**, **co-location**, **leading words**, **pruning** — live in [`writing-great-skills`](../writing-great-skills/SKILL.md).

## Scope

Two choices, trading different costs:

- **Always-on** — `alwaysApply: true` in `.agents/rules/*.mdc`, or a thin block in `AGENTS.md` / `CLAUDE.md` at the repo root. Pays **always-on load** on every turn. Reserve for constraints that genuinely apply everywhere — git safety, commit policy, shared vocabulary.
- **Glob trigger** — `globs: **/*.ts` (etc.). Zero cost when irrelevant files are open; pays **missed guidance** when the agent works outside the pattern. Reserve for file-type conventions — React patterns, API handler shape, test style.

Pick always-on only when the constraint holds regardless of which files are open. If it applies only while editing TypeScript, glob-trigger it.

Mechanics and file layout: [`RULES-FORMAT.md`](RULES-FORMAT.md).

## Rule vs skill

| | Rule | Skill |
|---|------|-------|
| Reach | Scoped into context automatically | You or the agent invoke it |
| Content | Flat **reference** — constraints, conventions | **Steps**, **reference**, or both |
| Skip it? | Never (within scope) | Yes — only when the task needs it |

Persistent constraint → rule. Multi-step procedure you sometimes skip → skill. If both apply, put the constraint in the rule and the workflow in the skill; don't duplicate.

## Rule vs AGENTS.md pointer

Both can be always-on. The split:

- **`AGENTS.md` at repo root** — a **context pointer** index: one line per topic, detail in **external reference** (`.agents/docs/`, `CONTEXT.md`). Best when the body would sprawl and every path only needs the pointer.
- **`.agents/rules/*.mdc`** — the rule body itself, or a short body plus pointer. Best when the constraint is self-contained, file-scoped, or needs glob mechanics. Cursor picks them up via symlinks in `.cursor/rules/`.

This repo's root `AGENTS.md` follows the pointer pattern. Add `.mdc` rules under `.agents/rules/` when guidance is file-specific or doesn't belong in the index.

## Writing rules

Rules are almost always flat **reference** — keep them on the bottom rungs of the **information hierarchy**. Apply the pruning discipline from [`writing-great-skills`](../writing-great-skills/SKILL.md) unchanged.

- **One concern per rule** — split instead of one long `.mdc`. Each always-on rule competes for attention; each glob adds a pattern to maintain.
- **Binding** over vibes — "never commit unless explicitly asked" binds; "write clean code" doesn't. Sharp **binding** resists drift.
- **Push detail down** — rule states the constraint; linked doc holds examples, rationale, edge cases.
- **Single source of truth** — if a constraint lives in a rule, don't restate it in a skill, user rule, and doc. Point at the authoritative place.

## Failure modes

- **Always-on sprawl** — too many `alwaysApply: true` rules, or bodies too long. Every line loads every turn. Cure: demote to **glob trigger**, disclose behind a pointer, or cut **no-ops**.
- **Missed guidance** — glob too narrow (`**/*.tsx` but not `**/*.jsx`) or agent editing files outside the pattern. Cure: widen the glob or promote to always-on if the constraint is truly universal.
- **Duplication across channels** — same constraint in `AGENTS.md`, a `.mdc`, and a skill. Cure: one **single source of truth**; others **context pointer** at it.

For skill-specific failure modes, see [`writing-great-skills`](../writing-great-skills/SKILL.md).
