#!/usr/bin/env bash
# Shared logging for maintenance scripts. All output goes to stderr.
#
#   source "$(dirname "$0")/log.sh"
#   log_init "sync-vendors"
#
#   log_start "Syncing vendors 📦"
#   log_info  "target=host brewfile=..."
#   log_step  "copying jq from Homebrew"
#   log_ok
#   log_step  "writing wrapper jq.sh"
#   log_fail
#   log_error "jq not found at /opt/homebrew/opt/jq/bin/jq"
#   log_end   "Syncing vendors done 📦"
set -euo pipefail

_LOG_PREFIX=""
_LOG_STEP_ACTIVE=0

_log_timestamp() {
  date +%H:%M:%S
}

_log_line() {
  [ "${LOG_QUIET:-}" = 1 ] && return 0
  printf '[%s] %s %s\n' "$_LOG_PREFIX" "$(_log_timestamp)" "$*" >&2
}

log_init() {
  _LOG_PREFIX="$1"
}

log_start() {
  _log_line "$*"
}

log_info() {
  _log_line "$*"
}

log_step() {
  if [ "${LOG_QUIET:-}" != 1 ]; then
    printf '[%s] %s %s … ' "$_LOG_PREFIX" "$(_log_timestamp)" "$*" >&2
  fi
  _LOG_STEP_ACTIVE=1
}

log_ok() {
  if [ "$_LOG_STEP_ACTIVE" -eq 1 ]; then
    [ "${LOG_QUIET:-}" != 1 ] && printf '\033[32m✔︎\033[0m\n' >&2
    _LOG_STEP_ACTIVE=0
  fi
}

log_fail() {
  if [ "$_LOG_STEP_ACTIVE" -eq 1 ]; then
    [ "${LOG_QUIET:-}" != 1 ] && printf '\033[31m✘\033[0m\n' >&2
    _LOG_STEP_ACTIVE=0
  fi
}

log_error() {
  printf '[%s] %s %s\n' "$_LOG_PREFIX" "$(_log_timestamp)" "$*" >&2
}

log_end() {
  _log_line "$*"
}
