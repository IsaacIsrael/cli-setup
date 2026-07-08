Describe 'maintenance/lib/log.sh'
  log_lib="$SHELLSPEC_PROJECT_ROOT/maintenance/lib/log.sh"

  setup_log() {
    source "$log_lib"
    log_init "test"
  }
  BeforeEach 'setup_log'

  Describe 'LOG_QUIET suppresses progress but not errors'
    It 'suppresses log_info when LOG_QUIET=1'
      export LOG_QUIET=1
      When call log_info "should be hidden"
      The stderr should equal ""
    End

    It 'still outputs log_error when LOG_QUIET=1'
      export LOG_QUIET=1
      When call log_error "something broke"
      The stderr should include "something broke"
    End
  End
End
