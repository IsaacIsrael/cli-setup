Describe 'cli-setup dispatcher'
  # Seam 1: the entrypoint is exercised as an external process (see
  # spec/spec_helper.sh). These behaviors need no outside-world commands, so no
  # Mocks are required yet; the command specs added in later slices will mock
  # brew/curl/rbenv/… on this same entrypoint.

  Describe '--version'
    # install.sh materializes <root>/VERSION on the user's machine from the
    # released tag (ADR 0010); a repo checkout has none. CLI_SETUP_ROOT is the
    # install root the entrypoint resolves, so stage a VERSION there and remove
    # it after — proving --version reads that file.
    BeforeEach 'printf "1.2.3\n" > "$CLI_SETUP_ROOT/VERSION"'
    AfterEach 'rm -f "$CLI_SETUP_ROOT/VERSION"'

    It 'prints the version read from the VERSION file'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" --version
      The output should equal "1.2.3"
      The status should be success
    End

    It 'resolves the VERSION file when invoked through a PATH symlink'
      # install.sh symlinks the entrypoint onto PATH; --version must still find
      # <root>/VERSION by following the link back to its bin/ directory.
      link="$SHELLSPEC_TMPBASE/cli-setup"
      ln -sf "$CLI_SETUP_ROOT/bin/cli-setup" "$link"
      When run script "$link" --version
      The output should equal "1.2.3"
      The status should be success
    End
  End
End
