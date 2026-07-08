#!/usr/bin/env bash
# Vendor runtime entry — loaded via source_lib vendor_exec.
# Binaries at <root>/vendor/<name>; per-formula wrappers in <formula>.sh.
set -euo pipefail

_vendor_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Print the path to a vendored binary.
_vendor_path() {
  local name="$1" root
  root=$(resolve_root)
  printf '%s/vendor/%s\n' "$root" "$name"
}

# Execute a vendored binary; return 127 when missing.
vendor_exec() {
  local name="$1" bin
  shift
  bin=$(_vendor_path "$name")
  if [ ! -x "$bin" ]; then
    printf 'vendor: %s not found at %s (run just install)\n' "$name" "$bin" >&2
    return 127
  fi
  "$bin" "$@"
}
