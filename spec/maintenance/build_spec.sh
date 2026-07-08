Describe 'maintenance/build.sh'
  # Integration seam for `just build`: it composes the real maintenance/lib
  # scripts, so only the outside world (cog/gh/git) is mocked — declared per
  # mode so every example in the mode shares them. Assertions are on the
  # artifacts build produces (the asset, src/VERSION, src/CHANGELOG.md), not on
  # how the lib scripts are called. build writes src/VERSION and src/CHANGELOG.md
  # in the real working tree (gitignored); the hook drops them so it stays clean.
  build="$SHELLSPEC_PROJECT_ROOT/maintenance/build.sh"

  AfterEach 'clear_path "VERSION"; clear_path "CHANGELOG.md"'

  # Build in a throwaway CWD so the dist/ asset lands there, not in the repo.
  BeforeEach "cd \"$SHELLSPEC_TMPBASE\""

  Describe 'feature mode'
    Mock cog
      case "$1" in
        bump)
          case "$2" in
            --auto) echo v0.1.0 ;;
            --minor) echo v0.1.0 ;;
          esac
          ;;
        changelog)
          echo "#### Features"
          echo "- (**cli**) do a thing - (abc1234) - X"
          ;;
      esac
    End
    Mock git
      : # no tags
    End
    Mock gh
      : # no published releases
    End

    It 'builds the versioned asset for the resolved version'
      When run script "$build" feature
      The status should be success
      The path "dist/cli-setup-0.1.0.tar.gz" should be file
    End

    It 'writes the release notes to src/CHANGELOG.md'
      "$build" feature
      When run cat "$SHELLSPEC_PROJECT_ROOT/src/CHANGELOG.md"
      The output should include "do a thing"
    End

    It 'materializes the version at src/VERSION for the workflow to read back'
      "$build" feature
      When run cat "$SHELLSPEC_PROJECT_ROOT/src/VERSION"
      The output should equal "0.1.0"
    End

    It 'signals nothing-releasable with a non-zero status'
      Mock cog
        case "$1" in
          bump)
            case "$2" in
              --auto) exit 1 ;;
            esac
            ;;
        esac
      End
      When run script "$build" feature
      The status should be failure
    End
  End

  Describe 'hotfix mode'
    Mock cog
      case "$1" in
        bump)
          case "$2" in
            --patch) echo v1.2.1 ;;
          esac
          ;;
        changelog)
          echo "#### Bug Fixes"
          echo "- (**cli**) fix the crash - (aaaa111) - X"
          ;;
      esac
    End
    Mock gh
      case "$1 $2" in
        "pr view") printf 'aaaa111\nbbbb222\n' ;;
      esac
    End
    Mock git
      case "$1" in
        rev-parse) exit 0 ;;
      esac
    End

    It 'builds the patch asset and PR-scoped notes'
      When run script "$build" hotfix 42
      The status should be success
      The path "dist/cli-setup-1.2.1.tar.gz" should be file
    End
  End
End
