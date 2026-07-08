#!/usr/bin/env bash
# Usage text shared by the entrypoint and future command handlers.
set -euo pipefail

# Print the CLI usage. $1 is the program name (defaults to cli-setup).
print_help() {
  local prog="${1:-cli-setup}"
  cat <<EOF
$prog — guided macOS dev environment setup.

Usage:
  $prog [command] [options]

Commands (planned):
  doctor <profile>    Diagnose what's missing for a profile (read-only).
  setup <profile>     Install and adjust the missing tools for a profile.
  update <profile>    Reconcile installed tools to the team config.
  config <action>     Manage the team config.

Options:
      --version       Print the installed version and exit.
  -h, --help          Print this help and exit.
  -v, --verbose       Show detailed output.

Run with no arguments to print this help.
EOF
}
