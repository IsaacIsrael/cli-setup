#!/usr/bin/env bash
# Decide the release version from the git tags (ADR 0010): the tag is the single
# source of truth, so `cog` recomputes the number and this prints it (plain
# semver, no `v`).
#
#   bump-version.sh feature   # cog --auto
#   bump-version.sh hotfix    # cog --patch
set -euo pipefail

mode="${1:?usage: bump-version.sh <feature|hotfix>}"

case "$mode" in
  hotfix)
    version="$(cog bump --patch --dry-run)"
    printf '%s\n' "${version#v}"
    ;;
  feature)
    auto="$(cog bump --auto --dry-run)"
    pending="$auto"

    # Floor to a minor when the bump is patch-only: it shares the latest tag's
    # major.minor, or there is no tag yet and cog produced a 0.0.x number (D1).
    latest="$(git tag -l 'v*' --sort=v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n1 || true)"
    a="${auto#v}"
    l="${latest#v}"
    l="${l:-0.0.0}"
    if [ "${a%.*}" = "${l%.*}" ]; then
      pending="$(cog bump --minor --dry-run)"
    fi
    printf '%s\n' "${pending#v}"
    ;;
esac
