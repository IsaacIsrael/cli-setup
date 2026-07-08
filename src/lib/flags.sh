#!/usr/bin/env bash
# Feature-flag resolver — manifest at <root>/flags.json, JSON via vendored jq
# (ADR 0012). Boot runs once in bin/cli-setup and spec/spec_helper.sh (src/boot/).
set -euo pipefail

source_lib lib/semver
source_lib jq
source_lib lib/version

FLAGS_MANIFEST_NAME="flags.json"
_KILL_SWITCH_URL="https://gist.githubusercontent.com/REPLACE_ME/raw/kill-switch.json"
_KILL_SWITCH_CACHE="kill-switch.cache.json"

_flags_manifest_path() {
  printf '%s/%s\n' "$(resolve_root)" "$FLAGS_MANIFEST_NAME"
}

_flags_kill_switch_cache() {
  printf '%s/%s\n' "$(resolve_root)" "$_KILL_SWITCH_CACHE"
}

_flags_kill_switch_url() {
  if [ -n "${CLI_SETUP_KILL_SWITCH_URL:-}" ]; then
    printf '%s\n' "$CLI_SETUP_KILL_SWITCH_URL"
    return 0
  fi
  printf '%s\n' "$_KILL_SWITCH_URL"
}

_flags_env_var_name() {
  local flag="$1"
  printf 'CLI_SETUP_FF_%s' "$(printf '%s' "$flag" | tr '[:lower:]' '[:upper:]')"
}

# Echo enabled/disabled from the env override, or return 2 when unset.
_flags_env_override() {
  local flag="$1" var val
  var=$(_flags_env_var_name "$flag")
  # shellcheck disable=SC2154  # indirect expansion via eval
  eval "val=\${$var:-}"
  case "$val" in
    1 | true | on | TRUE | ON) return 0 ;;
    0 | false | off | FALSE | OFF) return 1 ;;
    *) return 2 ;;
  esac
}

_flags_fetch_kill_switch() {
  [ -n "${_CLI_SETUP_KILL_FETCHED:-}" ] && return 0
  _CLI_SETUP_KILL_FETCHED=1

  local url cache dir tmp
  url=$(_flags_kill_switch_url)
  cache=$(_flags_kill_switch_cache)
  dir=$(dirname "$cache")
  mkdir -p "$dir"
  tmp="${cache}.tmp.$$"
  if curl --max-time 2 -fsSL "$url" -o "$tmp" 2>/dev/null; then
    mv "$tmp" "$cache"
  else
    rm -f "$tmp"
  fi
}

_flags_remotely_disabled() {
  local flag="$1" cache item
  _flags_fetch_kill_switch
  cache=$(_flags_kill_switch_cache)
  [ -f "$cache" ] || return 1
  while IFS= read -r item; do
    [ -n "$item" ] || continue
    if [ "$item" = "$flag" ]; then
      return 0
    fi
  done < <(jq -r '.disabled[]' "$cache" 2>/dev/null || true)
  return 1
}

# Return success when the flag is enabled for the current install.
flag_enabled() {
  local flag="$1"
  local manifest state since installed env_result

  manifest=$(_flags_manifest_path)
  if [ ! -f "$manifest" ]; then
    return 1
  fi

  state=$(jq -r ".\"$flag\".state" "$manifest" 2>/dev/null || true)
  since=$(jq -r ".\"$flag\".since" "$manifest" 2>/dev/null || true)
  if [ -z "$state" ] || [ "$state" = "null" ]; then
    return 1
  fi

  if _flags_remotely_disabled "$flag"; then
    return 1
  fi

  _flags_env_override "$flag"
  env_result=$?
  if [ "$env_result" -eq 0 ]; then
    return 0
  fi
  if [ "$env_result" -eq 1 ]; then
    return 1
  fi

  installed=$(installed_version)
  if [ "$installed" = "$CLI_SETUP_DEV_VERSION" ]; then
    return 0
  fi

  if [ "$state" = "on" ] && semver_gte "$installed" "$since"; then
    return 0
  fi
  return 1
}
