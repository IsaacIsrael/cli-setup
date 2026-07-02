# cli-setup project recipes. Run `just` (or `just help`) to list them.
# Later toolchain slices fill in `fmt`, `test`, and `docs`.

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
