#!/usr/bin/env bash
# Install-root resolution shared by the entrypoint and lib.
set -euo pipefail

_resolve_root_from_script() {
  local source="$1" dir
  while [ -h "$source" ]; do
    dir=$(cd -P "$(dirname "$source")" >/dev/null 2>&1 && pwd)
    source=$(readlink "$source")
    case $source in
      /*) ;;
      *) source=$dir/$source ;;
    esac
  done
  dir=$(cd -P "$(dirname "$source")" >/dev/null 2>&1 && pwd)
  dirname "$dir"
}

# Resolve the install root (parent of bin/). Honors CLI_SETUP_ROOT for tests.
# Pass the entrypoint path ($0) for symlink-aware resolution from bin/.
# shellcheck disable=SC2120  # $1 is an optional entrypoint override
resolve_root() {
  if [ -n "${CLI_SETUP_ROOT:-}" ]; then
    printf '%s\n' "$CLI_SETUP_ROOT"
    return 0
  fi
  if [ -n "${1:-}" ]; then
    _resolve_root_from_script "$1"
    return 0
  fi
  local boot_dir
  boot_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  dirname "$boot_dir"
}
