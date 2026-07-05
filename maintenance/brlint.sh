#!/usr/bin/env bash
# Validate a branch name against the Git Flow naming convention (config-free,
# pure shell — no Node). Runs locally via the Lefthook pre-push hook and in CI
# as the branch-lint gate, the unbypassable backstop. See CONTRIBUTING.md and
# ADR 0010.
#
#   brlint.sh              # validate the current branch (or $GITHUB_HEAD_REF in CI)
#   brlint.sh <name>       # validate an explicit branch name
#
# Allowed:
#   main
#   <feature|bugfix|hotfix|release|support>/<kebab-case-description>
#
# A leading issue number (feature/5-branch-name-lint) is recommended but
# optional: a prefixed branch without one passes with a warning, never a failure.
set -euo pipefail

# Resolve the branch to check: an explicit argument wins, then the PR head ref
# GitHub exposes in CI (HEAD there is a detached merge commit, not the branch),
# then the locally checked-out branch for the pre-push hook.
resolve_branch() {
  if [ "$#" -gt 0 ] && [ -n "$1" ]; then
    printf '%s\n' "$1"
  elif [ -n "${GITHUB_HEAD_REF:-}" ]; then
    printf '%s\n' "$GITHUB_HEAD_REF"
  else
    git rev-parse --abbrev-ref HEAD
  fi
}

branch="$(resolve_branch "$@")"

if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
  echo "branch-lint: could not determine the current branch (detached HEAD?)." >&2
  echo "Pass the branch name explicitly: maintenance/brlint.sh <name>" >&2
  exit 1
fi

# main is the only bare (prefix-less) name; every other branch is
# <prefix>/<kebab-case>, where kebab-case is lowercase alphanumerics in
# hyphen-separated words (an issue number may lead, e.g. 5-branch-name-lint).
prefixes='feature|bugfix|hotfix|release|support'
if printf '%s' "$branch" | grep -Eq "^(main|($prefixes)/[a-z0-9]+(-[a-z0-9]+)*)$"; then
  # A leading issue number (feature/5-foo) is recommended but optional, so a
  # prefixed branch without one still passes — only nudge. main is exempt.
  if printf '%s' "$branch" | grep -Eq "^($prefixes)/" &&
    ! printf '%s' "$branch" | grep -Eq "^($prefixes)/[0-9]+-"; then
    echo "branch-lint: '$branch' OK (no issue number in the slug — prefer <prefix>/<number>-<description>, e.g. feature/5-branch-name-lint)" >&2
  else
    echo "branch-lint: '$branch' OK" >&2
  fi
  exit 0
fi

cat >&2 <<EOF
branch-lint: '$branch' is not a valid branch name.

Use a Git Flow name — one of these prefixes plus a kebab-case description — or
the long-lived 'main':

  feature/<description>   new features and enhancements
  bugfix/<description>    non-urgent bug fixes
  hotfix/<description>    urgent fixes
  release/<description>   release preparation
  support/<description>   long-term maintenance

Descriptions are lowercase alphanumerics in hyphen-separated words, optionally
led by an issue number. Examples:

  feature/branch-name-lint
  feature/5-branch-name-lint
  hotfix/crash-on-launch
EOF
exit 1
