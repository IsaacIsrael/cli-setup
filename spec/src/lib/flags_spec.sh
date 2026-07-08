Describe 'flag_enabled'
  # Seam 2: the flag resolver is tested directly; curl is mocked at the
  # boundary. Bootstrap + vendored jq come from spec_helper (just test runs install --vendor).
  # Manifest contract: see spec_helper.sh (preserve → stage → restore).
  flags_lib="$SHELLSPEC_PROJECT_ROOT/src/lib/flags.sh"

  Mock curl
    false
  End

  setup_watchman_off_v123() {
    stage_file "flags.json" '{"watchman":{"state":"off","since":"1.3.0"}}'
    stage_file "VERSION" "1.2.3"
  }

  setup_watchman_off_v123_opt_in() {
    export CLI_SETUP_FF_WATCHMAN=1
    setup_watchman_off_v123
  }

  setup_watchman_on_v200_opt_out() {
    export CLI_SETUP_FF_WATCHMAN=off
    stage_file "flags.json" '{"watchman":{"state":"on","since":"1.0.0"}}'
    stage_file "VERSION" "2.0.0"
  }

  setup_watchman_on_v123() {
    stage_file "flags.json" '{"watchman":{"state":"on","since":"1.3.0"}}'
    stage_file "VERSION" "1.2.3"
  }

  setup_watchman_on_v130() {
    stage_file "flags.json" '{"watchman":{"state":"on","since":"1.3.0"}}'
    stage_file "VERSION" "1.3.0"
  }

  setup_watchman_off_dev() {
    clear_path "VERSION"
    stage_file "flags.json" '{"watchman":{"state":"off","since":"1.3.0"}}'
  }

  setup_watchman_on_v200() {
    stage_file "flags.json" '{"watchman":{"state":"on","since":"1.0.0"}}'
    stage_file "VERSION" "2.0.0"
  }

  setup_watchman_off_v150() {
    stage_file "flags.json" '{"watchman":{"state":"off","since":"1.3.0"}}'
    stage_file "VERSION" "1.5.0"
  }

  setup_watchman_on_v129() {
    stage_file "flags.json" '{"watchman":{"state":"on","since":"1.3.0"}}'
    stage_file "VERSION" "1.2.9"
  }

  setup_watchman_off_v123_opt_in_true() {
    export CLI_SETUP_FF_WATCHMAN=true
    setup_watchman_off_v123
  }

  setup_watchman_on_v200_opt_out_false() {
    export CLI_SETUP_FF_WATCHMAN=false
    stage_file "flags.json" '{"watchman":{"state":"on","since":"1.0.0"}}'
    stage_file "VERSION" "2.0.0"
  }

  BeforeEach 'preserve_path "flags.json"'
  BeforeEach 'preserve_path "VERSION"'
  BeforeEach "source \"$flags_lib\""
  BeforeEach 'clear_path "kill-switch.cache.json"'
  AfterEach 'restore_path "flags.json"'
  AfterEach 'restore_path "VERSION"'

  Describe 'unknown flags'
    It 'does not enable a flag missing from the manifest'
      stage_file "flags.json" '{}'
      When call flag_enabled watchman
      The status should be failure
    End

    It 'does not enable when the manifest file is absent'
      clear_path "flags.json"
      When call flag_enabled watchman
      The status should be failure
    End
  End

  Describe 'feature visibility to the end user'
    It 'does not enable a feature that is not ready yet'
      setup_watchman_off_v123
      When call flag_enabled watchman
      The status should be failure
    End

    Describe 'when the user opts in via env'
      BeforeEach setup_watchman_off_v123_opt_in

      It 'enables a not-yet-default feature'
        When call flag_enabled watchman
        The status should be success
      End

      Describe 'with the true alias'
        BeforeEach setup_watchman_off_v123_opt_in_true

        It 'enables a not-yet-default feature'
          When call flag_enabled watchman
          The status should be success
        End
      End
    End

    Describe 'when the user opts out via env'
      BeforeEach setup_watchman_on_v200_opt_out

      It 'disables an otherwise-enabled feature'
        When call flag_enabled watchman
        The status should be failure
      End

      Describe 'with the false alias'
        BeforeEach setup_watchman_on_v200_opt_out_false

        It 'disables an otherwise-enabled feature'
          When call flag_enabled watchman
          The status should be failure
        End
      End
    End

    Describe 'when the manifest still marks the feature off'
      BeforeEach setup_watchman_off_v150

      It 'does not enable even after the since version has passed'
        When call flag_enabled watchman
        The status should be failure
      End
    End

    Describe 'when the installed version predates the feature'
      BeforeEach setup_watchman_on_v123

      It 'does not enable the feature'
        When call flag_enabled watchman
        The status should be failure
      End

      Describe 'on a hotfix line below the opening minor'
        BeforeEach setup_watchman_on_v129

        It 'does not enable the feature'
          When call flag_enabled watchman
          The status should be failure
        End
      End
    End

    Describe 'when the installed version reaches the feature opening'
      BeforeEach setup_watchman_on_v130

      It 'enables the feature automatically'
        When call flag_enabled watchman
        The status should be success
      End
    End
  End

  Describe 'developer experience'
    BeforeEach setup_watchman_off_dev

    It 'enables in-progress features in a source checkout without configuration'
      When call flag_enabled watchman
      The status should be success
    End
  End

  Describe 'maintainer remote control'
    kill_cache() {
      printf '%s/kill-switch.cache.json\n' "$CLI_SETUP_ROOT"
    }

    BeforeEach 'clear_path "kill-switch.cache.json"'
    BeforeEach setup_watchman_on_v200

    It 'disables a live feature when the maintainer lists it remotely'
      printf '%s\n' '{"disabled":["watchman"]}' >"$(kill_cache)"
      When call flag_enabled watchman
      The status should be failure
    End

    It 'overrides a user opt-in when the maintainer disables the feature remotely'
      printf '%s\n' '{"disabled":["watchman"]}' >"$(kill_cache)"
      export CLI_SETUP_FF_WATCHMAN=1
      When call flag_enabled watchman
      The status should be failure
    End

    Describe 'when the remote list is unreachable'
      It 'keeps working on the last known kill-switch state'
        printf '%s\n' '{"disabled":["watchman"]}' >"$(kill_cache)"
        When call flag_enabled watchman
        The status should be failure
      End

      It 'falls back to local rules when nothing is cached'
        When call flag_enabled watchman
        The status should be success
      End
    End

    Describe 'when the remote list is fetched successfully'
      Mock curl
        while [ $# -gt 0 ]; do
          case "$1" in
            -o) dest="$2"; shift 2 ;;
            *) shift ;;
          esac
        done
        printf '%s\n' '{"disabled":["watchman"]}' >"$dest"
      End

      It 'disables a live feature from the fresh remote payload'
        When call flag_enabled watchman
        The status should be failure
      End
    End

    Describe 'fetch-once guard'
      curl_counter="$SHELLSPEC_TMPBASE/curl-call-count"

      Mock curl
        printf '.\n' >>"$SHELLSPEC_TMPBASE/curl-call-count"
        false
      End

      It 'fetches the kill switch at most once across multiple flag checks'
        rm -f "$curl_counter"
        When call eval 'flag_enabled watchman; flag_enabled other_flag; true'
        The contents of file "$curl_counter" should equal "."
      End
    End
  End
End
