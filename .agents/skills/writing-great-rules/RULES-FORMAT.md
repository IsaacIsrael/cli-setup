# Rules Format

Mechanical reference for Cursor rules and this repo's always-on pointer pattern. Principles live in [`SKILL.md`](SKILL.md); definitions in [`GLOSSARY.md`](GLOSSARY.md).

## `.agents/rules/*.mdc`

Source of truth for rule bodies. One file per concern, ideally under ~50 lines:

```markdown
---
description: Brief description (shown in rule picker)
globs: **/*.ts        # omit when alwaysApply is true
alwaysApply: false    # true = always-on scope
---

# Rule Title

Constraint body — flat reference.
```

| Field | When to use |
|-------|-------------|
| `alwaysApply: true` | Constraint applies regardless of open files |
| `globs` | Constraint applies only while matching files are in context |
| `description` | Human-readable label in Cursor's rule picker |

Prefer globs over always-on when the constraint is file-type-specific.

Cursor discovers rules via `.cursor/rules/*.mdc` — symlinks pointing at `.agents/rules/`. Edit under `.agents/rules/`; do not duplicate bodies in `.cursor/`.

## `AGENTS.md` at repo root

Always-on index — no globs, loaded every session. Lives at the project root (not under `.agents/`):

```markdown
### Topic name

One-line constraint or summary. See `.agents/docs/topic.md`.
```

Use thin pointer blocks; push detail into `.agents/docs/` or `.agents/rules/`.

## This repo's layout

```
/
├── AGENTS.md              → always-on index (repo root)
└── .agents/
    ├── docs/              → disclosed reference bodies
    ├── rules/             → persistent constraints (.mdc)
    ├── skills/            → invocable skills
    └── activities/        → hand-authored agent run artifacts
```

`.cursor/rules/` holds symlinks to `.agents/rules/` for Cursor discovery. See `.agents/docs/layout.md`.

## Choosing a home

| Material | Home |
|----------|------|
| Universal constraint, self-contained (~≤50 lines) | `.agents/rules/*.mdc` |
| Universal constraint, long body or many examples | Thin `AGENTS.md` pointer → `.agents/docs/` |
| File-type or directory convention | `.agents/rules/*.mdc` with `globs` |
| Multi-step procedure invoked on demand | Skill — see [`writing-great-skills`](../writing-great-skills/SKILL.md) |
| Shared reference any skill or rule can point at | **External reference** (plain `.md` under `.agents/docs/`) |

## Checklist

- [ ] One concern per rule
- [ ] Scope chosen deliberately (always-on vs glob)
- [ ] Body is **binding**, not vague
- [ ] Detail disclosed behind a pointer if over ~50 lines
- [ ] No **duplication** with `AGENTS.md`, skills, or user rules — pointer at **single source of truth**
