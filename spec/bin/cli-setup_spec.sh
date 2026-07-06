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

  Describe '--version without a VERSION file'
    # A dev checkout (or an incomplete install) has no VERSION file. --version
    # still succeeds, printing a dev sentinel instead of a real number.
    BeforeEach 'rm -f "$CLI_SETUP_ROOT/VERSION"'

    It 'prints a dev sentinel and exits zero'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" --version
      The output should equal "0.0.0-dev"
      The status should be success
    End
  End

  Describe '--help / -h'
    It 'prints the usage, planned commands, and global flags'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" --help
      The output should include "Usage:"
      The output should include "doctor"
      The output should include "setup"
      The output should include "update"
      The output should include "config"
      The output should include "planned"
      The output should include "--verbose"
      The status should be success
    End

    It 'prints the same usage for the -h alias'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" -h
      The output should include "Usage:"
      The status should be success
    End
  End

  Describe 'no arguments'
    It 'prints the help'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup"
      The output should include "Usage:"
      The status should be success
    End
  End

  Describe 'planned commands'
    It 'reports a planned command as not implemented and exits non-zero'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" doctor
      The status should be failure
      The error should include "not implemented"
    End
  End

  Describe 'the global --verbose flag'
    # --verbose/-v is advertised in the usage as a global flag, so it must be
    # accepted, not rejected as unknown. It gates output verbosity once the
    # commands land; with no command to run it just prints the help.
    It 'accepts --verbose and prints the help when no command follows'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" --verbose
      The output should include "Usage:"
      The status should be success
    End

    It 'accepts the -v alias'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" -v
      The output should include "Usage:"
      The status should be success
    End
  End

  Describe 'unknown input'
    It 'errors and exits non-zero on an unknown command'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" bogus
      The status should be failure
      The error should include "unknown command"
    End

    It 'errors and exits non-zero on an unknown option'
      When run script "$CLI_SETUP_ROOT/bin/cli-setup" --nope
      The status should be failure
      The error should include "unknown option"
    End
  End
End
