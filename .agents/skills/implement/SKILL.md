---
name: implement
description: "Implement a piece of work based on a PRD or set of issues."
disable-model-invocation: true
---

Implement the work described by the user in the PRD or issues.

Before writing any code, start on a fresh branch. Choose a name per the branch table in [CONTRIBUTING.md](../../../CONTRIBUTING.md) — the prefix reflects the work type (`feature/`, `bugfix/`, `hotfix/`) and the slug embeds the issue number where there is one (e.g. `feature/42-doctor-command`). Development is trunk-based, so branch off the default branch (`main`) per [branch-issue-resolution.md](../../docs/branch-issue-resolution.md). Create the branch off that base before proceeding.

Use /tdd where possible, at pre-agreed seams.

Run static analysis (`shellcheck`) regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.
