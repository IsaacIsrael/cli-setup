#!/usr/bin/env bash
# Build the release asset (ADR 0010): a .tar.gz of the installable payload with
# the version stamped into a bundled VERSION file. The archive's top-level
# cli-setup/ mirrors the install root (~/.cli-setup) so the installer just
# extracts it, and the VERSION file feeds src/bin/cli-setup's --version.
#
#   package.sh <version> [outdir]   # outdir defaults to dist/
set -euo pipefail

version="${1:?usage: package.sh <version> [outdir]}"
outdir="${2:-dist}"

root="$(cd "$(dirname "$0")/../.." && pwd)"

# Materialize the version at the payload root (src/VERSION) so it travels with
# the payload — the CLI reads <root>/VERSION at runtime, so this is also what
# `just run --version` shows in a dev checkout. Gitignored: tag-sourced releases
# never commit it (ADR 0010).
printf '%s\n' "$version" >"$root/src/VERSION"

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/cli-setup"

# The installable payload is everything under src/ (bin/ lib/ tools/ profiles/),
# now including the VERSION file stamped above.
cp -R "$root/src/." "$stage/cli-setup/"

# Wipe and recreate the output dir so a rebuild never mixes in stale assets
# from an earlier version (the build is fully regenerated each run).
rm -rf "$outdir"
mkdir -p "$outdir"
tar czf "$outdir/cli-setup-$version.tar.gz" -C "$stage" cli-setup
