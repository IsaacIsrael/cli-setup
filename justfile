# cli-setup project recipes. Run `just` (or `just help`) to list them.
# Later toolchain slices fill in `lint`, `fmt`, `test`, and `docs`.

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
