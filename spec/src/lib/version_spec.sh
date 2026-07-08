Describe 'installed_version'
  BeforeEach "source \"$SHELLSPEC_PROJECT_ROOT/src/lib/version.sh\""

  It 'reads the version from the VERSION file at the install root'
    printf '%s\n' '1.2.3' >"$CLI_SETUP_ROOT/VERSION"
    When call installed_version "$CLI_SETUP_ROOT"
    The output should equal "1.2.3"
    The status should be success
  End

  It 'returns the dev sentinel when no VERSION file exists'
    clear_path "VERSION"
    When call installed_version "$CLI_SETUP_ROOT"
    The output should equal "0.0.0-dev"
    The status should be success
  End
End
