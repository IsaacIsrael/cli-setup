#!/usr/bin/env bash
# Bootstrap and maintain the dev toolchain + runtime vendors.
#
#   install.sh              # brew bundle + vendor (host) + lefthook
#   install.sh --ci         # brew bundle + vendor (host); CI — no lefthook
#   install.sh --update     # brew bundle + vendor (host); refresh — no lefthook
#   install.sh --vendor     # vendor (host) only — sync src/vendor/ from Brewfile
#   install.sh --vendor --macos   # vendor (macos) only — release packaging
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
lib="$root/maintenance/lib"

do_brew=false
do_vendor=false
do_hooks=false
vendor_target=host
explicit=false

while [ $# -gt 0 ]; do
  explicit=true
  case "$1" in
    --ci)
      do_brew=true
      do_vendor=true
      ;;
    --update)
      do_brew=true
      do_vendor=true
      ;;
    --vendor)
      do_vendor=true
      ;;
    --macos)
      vendor_target=macos
      ;;
    *)
      printf 'install.sh: unknown flag %s\n' "$1" >&2
      printf 'usage: install.sh [--ci | --update | --vendor [--macos]]\n' >&2
      exit 2
      ;;
  esac
  shift
done

if [ "$explicit" = false ]; then
  do_brew=true
  do_vendor=true
  do_hooks=true
fi

if [ "$do_vendor" = true ] && [ "$vendor_target" = macos ] && [ "$do_brew" = false ]; then
  :
elif [ "$explicit" = true ] && [ "$do_brew" = false ] && [ "$do_vendor" = false ]; then
  printf 'install.sh: pass at least one of --ci, --update, or --vendor\n' >&2
  exit 2
fi

if [ "$do_brew" = true ]; then
  brew bundle --file="$root/Brewfile"
fi

if [ "$do_vendor" = true ]; then
  bash "$lib/sync-vendors.sh" "$vendor_target"
fi

if [ "$do_hooks" = true ]; then
  lefthook install
fi
