Describe 'cli-setup entrypoint'
  # Smoke test proving the harness runs the real entrypoint as an external
  # process (the seam-1 shape #8's specs build on). #8 adds the behavioral specs
  # that mock outside-world commands (brew, curl, …) on this entrypoint.
  It 'runs as an external process and prints its name'
    When run script "$CLI_SETUP_ROOT/bin/cli-setup"
    The output should equal "cli-setup"
    The status should be success
  End
End
