#!/usr/bin/env bash
# Installed-version helpers shared by the entrypoint and lib.
# Requires boot (bin/cli-setup or spec_helper) to have loaded root first.
set -euo pipefail

CLI_SETUP_DEV_VERSION="0.0.0-dev"

# Print the installed version from <root>/VERSION, or the dev sentinel.
installed_version() {
  local root="${1:-}" version_file line
  if [ -z "$root" ]; then
    root=$(resolve_root)
  fi
  version_file="$root/VERSION"
  if [ -f "$version_file" ]; then
    line=""
    IFS= read -r line <"$version_file" || true
    printf '%s\n' "$line"
  else
    printf '%s\n' "$CLI_SETUP_DEV_VERSION"
  fi
}
