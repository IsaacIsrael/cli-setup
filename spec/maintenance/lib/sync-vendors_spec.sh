Describe 'maintenance/lib/sync-vendors.sh'
  # Syncs the Brewfile vendor section into src/vendor/. brew/curl are mocked at
  # the boundary; the spec asserts the staged binaries, not shell internals.
  sync="$SHELLSPEC_PROJECT_ROOT/maintenance/lib/sync-vendors.sh"
  vendor_dir="$SHELLSPEC_PROJECT_ROOT/src/vendor"
  jq_wrapper="$SHELLSPEC_PROJECT_ROOT/src/vendor/jq.sh"
  fake_prefix="$SHELLSPEC_TMPBASE/brew-jq"

  stage_fake_jq() {
    mkdir -p "$fake_prefix/bin"
    printf '%s\n' '#!/bin/sh' 'echo jq-stub' >"$fake_prefix/bin/jq"
    chmod +x "$fake_prefix/bin/jq"
  }

  BeforeEach 'stage_fake_jq'
  AfterEach 'restore_path "vendor"'

  Describe 'host mode'
    It 'copies each vendor formula into src/vendor/'
      Mock brew
        case "$1" in
          --prefix) printf '%s\n' "$SHELLSPEC_TMPBASE/brew-jq" ;;
        esac
      End
      When run bash "$sync" host
      The status should be success
      The path "$vendor_dir/jq" should be file
    End

    It 'generates a per-library wrapper from the Brewfile'
      Mock brew
        case "$1" in
          --prefix) printf '%s\n' "$SHELLSPEC_TMPBASE/brew-jq" ;;
        esac
      End
      When run bash "$sync" host
      The path "$jq_wrapper" should be file
      The contents of file "$jq_wrapper" should include "jq() { vendor_exec jq"
    End
  End

  Describe 'macos mode'
    It 'stages macOS jq into src/vendor'
      Mock brew
        case "$1" in
          --prefix) printf '%s\n' "$SHELLSPEC_TMPBASE/brew-jq" ;;
        esac
      End
      Mock curl
        while [ $# -gt 0 ]; do
          case "$1" in
            -o) dest="$2"; shift 2 ;;
            *) shift ;;
          esac
        done
        printf '%s\n' '#!/bin/sh' 'echo macos-jq' >"$dest"
        chmod +x "$dest"
      End
      When run bash "$sync" macos
      The status should be success
      The path "$vendor_dir/jq" should be file
    End
  End

  Describe 'invalid input'
    It 'rejects an unknown target'
      When run bash "$sync" linux
      The status should be failure
      The stderr should include "unknown target"
    End
  End

  Describe 'Brewfile-driven vendors'
    It 'syncs any vendor formula declared in the Brewfile'
      brewfile="$SHELLSPEC_TMPBASE/vendor-brewfile"
      gum_prefix="$SHELLSPEC_TMPBASE/brew-gum"
      printf '%s\n' \
        '# --- vendor: ---' \
        '# vendor-meta gum version=0.14.5 repo=charmbracelet/gum tag=v{version} asset=gum_{version}_darwin_{arch}.tar.gz bin=gum' \
        'brew "gum"' >"$brewfile"
      mkdir -p "$gum_prefix/bin"
      printf '%s\n' '#!/bin/sh' 'echo gum-stub' >"$gum_prefix/bin/gum"
      chmod +x "$gum_prefix/bin/gum"
      Mock brew
        case "$1" in
          --prefix) printf '%s\n' "$SHELLSPEC_TMPBASE/brew-gum" ;;
        esac
      End
      export VENDOR_BREWFILE="$brewfile"
      When run bash "$sync" host
      The status should be success
      The path "$vendor_dir/gum" should be file
    End
  End
End
