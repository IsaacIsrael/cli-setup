Describe 'maintenance/install.sh'
  # Routes install flags to brew bundle, vendor sync, and lefthook. External
  # commands are mocked; vendor sync uses a staged brew prefix for jq.
  install="$SHELLSPEC_PROJECT_ROOT/maintenance/install.sh"
  vendor_dir="$SHELLSPEC_PROJECT_ROOT/src/vendor"
  fake_prefix="$SHELLSPEC_TMPBASE/brew-jq"

  stage_fake_jq() {
    mkdir -p "$fake_prefix/bin"
    printf '%s\n' '#!/bin/sh' 'echo jq-stub' >"$fake_prefix/bin/jq"
    chmod +x "$fake_prefix/bin/jq"
  }

  BeforeEach stage_fake_jq
  AfterEach 'restore_path "vendor"'

  Describe 'flag validation'
    It 'rejects an unknown flag'
      When run script "$install" --nope
      The status should be failure
      The stderr should include "unknown flag"
    End

    It 'requires --vendor when passing --macos alone'
      When run script "$install" --macos
      The status should be failure
      The stderr should include "pass at least one"
    End
  End

  Describe '--vendor'
    It 'syncs src/vendor without running brew bundle or lefthook'
      Mock brew
        case "$1" in
          bundle) false ;;
          --prefix) printf '%s\n' "$SHELLSPEC_TMPBASE/brew-jq" ;;
        esac
      End
      Mock lefthook
        false
      End
      When run script "$install" --vendor
      The status should be success
      The path "$vendor_dir/jq" should be file
    End
  End

  Describe '--ci and --update'
    It 'runs brew bundle and vendor without lefthook on --ci'
      Mock brew
        case "$1" in
          bundle) exit 0 ;;
          --prefix) printf '%s\n' "$SHELLSPEC_TMPBASE/brew-jq" ;;
        esac
      End
      Mock lefthook
        false
      End
      When run script "$install" --ci
      The status should be success
      The path "$vendor_dir/jq" should be file
    End

    It 'runs brew bundle and vendor without lefthook on --update'
      Mock brew
        case "$1" in
          bundle) exit 0 ;;
          --prefix) printf '%s\n' "$SHELLSPEC_TMPBASE/brew-jq" ;;
        esac
      End
      Mock lefthook
        false
      End
      When run script "$install" --update
      The status should be success
      The path "$vendor_dir/jq" should be file
    End
  End

  Describe 'default bootstrap'
    It 'runs brew bundle, vendor, and lefthook with no flags'
      Mock brew
        case "$1" in
          bundle) exit 0 ;;
          --prefix) printf '%s\n' "$SHELLSPEC_TMPBASE/brew-jq" ;;
        esac
      End
      Mock lefthook
        :
      End
      When run script "$install"
      The status should be success
      The path "$vendor_dir/jq" should be file
    End
  End
End
