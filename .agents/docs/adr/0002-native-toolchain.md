# Native, single-binary dev toolchain (no Node)

We build, lint, test, and document cli-setup with native / single-binary tools — ShellCheck, shfmt, ShellSpec, Lefthook, Cocogitto, `just`, mdBook — and vendor `gum` and `jq` as prebuilt binaries, rejecting the Node ecosystem (husky, commitlint, Docusaurus, and friends). We chose this because cli-setup is itself a Bash CLI that must run on a clean macOS without Node; pulling a Node toolchain into the project would contradict the product's own "no Node runtime dependency" promise and add a runtime we otherwise never need.

## Consequences

- The richer JS-ecosystem tooling (and a Go/`lipgloss` TUI) is off the table unless we later accept a build toolchain.
- The dependency surface stays small and the CLI remains installable via `curl` on a bare machine.
