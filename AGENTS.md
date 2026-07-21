## Agent workspace

`AGENTS.md` at the repo root is the always-on index. Skills, rules, docs, and activities live under `.agents/`. Layout: `.agents/docs/layout.md`.

### Rules

Binding constraints in `.agents/rules/*.mdc` — git safety, conventional commits, code changes, documentation, GitHub issues, agent workspace.

### Issue tracker

Issues live in GitHub Issues (using the `gh` CLI); external PRs are not a triage surface. See `.agents/docs/issue-tracker.md`.

### Triage labels

Triage roles — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Content labels — `prd` (tags PRD issues), `leftover` (per-milestone tech-debt container). See `.agents/docs/triage-labels.md`.

### Domain docs

Single-context — one `.agents/docs/CONTEXT.md` + `.agents/docs/adr/`. See `.agents/docs/domain.md`. Application source layout: `.agents/docs/app-layout.md`.
