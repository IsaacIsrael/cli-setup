Describe 'semver_gte'
  # Seam 2: pure lib — version comparison for flag gating and release logic.
  BeforeEach "source \"$SHELLSPEC_PROJECT_ROOT/src/lib/semver.sh\""

  It 'treats equal versions as satisfying >='
    When call semver_gte 1.3.0 1.3.0
    The status should be success
  End

  It 'reports failure when the left version is older'
    When call semver_gte 1.2.3 1.3.0
    The status should be failure
  End

  It 'reports success when the left version is newer'
    When call semver_gte 2.0.0 1.3.0
    The status should be success
  End

  It 'compares numeric patch segments, not strings'
    When call semver_gte 1.10.0 1.9.0
    The status should be success
  End
End
