---
name: implement
description: "Implement a piece of work based on a PRD or set of issues."
disable-model-invocation: true
---

Implement the work described by the user in the PRD or issues.

Before writing any code, start on a fresh branch. Name it per [branch-names.mdc](../../rules/branch-names.mdc) (validate with `just brlint`). Development is trunk-based, so branch off the default branch (`main`) per [branch-issue-resolution.md](../../docs/branch-issue-resolution.md). Create the branch off that base before proceeding.

Use /tdd where possible, at pre-agreed seams.

Prefer the repo's `just` recipes over invoking tools directly — run `just` to see what exists (`install`, `lint`, and `fmt` exist today; `test` and `docs` land over later infrastructure slices, so until a recipe exists, call the tool directly). Bootstrap with `just install` if the toolchain is not yet installed. Run static analysis regularly, single test files regularly, and the full test suite once at the end.

When the change alters user-facing behavior or the CLI's observable contract, ship its docs as part of done — follow the `writing-docs` skill and the `documentation` rule. Non-user-facing work (internal infra, refactors, agent tooling) is exempt.

Once done, use /code-review to review the work.

Before committing, make the working tree pass the repo's gates: run `just fmt` (formatting) and `just lint` (ShellCheck). Fix anything they flag **in consultation with the user**, never silently — `just fmt --write` applies shfmt; for lint, propose the ShellCheck fixes and confirm before editing — then re-run both until clean.

Commit your work to the current branch with /commit, which prioritizes **absorbing** each change into the branch-local commit it belongs to and only creates a new commit when no exclusive target fits — always confirming the plan with the user.
