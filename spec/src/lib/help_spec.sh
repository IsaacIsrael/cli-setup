Describe 'print_help'
  BeforeEach "source \"$SHELLSPEC_PROJECT_ROOT/src/lib/help.sh\""

  It 'prints the usage, planned commands, and global flags'
    When call print_help cli-setup
    The output should include "Usage:"
    The output should include "doctor"
    The output should include "setup"
    The output should include "update"
    The output should include "config"
    The output should include "planned"
    The output should include "--verbose"
    The status should be success
  End
End
