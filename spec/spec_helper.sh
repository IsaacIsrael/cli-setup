# ShellSpec harness for cli-setup. Auto-loaded before every spec via .shellspec
# (--require spec_helper). It establishes the seam-1 testing convention from the
# app layout: the CLI is exercised as an external process (`When run script`)
# with its outside-world commands (brew, curl, rbenv, gem, …) replaced by
# ShellSpec `Mock`s, so specs assert observable behavior without touching the
# real system. Adding a new spec needs no changes here.

# Lets specs locate the entrypoint regardless of ShellSpec's working directory:
#   When run script "$CLI_SETUP_ROOT/bin/cli-setup" --version
# shellcheck disable=SC2154  # SHELLSPEC_PROJECT_ROOT comes from the ShellSpec runtime
export CLI_SETUP_ROOT="${SHELLSPEC_PROJECT_ROOT}/src"
export LOG_QUIET=1

# Install-payload staging for specs that mutate files under CLI_SETUP_ROOT.
# Contract: preserve_path once (BeforeEach), stage per-example fixtures,
# restore_path after each example (AfterEach) — restores on-disk state (even {}),
# never a hardcoded default.

stage_file() {
  printf '%s\n' "$2" >"${CLI_SETUP_ROOT}/$1"
}

clear_path() {
  rm -rf "${CLI_SETUP_ROOT:?}/$1"
}

# Generic path preserve/restore — handles files and directories transparently.
# Paths are relative to $CLI_SETUP_ROOT. Storage: backups + existence markers
# live under $SHELLSPEC_TMPBASE/preserve/.
_preserve_store="${SHELLSPEC_TMPBASE}/preserve"

_preserve_key() {
  printf '%s' "$1" | tr '/' '_'
}

# shellcheck disable=SC2329  # ShellSpec invokes BeforeEach/AfterEach hooks indirectly
preserve_path() {
  local rel="$1" path key backup_path
  path="${CLI_SETUP_ROOT}/${rel}"
  key=$(_preserve_key "$rel")
  backup_path="${_preserve_store}/${key}"
  [ -f "${backup_path}.existed" ] && return 0
  mkdir -p "$_preserve_store"
  if [ -d "$path" ]; then
    cp -Rp "$path" "$backup_path"
    printf '1\n' >"${backup_path}.existed"
  elif [ -f "$path" ]; then
    cp "$path" "$backup_path"
    printf '1\n' >"${backup_path}.existed"
  else
    printf '0\n' >"${backup_path}.existed"
  fi
}

# shellcheck disable=SC2329
restore_path() {
  local rel="$1" path key backup_path existed
  path="${CLI_SETUP_ROOT}/${rel}"
  key=$(_preserve_key "$rel")
  backup_path="${_preserve_store}/${key}"
  [ -f "${backup_path}.existed" ] || return 0
  IFS= read -r existed <"${backup_path}.existed" || true
  if [ "$existed" = "1" ]; then
    if [ -d "$backup_path" ]; then
      rm -rf "$path"
      cp -Rp "$backup_path" "$path"
    else
      cp "$backup_path" "$path"
    fi
  else
    rm -rf "$path"
  fi
}

preserve_path "vendor"

# shellcheck source=../src/boot/bootstrap.sh
source "${CLI_SETUP_ROOT}/boot/bootstrap.sh"
