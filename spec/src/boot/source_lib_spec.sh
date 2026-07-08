Describe 'source_lib'
  BeforeEach "source \"$SHELLSPEC_PROJECT_ROOT/src/boot/bootstrap.sh\""

  Describe 'explicit path (contains /)'
    It 'loads a boot module by path'
      When call source_lib boot/root
      The status should be success
    End

    It 'loads a lib module by path'
      When call source_lib lib/version
      The status should be success
    End

    It 'is a no-op when the same module is loaded twice'
      source_lib boot/root
      When call source_lib boot/root
      The status should be success
    End

    It 'sources index.sh when the path is a directory'
      idx_dir="$SHELLSPEC_PROJECT_ROOT/src/tools/idx-test-$$"
      mkdir -p "$idx_dir"
      printf '%s\n' '_IDX_TEST_LOADED=1' >"$idx_dir/index.sh"
      When call source_lib "tools/idx-test-$$"
      The status should be success
      rm -rf "$idx_dir"
    End
  End

  Describe 'vendor shorthand (no /)'
    It 'loads vendor_exec from the vendor directory'
      When call source_lib vendor_exec
      The status should be success
    End

    It 'loads jq wrapper from vendor'
      When call source_lib jq
      The status should be success
    End
  End

  Describe 'error handling'
    It 'fails for a missing explicit path'
      When call source_lib lib/nonexistent
      The status should be failure
      The stderr should include "not found"
    End

    It 'fails for a missing vendor module'
      When call source_lib nonexistent
      The status should be failure
      The stderr should include "not found in vendor"
    End
  End
End
