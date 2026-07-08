#!/usr/bin/env bash
# Module loader — loaded via boot/bootstrap.sh; then source_lib <path>.
#   source_lib boot/root       # explicit: src/boot/root.sh
#   source_lib lib/flags       # explicit: src/lib/flags.sh
#   source_lib tools/node      # explicit dir: src/tools/node/index.sh
#   source_lib vendor_exec     # vendor shorthand: src/vendor/vendor_exec.sh
#   source_lib jq              # vendor shorthand: src/vendor/jq.sh
set -euo pipefail

_boot_dir=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
_src_root="$(dirname "$_boot_dir")"

# Idempotent loader. Two resolution modes:
#   contains /  → explicit path relative to src/ (dir → index.sh, file → .sh)
#   no /        → vendor shorthand (src/vendor/<name>.sh)
source_lib() {
  local name="$1" mark path
  name=${name%.sh}
  mark="_CLI_SETUP_LOADED_${name//\//_}"
  # shellcheck disable=SC2154  # indirect expansion via eval
  eval "[ -n \"\${$mark:-}\" ]" && return 0

  if [ "${name#*/}" != "$name" ]; then
    path="$_src_root/$name"
    if [ -d "$path" ]; then
      if [ ! -f "$path/index.sh" ]; then
        printf 'source_lib: %s/index.sh not found\n' "$name" >&2
        return 1
      fi
      # shellcheck source=/dev/null
      . "$path/index.sh"
    elif [ -f "$path.sh" ]; then
      # shellcheck source=/dev/null
      . "$path.sh"
    else
      printf 'source_lib: %s not found\n' "$name" >&2
      return 1
    fi
  else
    path="$_src_root/vendor/${name}.sh"
    if [ -f "$path" ]; then
      # shellcheck source=/dev/null
      . "$path"
    else
      printf 'source_lib: %s not found in vendor/\n' "$name" >&2
      return 1
    fi
  fi

  eval "$mark=1"
}
