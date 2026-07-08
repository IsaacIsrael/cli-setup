#!/usr/bin/env bash
# Sync runtime vendored binaries into src/vendor/ (gitignored, like node_modules).
# Vendors are declared only in the Brewfile vendor section:
#
#   # vendor-meta <formula> version=<ver> repo=<org/repo> [tag=...] [asset=...] [url=...] [bin=...]
#   brew "<formula>"
#
# Placeholders in tag/asset/url: {formula} {version} {repo} {arch} {tag} {asset}
# Defaults: tag={formula}-{version} asset={formula}-macos-{arch}
#           url=https://github.com/{repo}/releases/download/{tag}/{asset} bin={formula}
#
#   sync-vendors.sh host   # copy from Homebrew for the current machine (dev + tests)
#   sync-vendors.sh macos  # macOS payload for release tarballs (cross-fetch on Linux CI)
#
# Always invoke via bash — never macOS `script sync-vendors.sh …` (that overwrites this file).
set -euo pipefail

# shellcheck source=log.sh
source "$(dirname "$0")/log.sh"
log_init "sync-vendors"

VENDOR_MARKER="# --- vendor:"
VENDOR_META_MARKER="# vendor-meta"
META_DELIM=$'\t'

root="$(cd "$(dirname "$0")/../.." && pwd)"
brewfile="${VENDOR_BREWFILE:-$root/Brewfile}"
vendor_dir="$root/src/vendor"
mkdir -p "$vendor_dir"

_vendor_parse_meta_line() {
  local content="$1"
  local formula="${content%% *}"

  VENDOR_META_FORMULA="$formula"
  VENDOR_META_VERSION=""
  VENDOR_META_REPO=""
  VENDOR_META_TAG=""
  VENDOR_META_ASSET=""
  VENDOR_META_URL=""
  VENDOR_META_BIN=""

  content=${content#"$formula"}
  content=${content# }

  while [ -n "$content" ]; do
    local key="${content%%=*}" val rest
    [ "$key" != "$content" ] || break
    rest=${content#*=}
    val=${rest%% *}
    case "$key" in
      version) VENDOR_META_VERSION="$val" ;;
      repo) VENDOR_META_REPO="$val" ;;
      tag) VENDOR_META_TAG="$val" ;;
      asset) VENDOR_META_ASSET="$val" ;;
      url) VENDOR_META_URL="$val" ;;
      bin) VENDOR_META_BIN="$val" ;;
    esac
    content=${rest#"$val"}
    content=${content# }
  done
}

# Emit one tab-separated vendor row per brew line under the vendor section.
_vendor_entries_from() {
  local file="$1"
  local pick=0 line formula
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      *"$VENDOR_MARKER"*)
        pick=1
        continue
        ;;
    esac
    [ "$pick" -eq 1 ] || continue

    case "$line" in
      *"$VENDOR_META_MARKER"*)
        line=${line#*"$VENDOR_META_MARKER"}
        line=${line# }
        _vendor_parse_meta_line "$line"
        ;;
      brew\ \"*\")
        formula=${line#brew \"}
        formula=${formula%%\"*}
        formula=${formula%% *}
        [ -z "$formula" ] && continue
        if [ -n "$VENDOR_META_FORMULA" ] && [ "$VENDOR_META_FORMULA" != "$formula" ]; then
          log_error "vendor-meta names $VENDOR_META_FORMULA but brew declares $formula"
          return 1
        fi
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
          "$formula" \
          "$VENDOR_META_VERSION" \
          "$VENDOR_META_REPO" \
          "$VENDOR_META_TAG" \
          "$VENDOR_META_ASSET" \
          "$VENDOR_META_URL" \
          "$VENDOR_META_BIN"
        VENDOR_META_FORMULA=""
        VENDOR_META_VERSION=""
        VENDOR_META_REPO=""
        VENDOR_META_TAG=""
        VENDOR_META_ASSET=""
        VENDOR_META_URL=""
        VENDOR_META_BIN=""
        ;;
    esac
  done <"$file"
}

_vendor_entries() {
  _vendor_entries_from "$brewfile"
}

_vendor_meta_expand() {
  local template="$1" formula="$2" version="$3" repo="$4" arch="$5" tag="$6" asset="$7"
  local result="$template"
  result=${result//\{formula\}/$formula}
  result=${result//\{version\}/$version}
  result=${result//\{repo\}/$repo}
  result=${result//\{arch\}/$arch}
  result=${result//\{tag\}/$tag}
  result=${result//\{asset\}/$asset}
  printf '%s' "$result"
}

_vendor_copy_from_brew() {
  local formula="$1" dest="$2" bin_name="$3" prefix bin
  log_step "copying $formula from Homebrew"
  prefix=$(brew --prefix "$formula")
  bin="$prefix/bin/$bin_name"
  if [ ! -x "$bin" ]; then
    log_fail
    log_error "$bin_name not found at $bin (run just install)"
    return 1
  fi
  rm -f "$dest"
  cp "$bin" "$dest"
  chmod +x "$dest"
  log_ok
}

_vendor_fetch_macos_release() {
  local formula="$1" version="$2" repo="$3" dest="$4"
  local tag_t="$5" asset_t="$6" url_t="$7" arch asset tag url tmp
  if [ -z "$version" ] || [ -z "$repo" ]; then
    log_error "$formula needs vendor-meta version= and repo= in the Brewfile for macOS cross-fetch"
    return 1
  fi
  arch="${VENDOR_MACOS_ARCH:-arm64}"
  case "$arch" in
    arm64 | aarch64) arch=arm64 ;;
    amd64 | x86_64) arch=amd64 ;;
    *)
      log_error "unsupported VENDOR_MACOS_ARCH $arch"
      return 1
      ;;
  esac
  tag_t=${tag_t:-'{formula}-{version}'}
  asset_t=${asset_t:-'{formula}-macos-{arch}'}
  tag=$(_vendor_meta_expand "$tag_t" "$formula" "$version" "$repo" "$arch" "" "")
  asset=$(_vendor_meta_expand "$asset_t" "$formula" "$version" "$repo" "$arch" "$tag" "")
  if [ -n "$url_t" ]; then
    url=$(_vendor_meta_expand "$url_t" "$formula" "$version" "$repo" "$arch" "$tag" "$asset")
  else
    url="https://github.com/${repo}/releases/download/${tag}/${asset}"
  fi
  log_step "fetching $formula from $url"
  tmp="$dest.tmp.$$"
  if ! curl -fsSL --max-time 30 "$url" -o "$tmp"; then
    log_fail
    log_error "download failed for $formula"
    return 1
  fi
  chmod +x "$tmp"
  mv "$tmp" "$dest"
  log_ok
}

_vendor_write_wrappers() {
  local formula slug tmp wrapper
  while IFS="$META_DELIM" read -r formula _ _ _ _ _ _; do
    [ -n "$formula" ] || continue
    slug=${formula//-/_}
    wrapper="$vendor_dir/${formula}.sh"
    tmp="$wrapper.tmp.$$"
    log_step "writing wrapper ${formula}.sh"
    {
      printf '%s\n' \
        '#!/usr/bin/env bash' \
        "# Generated by maintenance/lib/sync-vendors.sh — do not edit." \
        'set -euo pipefail' \
        '' \
        'source_lib vendor_exec'
      printf '%s() { vendor_exec %s "$@"; }\n' "$slug" "$formula"
    } >"$tmp"
    mv "$tmp" "$wrapper"
    log_ok
  done < <(_vendor_entries_from "$root/Brewfile")
}

_vendor_sync_host() {
  local formula version repo tag asset url bin_name dest
  while IFS="$META_DELIM" read -r formula version repo tag asset url bin_name; do
    [ -n "$formula" ] || continue
    bin_name=${bin_name:-$formula}
    dest="$vendor_dir/$formula"
    _vendor_copy_from_brew "$formula" "$dest" "$bin_name"
  done < <(_vendor_entries)
}

_vendor_sync_macos() {
  local formula version repo tag asset url bin_name dest os
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  while IFS="$META_DELIM" read -r formula version repo tag asset url bin_name; do
    [ -n "$formula" ] || continue
    bin_name=${bin_name:-$formula}
    dest="$vendor_dir/$formula"
    if [ "$os" = "darwin" ]; then
      _vendor_copy_from_brew "$formula" "$dest" "$bin_name"
    else
      _vendor_fetch_macos_release "$formula" "$version" "$repo" "$dest" "$tag" "$asset" "$url"
    fi
  done < <(_vendor_entries)
}

target="${1:-host}"
log_start "Syncing vendors 📦"
log_info "target=$target brewfile=$brewfile"
case "$target" in
  host) _vendor_sync_host ;;
  macos) _vendor_sync_macos ;;
  *)
    log_error "unknown target $target (use host or macos)"
    exit 2
    ;;
esac
_vendor_write_wrappers
log_end "Syncing vendors done 📦"
