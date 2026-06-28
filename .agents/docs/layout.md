# Agent workspace layout

Agent configuration lives at the repo root (`AGENTS.md`) and under `.agents/`. Do not scatter other agent files at the repo root.

```
/
├── AGENTS.md          # always-on index (repo root — canonical)
└── .agents/
    ├── docs/          # shared reference — issue tracker, triage labels, layout; domain docs (CONTEXT.md, adr/)
    ├── rules/         # persistent constraints (.mdc; source of truth)
    ├── skills/        # invocable skills (SKILL.md per skill)
    └── activities/    # hand-authored agent run artifacts
```

## Symlinks for Cursor

Cursor discovers rules under `.cursor/rules/`. Those files are symlinks — edit the target under `.agents/rules/`, not the link. They are gitignored; after clone run `/setup` to create them.

| Link | Target |
|------|--------|
| `.cursor/rules/*.mdc` | `.agents/rules/*.mdc` |

`AGENTS.md` stays at the repo root; it is not symlinked.

## What stays outside `.agents/`

| Path | Why |
|------|-----|
| `AGENTS.md` | Always-on index — Cursor convention, lives at repo root |
| `src/` | Application source code |
| `.cursor/retrospectives/` | Cursor runtime diagnostics — written by the IDE, not hand-edited |
| `.scratch/` | Ephemeral runtime artifacts (e.g. the `teach` workspace) — gitignored, never committed (ADR 0007) |

When Cursor writes diagnostics outside `.agents/`, that is expected. Hand-authored agent guidance belongs in `AGENTS.md` or under `.agents/`.
