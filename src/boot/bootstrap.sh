#!/usr/bin/env bash
# Runtime boot — source once from bin/cli-setup and spec/spec_helper.sh.
set -euo pipefail

[ -n "${_CLI_SETUP_BOOTSTRAPPED:-}" ] && return 0
_CLI_SETUP_BOOTSTRAPPED=1

# shellcheck source=source_lib.sh
source "$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)/source_lib.sh"
source_lib boot/root
