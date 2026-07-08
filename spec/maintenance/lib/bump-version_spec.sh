Describe 'maintenance/lib/bump-version.sh'
  # Decides the release version (ADR 0010). cog/git are the outside world, so
  # they are mocked here (seam-1 convention); the spec asserts the version the
  # script prints, not how it calls cog.
  #
  #   bump-version.sh feature   # cog --auto, floored to at least a minor (D1);
  #                             #   exits non-zero when nothing is releasable
  #   bump-version.sh hotfix    # cog --patch
  bump="$SHELLSPEC_PROJECT_ROOT/maintenance/lib/bump-version.sh"

  Describe 'feature mode'
    It 'prints the minor version cog computes (no floor needed)'
      Mock cog
        case "$1 $2" in
          "bump --auto") echo v0.1.0 ;;
        esac
      End
      Mock git
        : # no tags
      End
      When run script "$bump" feature
      The output should equal "0.1.0"
      The status should be success
    End

    It 'floors a patch-only bump to a minor on the very first release'
      Mock cog
        case "$1 $2" in
          "bump --auto") echo v0.0.1 ;;
          "bump --minor") echo v0.1.0 ;;
        esac
      End
      Mock git
        : # no tags
      End
      When run script "$bump" feature
      The output should equal "0.1.0"
    End

    It 'floors a patch bump that shares the latest tag major.minor'
      Mock cog
        case "$1 $2" in
          "bump --auto") echo v1.2.1 ;;
          "bump --minor") echo v1.3.0 ;;
        esac
      End
      Mock git
        echo v1.2.0
      End
      When run script "$bump" feature
      The output should equal "1.3.0"
    End

    It 'keeps a bump that already raised the minor or major'
      Mock cog
        case "$1 $2" in
          "bump --auto") echo v2.0.0 ;;
        esac
      End
      Mock git
        echo v1.2.0
      End
      When run script "$bump" feature
      The output should equal "2.0.0"
    End

    It 'signals nothing-releasable with a non-zero status'
      Mock cog
        case "$1 $2" in
          "bump --auto") exit 1 ;;
        esac
      End
      Mock git
        :
      End
      When run script "$bump" feature
      The status should be failure
    End
  End

  Describe 'hotfix mode'
    It 'prints the patch version cog forces'
      Mock cog
        case "$1 $2" in
          "bump --patch") echo v1.2.1 ;;
        esac
      End
      When run script "$bump" hotfix
      The output should equal "1.2.1"
      The status should be success
    End
  End
End
