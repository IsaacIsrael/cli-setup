# Contributing to cli-setup

Thanks for your interest in improving `cli-setup`! This document explains how to
set up your environment, the conventions we follow, and the pull-request flow.

All artifacts and user-facing output are written in **English**.

## Toolchain setup

`cli-setup` is a native Bash project for macOS with a single-binary toolchain
(no Node runtime). The recommended way to install the toolchain is Homebrew:

| Concern | Tool | Install |
| --- | --- | --- |
| Lint (code) | ShellCheck | `brew install shellcheck` |
| Format | shfmt | `brew install shfmt` |
| Tests | ShellSpec | `brew install shellspec` |
| Git hooks | Lefthook | `brew install lefthook` |
| Commits / releases | Cocogitto (`cog`) | `brew install cocogitto` |
| Task runner | `just` | `brew install just` |
| Docs site | mdBook | `brew install mdbook` |

> A `Brewfile` and `just` recipes are introduced by the infrastructure
> milestone; once present, `brew bundle` + `just setup` will bootstrap the
> toolchain for you. Until then, install the tools you need individually.

Compatibility target: **Bash 3.2** (the macOS system Bash). Do not use Bash 4+
features such as associative arrays (`declare -A`).

## Making changes

1. Create a branch using a Git Flow name (see below).
2. Keep changes scoped to one logical unit of work.
3. Run lint, format, and tests locally before opening a PR:
   - `shellcheck` on changed scripts
   - `shfmt` to format
   - `shellspec` for the test suite
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

Branches follow Git Flow naming:

| Prefix | Use for |
| --- | --- |
| `feature/<slug>` | New features and enhancements |
| `bugfix/<slug>` | Bug fixes during development |
| `release/<version>` | Release preparation |
| `hotfix/<slug>` | Urgent fixes against a release |

## Pull request flow

1. Push your branch and open a PR against the default branch.
2. Fill in the [pull request template](.github/PULL_REQUEST_TEMPLATE.md).
3. Make sure CI is green: lint, format, tests, and `cog check`.
4. Link the issue your PR addresses (e.g. `Closes #123`).
5. A maintainer (see [CODEOWNERS](CODEOWNERS)) reviews and merges.

## Reporting bugs and requesting features

Use the issue templates:

- **Bug report** — something is broken.
- **Feature request** — a new capability or improvement.

By contributing, you agree that your contributions are licensed under the
project's [MIT License](LICENSE).
