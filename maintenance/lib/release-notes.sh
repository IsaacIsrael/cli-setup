#!/usr/bin/env bash
# Write the release-notes document to the payload root (src/CHANGELOG.md) so
# package.sh archives it into the asset and _release.yml passes it to
# `gh release --notes-file` (ADR 0010). The tag is the single source of truth, so
# notes are recomputed by `cog`; gitignored, never committed.
#
#   release-notes.sh feature      # notes since the latest feature tag (vX.Y.0)
#   release-notes.sh hotfix <pr>  # notes scoped to the merged PR
set -euo pipefail

mode="${1:?usage: release-notes.sh <feature|hotfix> [pr-number]}"

root="$(cd "$(dirname "$0")/../.." && pwd)"
target="$root/src/CHANGELOG.md"

# cog prefixes each block with a "## <version> (range)" header; the GitHub
# Release title already shows the version, so drop that line (its "## " never
# collides with cog's "#### " section titles) and any blank lines it leaves.
strip_version_header() { { grep -v '^## ' || true; } | sed '/./,$!d'; }

feature_enables_section() {
  local base="$1" range flags
  if [ -n "$base" ]; then
    range="$base..HEAD"
  else
    range="HEAD"
  fi
  flags=$(
    git log "$range" --format='%B' 2>/dev/null | awk '
      /^Enables:[[:space:]]*/ {
        flag = $2
        gsub(/\r/, "", flag)
        if (flag != "" && !seen[flag]++) {
          print flag
        }
      }
    ' || true
  )
  [ -n "$flags" ] || return 0
  printf '%s\n' "#### Feature enables"
  while IFS= read -r flag; do
    [ -n "$flag" ] || continue
    printf '%s\n' "- $flag"
  done <<<"$flags"
}

case "$mode" in
  feature)
    base="$(git tag -l 'v*' --sort=v:refname | grep -E '^v[0-9]+\.[0-9]+\.0$' | tail -n1 || true)"
    if [ -n "$base" ]; then
      body="$(cog changelog "$base..HEAD")"
    else
      body="$(cog changelog)"
    fi

    # De-dup (ADR 0010): drop commits already shipped by a hotfix Release, read
    # from the shipped-shas marker in each published hotfix (patch>0) body.
    shipped=""
    while IFS= read -r tag; do
      [ -n "$tag" ] || continue
      printf '%s' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[1-9][0-9]*$' || continue
      hotfix_body="$(gh release view "$tag" --json body --jq .body 2>/dev/null || true)"
      marker="$(printf '%s' "$hotfix_body" | sed -n 's/.*cli-setup:shipped-shas\(.*\)-->.*/\1/p')"
      shipped="$shipped $marker"
    done < <(gh release list --limit 1000 --json tagName,isDraft --jq '.[] | select(.isDraft == false) | .tagName')

    for sha in $shipped; do
      short="$(printf '%s' "$sha" | cut -c1-7)"
      [ -n "$short" ] || continue
      body="$(printf '%s\n' "$body" | grep -v "($short)" || true)"
    done

    enables="$(feature_enables_section "$base")"
    if [ -n "$enables" ]; then
      body="$(printf '%s\n%s\n' "$body" "$enables")"
    fi

    printf '%s\n' "$body" | strip_version_header >"$target"
    ;;
  hotfix)
    pr="${2:?release-notes.sh hotfix needs a PR number}"
    # Scope the notes to the PR's commits (linear history: they are the tip).
    commits="$(gh pr view "$pr" --json commits --jq '.commits[].oid')"
    oldest="$(printf '%s\n' "$commits" | head -n1)"
    if git rev-parse -q --verify "$oldest^" >/dev/null 2>&1; then
      range="$oldest^..HEAD"
    else
      range="$oldest..HEAD"
    fi
    # Record the shipped SHAs so the feature draft can de-dup them later (D3).
    shas="$(printf '%s' "$commits" | tr '\n' ' ')"
    {
      cog changelog "$range" | strip_version_header
      printf '\n<!-- cli-setup:shipped-shas %s -->\n' "$shas"
    } >"$target"
    ;;
  *)
    echo "release-notes.sh: unknown mode '$mode' (use 'feature' or 'hotfix')" >&2
    exit 2
    ;;
esac
