#!/usr/bin/env bash
# awk-based semver comparison for macOS Bash 3.2 (no reliable sort -V).
set -euo pipefail

# Return success when $1 >= $2 (plain semver, no v prefix).
semver_gte() {
  local a="$1" b="$2"
  awk -v a="$a" -v b="$b" '
    BEGIN {
      split(a, pa, ".")
      split(b, pb, ".")
      for (i = 1; i <= 3; i++) {
        pa[i] = pa[i] + 0
        pb[i] = pb[i] + 0
        if (pa[i] > pb[i]) exit 0
        if (pa[i] < pb[i]) exit 1
      }
      exit 0
    }
  '
}
