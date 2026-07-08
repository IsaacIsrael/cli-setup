Describe 'resolve_root'
  BeforeEach "source \"$SHELLSPEC_PROJECT_ROOT/src/boot/root.sh\""

  It 'honors CLI_SETUP_ROOT when set'
    export CLI_SETUP_ROOT="$SHELLSPEC_TMPBASE/custom-root"
    mkdir -p "$CLI_SETUP_ROOT"
    When call resolve_root
    The output should equal "$CLI_SETUP_ROOT"
    The status should be success
  End

  It 'resolves src/ from boot when CLI_SETUP_ROOT is unset'
    unset CLI_SETUP_ROOT
    When call resolve_root
    The output should equal "$SHELLSPEC_PROJECT_ROOT/src"
    The status should be success
  End
End
