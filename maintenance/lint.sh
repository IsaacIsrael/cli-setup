#!/usr/bin/env bash
# Run ShellCheck over the repo's shell files (config in .shellcheckrc).
# ShellCheck can't discover files itself, so this finds them first, then lints.
#
#   lint.sh          # whole project (tracked + new, non-ignored shell files)
#   lint.sh stage    # only the staged shell files (added/copied/modified)
#
# A shell file is a *.sh/*.bash path, or a file whose first line is a shell
# shebang (so an extensionless entrypoint like src/bin/cli-setup is covered).
set -euo pipefail

mode="${1:-all}"
case "$mode" in
  all | stage | staged) ;;
  *)
    echo "lint.sh: unknown mode '$mode' (use 'all' or 'stage')" >&2
    exit 2
    ;;
esac

# Emit the candidate paths for the mode. Runs in a process-substitution subshell
# below, so the mode is validated above (in the main shell) rather than here.
candidates() {
  case "$1" in
    # Tracked files plus new (untracked) ones, so a file you haven't `git add`ed
    # yet is still linted — matching `just fmt`'s working-tree coverage.
    # --exclude-standard honors .gitignore, so ephemeral .scratch/ stays out.
    all) git ls-files --cached --others --exclude-standard ;;
    stage | staged) git diff --cached --name-only --diff-filter=ACM ;;
  esac
}

is_shell_file() {
  case "$1" in
    *.sh | *.bash) return 0 ;;
  esac
  [ -f "$1" ] || return 1
  head -n 1 "$1" | grep -qE '^#!.*/(env +)?(ba)?sh( |$)'
}

files=()
while IFS= read -r path; do
  if [ -n "$path" ] && is_shell_file "$path"; then
    files+=("$path")
  fi
done < <(candidates "$mode")

if [ "${#files[@]}" -eq 0 ]; then
  exit 0
fi

shellcheck -- "${files[@]}"

# ShellCheck is silent on success; print a summary so a clean run is visible.
# To stderr, keeping stdout clean for callers that pipe it.
printf 'shellcheck: %d file(s) OK\n' "${#files[@]}" >&2
