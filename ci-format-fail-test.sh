#!/usr/bin/env bash
# Throwaway file to prove the CI format-check gate fails on unformatted shell.
# The indentation below is intentionally wrong (over-indented) but the script is
# ShellCheck-clean, so only the format-check gate should fail. Delete this file
# and its branch once the CI failure is confirmed.
set -euo pipefail

greet() {
        echo "hello from an intentionally misformatted script"
}

greet
