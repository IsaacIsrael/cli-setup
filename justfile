# cli-setup project recipes. Run `just` (or `just help`) to list them.
# A later toolchain slice fills in `docs`.

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
# `just test` runs every spec; pass a path to run one, e.g. `just test spec/smoke_spec.sh`.
test *args:
    @shellspec "$@"

# Report shell files that need formatting with shfmt (settings in .editorconfig).
# Unlike ShellCheck, shfmt discovers the repo's shell files itself, so no helper
# script is needed. `just fmt` only reports (prints a diff, non-zero on drift; used
# by CI and the pre-commit hook); `just fmt --write` applies the changes. Optional
# path args scope it (the pre-commit hook passes the staged shell files).
fmt *args:
    @if [ "${1:-}" = "--write" ]; then shift; shfmt -w "${@:-.}"; else shfmt -d "${@:-.}"; fi
