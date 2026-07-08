# cli-setup project recipes. Run `just` (or `just help`) to list them.

# Expose recipe arguments as $1, $2, ... so recipe bodies can stay plain shell
# (no `{{param}}` interpolation, which trips ShellCheck when editors lint recipes).
set positional-arguments

# List the available recipes (runs when `just` is invoked with no arguments).
default:
    @just --list

# Alias for the default listing.
help:
    @just --list

# Bootstrap the dev toolchain: install the Brewfile tools and wire the git hooks.
setup:
    brew bundle
    lefthook install

# Run the CLI from source (dev entrypoint), e.g. `just run --help` or `just run doctor mobile`.
run *args:
    @src/bin/cli-setup "$@"

# Build all release artifacts (ADR 0010) — no GitHub side effects, so it is safe
# to run locally. Resolves the version (feature: cog --auto floored to a minor;
# hotfix: cog --patch), then writes src/VERSION and src/CHANGELOG.md (the Release
# body) at the payload root and packages dist/cli-setup-<version>.tar.gz. The
# release workflow calls this and then only does the `gh release` writes.
# `just build feature` or `just build hotfix <pr>`; exits non-zero on the feature
# mode when nothing is releasable (the caller then leaves the draft untouched).
build mode pr="":
    @maintenance/build.sh "$@"

# Lint shell files with ShellCheck (config in .shellcheckrc). maintenance/lint.sh finds
# the repo's shell files (ShellCheck can't discover them itself) and runs shellcheck.
# `just lint` checks the whole project; `just lint stage` checks the staged files.
lint mode="all":
    @maintenance/lint.sh "$1"

# Validate a branch name against the Git Flow convention (see CONTRIBUTING.md).
# Pure shell, no Node. Runs via the Lefthook pre-push hook locally and as the
# branch-lint CI gate (which checks the PR head via $GITHUB_HEAD_REF). With no
# argument it checks the current branch; pass a name to check one directly, e.g.
# `just brlint feature/my-work`.
brlint *args:
    @maintenance/brlint.sh "$@"

# Run the ShellSpec test suite (options in .shellspec, harness in spec/spec_helper.sh).
# `just test` runs every spec; pass a path to run one, e.g. `just test spec/src/bin/cli-setup_spec.sh`.
test *args:
    @shellspec "$@"

# Build the mdBook documentation site (config in docs/book.toml). Output lands in
# docs/book (gitignored). `just docs` builds the same book the CI docs gate and
# the GitHub Pages deploy build. Pass extra args through to mdbook, e.g.
# `just docs serve` to preview locally with live reload.
docs *args:
    @if [ "${1:-}" = "" ]; then mdbook build docs; else mdbook "$@" docs; fi

# Report shell files that need formatting with shfmt (settings in .editorconfig).
# Unlike ShellCheck, shfmt discovers the repo's shell files itself, so no helper
# script is needed. `just fmt` only reports (prints a diff, non-zero on drift; used
# by CI and the pre-commit hook); `just fmt --write` applies the changes. Optional
# path args scope it (the pre-commit hook passes the staged shell files).
fmt *args:
    @if [ "${1:-}" = "--write" ]; then shift; shfmt -w "${@:-.}"; else shfmt -d "${@:-.}"; fi
