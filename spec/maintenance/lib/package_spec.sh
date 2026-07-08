Describe 'maintenance/lib/package.sh'
  # Builds the release asset: a .tar.gz of the installable payload (src/) with
  # the version stamped into a bundled VERSION file, matching how
  # src/bin/cli-setup reads <root>/VERSION (ADR 0010). The archive's top-level
  # cli-setup/ mirrors the install root so the installer just extracts it.
  package="$SHELLSPEC_PROJECT_ROOT/maintenance/lib/package.sh"

  # package.sh materializes src/VERSION (gitignored) in the working tree; drop it
  # afterwards so the dev checkout is not left dirty.
  AfterAll 'clear_path "VERSION"; restore_path "vendor"'

  Describe 'the built archive'
    out="$SHELLSPEC_TMPBASE/dist"
    tarball="$out/cli-setup-1.2.3.tar.gz"

    It 'creates a versioned tarball in the output dir'
      When run script "$package" 1.2.3 "$out"
      The status should be success
      The path "$tarball" should be file
    End

    It 'stamps the passed version into cli-setup/VERSION'
      "$package" 1.2.3 "$out" >/dev/null
      When run tar xzf "$tarball" -O cli-setup/VERSION
      The output should equal "1.2.3"
    End

    It 'bundles the installable payload (the entrypoint)'
      "$package" 1.2.3 "$out" >/dev/null
      When run tar tzf "$tarball"
      The output should include "cli-setup/bin/cli-setup"
    End

    It 'bundles vendored runtime binaries when present'
      mkdir -p "$SHELLSPEC_PROJECT_ROOT/src/vendor"
      clear_path "vendor/jq"
      printf '#!/bin/sh\necho vendor-jq\n' >"$SHELLSPEC_PROJECT_ROOT/src/vendor/jq"
      chmod +x "$SHELLSPEC_PROJECT_ROOT/src/vendor/jq"
      "$package" 1.2.3 "$out" >/dev/null 2>&1
      When run tar xzf "$tarball" -O cli-setup/vendor/jq
      The line 1 of output should equal "#!/bin/sh"
    End

    It 'wipes a stale output dir so the build is reproducible'
      mkdir -p "$out"
      : >"$out/cli-setup-9.9.9.tar.gz" # leftover asset from an older version
      "$package" 1.2.3 "$out" >/dev/null
      When run test -e "$out/cli-setup-9.9.9.tar.gz"
      The status should be failure
    End
  End

  Describe 'the working tree'
    # src/bin/cli-setup reads <root>/VERSION, and in a dev checkout <root> is src/;
    # packaging materializes src/VERSION so `just run --version` reflects the built
    # version (ADR 0010). Gitignored — never committed.
    It 'materializes src/VERSION at the payload root'
      "$package" 4.5.6 "$SHELLSPEC_TMPBASE/dist" >/dev/null
      When run cat "$SHELLSPEC_PROJECT_ROOT/src/VERSION"
      The output should equal "4.5.6"
    End
  End
End
