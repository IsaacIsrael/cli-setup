# Contributing to cli-setup

Thanks for your interest in improving `cli-setup`! This document explains how to
set up your environment, the conventions we follow, and the pull-request flow.

All artifacts and user-facing output are written in **English**.

## Toolchain setup

`cli-setup` is a native Bash project for macOS with a single-binary toolchain
(no Node runtime). Bootstrap it in three steps:

1. **Install Homebrew** (skip if you already have it):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install `just`** — the task runner that drives the rest:

   ```bash
   brew install just
   ```

3. **Run the bootstrap recipe** — installs the rest of the `Brewfile` tools and wires the git hooks:

   ```bash
   just setup
   ```

Then run `just` to list the available recipes. Prefer `just setup` over
installing the tools individually — the `Brewfile` is the single source of
truth. The toolchain it installs:

| Concern | Tool |
| --- | --- |
| Lint (code) | ShellCheck |
| Format | shfmt |
| Tests | ShellSpec |
| Git hooks | Lefthook |
| Commits / releases | Cocogitto (`cog`) |
| Task runner | `just` |
| Docs site | mdBook |

If you use Cursor or VS Code, accept the recommended-extensions prompt
(`.vscode/extensions.json`): the ShellCheck extension surfaces the same
diagnostics inline as you type (reusing this repo's `.shellcheckrc`), and the
EditorConfig and shell-format extensions apply this repo's `.editorconfig` so
editor formatting matches `just fmt`.

> **shell-format version:** use **7.2.2**. Version 7.2.8 ships a broken package
> (missing `dist/one_ini_bg.wasm`) that fails to activate, so you get "There is
> no formatter for 'shellscript' files installed"
> ([issue #396](https://github.com/foxundermoon/vs-shell-format/issues/396)). If
> you land on 7.2.8, right-click the extension → "Install Specific Version…" →
> 7.2.2, then turn off "Auto Update".

Compatibility target: **Bash 3.2** (the macOS system Bash). Do not use Bash 4+
features such as associative arrays (`declare -A`).

## Making changes

1. Create a short-lived branch using a Git-Flow-style name (see below) — the names are familiar, but the workflow is trunk-based.
2. Keep changes scoped to one logical unit of work.
3. Run lint, format, and tests locally before opening a PR:
   - `just lint` to run ShellCheck
   - `just fmt` to report formatting drift (or `just fmt --write` to apply)
   - `just test` to run the ShellSpec suite
4. Write tests that assert **observable external behavior**, not implementation
   details.

## Commit messages

We follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>[optional scope]: <description>
```

- Use `feat` for new behavior and `fix` for bug fixes. Other allowed types:
  `build`, `chore`, `ci`, `docs`, `refactor`, `perf`, `style`, `test`.
- Description is lowercase, imperative, no trailing period.
- Add an optional scope in parentheses when it clarifies the area, e.g.
  `feat(cli):`.
- Breaking changes: append `!` before the colon (`feat!:`) and/or add a
  `BREAKING CHANGE:` footer.

Commits are validated with `cog check`.

## Branch names

Development is trunk-based: every branch is short-lived, branches off `main`, and
merges back into `main` (rebase-only). The prefix drives what happens on merge:

| Prefix | Use for | On merge to `main` |
| --- | --- | --- |
| `feature/<slug>` | New features and enhancements | Accumulates into the draft Release |
| `bugfix/<slug>` | Non-urgent bug fixes | Rides the next feature release |
| `hotfix/<slug>` | Urgent fixes | Auto-publishes a patch release |

`release/<slug>` and `support/<slug>` are also accepted by the branch-name lint
(the full Git Flow set) but carry no special merge routing. The `<slug>` is a
kebab-case description — lowercase alphanumerics in hyphen-separated words. Lead
it with the issue number where there is one (e.g. `feature/5-branch-name-lint`);
the lint warns when it is missing but still passes, since not every branch has an
issue. Validate a name any time with `just brlint <name>`.

## Pull request flow

1. Push your branch and open a PR against `main`.
2. Fill in the [pull request template](.github/PULL_REQUEST_TEMPLATE.md).
3. Make sure the CI gates are green — each runs as its own check: commit-lint
   (`cog check`), branch-lint, code-lint (ShellCheck), format-check (shfmt),
   test (ShellSpec), and generate-docs (mdBook). A Lefthook `pre-push` hook runs
   the branch-name lint locally (`just brlint`) so a bad name is caught
   before it leaves your machine; the CI branch-lint gate is the unbypassable
   backstop.
4. **CodeRabbit** reviews every PR as a blocking gate; resolve its findings (and
   any open conversations) before merge. GitHub Copilot comments are advisory.
5. Link the issue your PR addresses (e.g. `Closes #123`).
6. PRs merge with **rebase only** — history stays linear (no squash, no merge
   commits). Keep your commits meaningful and atomic so they survive as-is.

## Releases

Releases are **tag-sourced** — the git tag is the single source of truth; nothing
(`VERSION`, `CHANGELOG`) is committed (see
[ADR 0010](.agents/docs/adr/0010-ci-cd-strategy.md)). A release only creates a tag
and a GitHub Release, never a commit to `main`:

- **Feature release (on demand):** merges to `main` accumulate into a **draft
  GitHub Release**. A maintainer clicks GitHub's native **"Publish release"**
  button to cut it; the version comes from the published tag and is stamped into
  the release asset.
- **Hotfix release (automatic):** merging a `hotfix/*` PR auto-publishes a patch
  release (tag + GitHub Release) scoped to that PR.

The changelog lives in the GitHub Releases — there is no committed `CHANGELOG.md`.

Repository/maintainer setup (branch protection, tag protection, Pages, required
checks) is documented in the
[CI/CD setup runbook](.agents/docs/ci-cd-setup.md).

## Reporting bugs and requesting features

Use the issue templates:

- **Bug report** — something is broken.
- **Feature request** — a new capability or improvement.

By contributing, you agree that your contributions are licensed under the
project's [MIT License](LICENSE).
