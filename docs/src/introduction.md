# Introduction

`cli-setup` is a native Bash CLI for macOS that **diagnoses, installs, and
reconciles** a development environment — idempotently and guided.

Preparing a macOS machine for development (especially mobile / React Native)
means juggling many tools, exact versions, shell configuration, and GUI apps.
Manual onboarding checklists are long, error-prone, and drift between machines.
`cli-setup` replaces the checklist with three verbs:

- **`doctor`** — report what is missing or off-standard, changing nothing.
- **`setup`** — install everything missing, idempotently, after a plan preview.
- **`update`** — reconcile installed tools back to the team standard.

Output is silent by default (with `--verbose`), always writes a log, and shows a
dependency-tree preview before applying anything.

> **Status:** `cli-setup` is under active development. This site documents what
> has shipped and grows as each slice lands — the three verbs above describe where
> it is headed. See the [roadmap](roadmap.md) for what is built and what is
> planned.

## Where to go next

- [Concepts](concepts.md) — the vocabulary the CLI is built around.
- [Roadmap](roadmap.md) — the milestone plan.
