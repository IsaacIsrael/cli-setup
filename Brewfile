# Dev toolchain for cli-setup — the single source of truth for the tools the
# project builds with, both locally (`brew bundle`) and in CI (the composite
# `.github/actions/setup`). This is the development toolchain, not the tools the
# CLI installs on a user's machine.

brew "just"        # task runner — `just` exposes the project recipes
brew "cocogitto"   # `cog` — Conventional Commits lint + tag-sourced releases
brew "lefthook"    # git hooks manager (commit-msg → cog verify)
brew "shellcheck"  # shell static analysis
brew "shfmt"       # shell formatter
brew "shellspec"   # BDD test framework for shell
brew "mdbook"      # documentation site generator
