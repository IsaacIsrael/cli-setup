Describe 'maintenance/lib/release-notes.sh'
  # Writes the release-notes document to src/CHANGELOG.md at the payload root
  # (ADR 0010). cog/gh/git are the outside world and are mocked (seam-1); the
  # spec asserts the notes written to the file, not how the script calls cog.
  # The file lands in the real working tree (gitignored); the hook drops it.
  notes="$SHELLSPEC_PROJECT_ROOT/maintenance/lib/release-notes.sh"
  changelog="$SHELLSPEC_PROJECT_ROOT/src/CHANGELOG.md"

  cleanup() { rm -f "$changelog"; }
  AfterEach 'cleanup'

  Describe 'feature mode'
    It 'emits the changelog when nothing has been hotfixed'
      Mock git
        : # no tags -> full history
      End
      Mock cog
        echo "#### Features"
        echo "- (**cli**) do a thing - (abc1234) - X"
      End
      Mock gh
        : # no published releases
      End
      "$notes" feature
      When run cat "$changelog"
      The output should include "#### Features"
      The output should include "do a thing"
    End

    It "drops cog's version header (the Release title already shows it)"
      Mock git
        : # no tags
      End
      Mock cog
        echo "## Unreleased (b7fdb47..03ace05)"
        echo "#### Features"
        echo "- (**cli**) do a thing - (abc1234) - X"
      End
      Mock gh
        : # no published releases
      End
      "$notes" feature
      When run cat "$changelog"
      The output should not include "## Unreleased"
      The output should include "#### Features"
    End

    It 'drops commits already shipped by a published hotfix'
      Mock git
        : # no tags
      End
      Mock cog
        echo "- (**cli**) keep this - (1111111) - X"
        echo "- (**cli**) shipped by a hotfix - (abc1234) - X"
      End
      Mock gh
        case "$1 $2" in
          "release list") echo "v1.0.1" ;;
          "release view") echo "<!-- cli-setup:shipped-shas abc1234deadbeef -->" ;;
        esac
      End
      "$notes" feature
      When run cat "$changelog"
      The output should include "keep this"
      The output should not include "shipped by a hotfix"
    End
  End

  Describe 'hotfix mode'
    It 'scopes notes to the PR and records the shipped SHAs'
      Mock gh
        case "$1 $2" in
          "pr view") printf 'aaaa111\nbbbb222\n' ;;
        esac
      End
      Mock git
        case "$1" in
          rev-parse) exit 0 ;; # the oldest commit has a parent
        esac
      End
      Mock cog
        echo "#### Bug Fixes"
        echo "- (**cli**) fix the crash - (aaaa111) - X"
      End
      "$notes" hotfix 42
      When run cat "$changelog"
      The output should include "fix the crash"
      The output should include "<!-- cli-setup:shipped-shas aaaa111 bbbb222 -->"
    End

    It "drops cog's version header but keeps the shipped-shas marker"
      Mock gh
        case "$1 $2" in
          "pr view") printf 'aaaa111\n' ;;
        esac
      End
      Mock git
        case "$1" in
          rev-parse) exit 0 ;;
        esac
      End
      Mock cog
        echo "## v1.0.1 (aaaa111..bbbb222)"
        echo "#### Bug Fixes"
        echo "- (**cli**) fix the crash - (aaaa111) - X"
      End
      "$notes" hotfix 42
      When run cat "$changelog"
      The output should not include "## v1.0.1"
      The output should include "fix the crash"
      The output should include "<!-- cli-setup:shipped-shas aaaa111 -->"
    End
  End
End
