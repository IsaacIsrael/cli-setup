Describe '_vendor_path'
  vendor_lib="$SHELLSPEC_PROJECT_ROOT/src/vendor/vendor_exec.sh"
  BeforeEach "source \"$vendor_lib\""

  It 'resolves under the install root'
    export CLI_SETUP_ROOT="$SHELLSPEC_TMPBASE/vendor-root-$$"
    mkdir -p "$CLI_SETUP_ROOT"
    When call _vendor_path jq
    The output should equal "$CLI_SETUP_ROOT/vendor/jq"
    The status should be success
  End
End

Describe 'jq'
  vendor_lib="$SHELLSPEC_PROJECT_ROOT/src/vendor/vendor_exec.sh"
  jq_wrapper="$SHELLSPEC_PROJECT_ROOT/src/vendor/jq.sh"

  # shellcheck disable=SC2329  # ShellSpec invokes BeforeEach/AfterEach hooks indirectly
  setup_vendor() {
    if [ ! -f "$jq_wrapper" ]; then
      bash "$SHELLSPEC_PROJECT_ROOT/maintenance/lib/sync-vendors.sh" host
    fi
    test_root="$SHELLSPEC_TMPBASE/vendor-exec-$$"
    export CLI_SETUP_ROOT="$test_root"
    mkdir -p "$CLI_SETUP_ROOT/vendor"
    cp "$SHELLSPEC_PROJECT_ROOT/src/vendor/jq" "$CLI_SETUP_ROOT/vendor/jq"
  }

  # shellcheck disable=SC2329
  teardown_vendor() {
    rm -rf "$test_root"
  }

  BeforeEach setup_vendor
  AfterEach teardown_vendor
  BeforeEach "source \"$vendor_lib\""

  It 'runs the vendored binary via the generated wrapper'
    When call jq --version
    The output should match pattern "jq-*"
    The status should be success
  End

  Describe 'vendor_exec'
    It 'runs the vendored binary'
      When call vendor_exec jq --version
      The output should match pattern "jq-*"
      The status should be success
    End

    It 'returns 127 when the binary is missing'
      clear_path "vendor/jq"
      When call vendor_exec jq --version
      The status should equal 127
      The stderr should include "vendor: jq not found at"
    End
  End
End
