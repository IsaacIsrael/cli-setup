#!/usr/bin/env bash
# Build every release artifact (ADR 0010) with no GitHub side effects, so it runs
# and is verifiable locally. Composes the maintenance/lib blocks: resolve the
# version, write src/CHANGELOG.md (the Release body), then package the asset —
# which also materializes src/VERSION. Both land at the payload root (src/) so
# they travel inside the asset, and src/VERSION is what the workflow reads back.
# _release.yml calls this and then does only the `gh release` writes.
#
#   build.sh feature       # cog --auto floored to a minor; exits non-zero when
#                          #   nothing is releasable (caller leaves the draft as-is)
#   build.sh hotfix <pr>   # cog --patch; notes scoped to the PR
set -euo pipefail

mode="${1:?usage: build.sh <feature|hotfix> [pr-number]}"
pr="${2:-}"

lib="$(cd "$(dirname "$0")/lib" && pwd)"

version="$("$lib/bump-version.sh" "$mode")"
# release-notes.sh writes src/CHANGELOG.md and package.sh writes src/VERSION —
# both at the payload root, so package.sh archives them into the asset.
"$lib/release-notes.sh" "$mode" "$pr"
"$lib/package.sh" "$version"
