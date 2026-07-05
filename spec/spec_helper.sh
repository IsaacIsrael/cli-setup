# ShellSpec harness for cli-setup. Auto-loaded before every spec via .shellspec
# (--require spec_helper). It establishes the seam-1 testing convention from the
# app layout: the CLI is exercised as an external process (`When run script`)
# with its outside-world commands (brew, curl, rbenv, gem, …) replaced by
# ShellSpec `Mock`s, so specs assert observable behavior without touching the
# real system. Adding a new spec needs no changes here.

# Lets specs locate the entrypoint regardless of ShellSpec's working directory:
#   When run script "$CLI_SETUP_ROOT/bin/cli-setup" --version
# shellcheck disable=SC2154  # SHELLSPEC_PROJECT_ROOT comes from the ShellSpec runtime
export CLI_SETUP_ROOT="${SHELLSPEC_PROJECT_ROOT}/src"
