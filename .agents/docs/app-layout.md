# Application layout

How the `cli-setup` application source is organized. This is the *application*
layout; the agent workspace layout (`AGENTS.md`, `.agents/`) is documented
separately in [`layout.md`](layout.md).

The guiding principle: **`src/` is the installable payload** — everything that
ends up on the user's machine (under `~/.cli-setup`) lives in `src/`. Tests,
docs, and repo metadata stay outside it.

```
/
├── src/                 # the installable CLI — everything shipped to ~/.cli-setup
│   ├── bin/
│   │   └── cli-setup    # single entrypoint / command dispatcher (symlinked onto PATH)
│   ├── boot/            # runtime infrastructure — sourced once at startup (Ruby-style boot)
│   │   ├── bootstrap.sh # idempotent one-time init; loads source_lib + root
│   │   ├── source_lib.sh# module loader: boot/, lib/, or <root>/<pkg>/index.sh
│   │   └── root.sh      # resolve_root — install-root discovery (CLI_SETUP_ROOT override)
│   ├── lib/             # application helpers loaded via source_lib
│   │   ├── semver.sh    # awk-based version comparison (no reliable `sort -V` on macOS)
│   │   ├── version.sh   # installed_version — reads <root>/VERSION or dev sentinel
│   │   ├── flags.sh     # flag_enabled resolver (ADR 0012)
│   │   ├── help.sh      # usage text for --help
│   │   ├── (log)        # tee + verbosity routing over gum (spin/log/table/style)
│   │   └── (graph)      # dependency-graph / topological-order resolution
│   ├── vendor/          # vendored runtime binaries (gitignored except vendor_exec.sh)
│   │   ├── vendor_exec.sh # _vendor_path / vendor_exec plumbing
│   │   ├── <formula>.sh # generated wrapper per library (e.g. jq.sh defines jq())
│   │   └── <formula>    # prebuilt binaries (jq, …) — populated by sync-vendors.sh
│   ├── flags.json       # feature-flag manifest: state + since per flag (ADR 0012)
│   ├── tools/           # tools as plugins (ADR 0004)
│   │   └── <id>/
│   │       ├── tool.json  # metadata: id, dependencies, blocking, version policy, exports, install kind, gui, duration hint
│   │       └── tool.sh    # exposes `check` and `install`
│   └── profiles/        # profiles as selections (ADR 0005)
│       └── <id>.json    # lists tool ids; the core resolves the dependency graph
├── spec/                # ShellSpec tests (not installed) — mirrors the repo root: spec/src/** covers the app, spec/maintenance/** covers repo tooling
├── docs/                # mdBook documentation site source (not installed)
├── maintenance/         # repo tooling scripts (not installed) — e.g. lint.sh, which finds the shell files and runs the ShellCheck gate
│   ├── install.sh       # brew bundle + vendor sync + lefthook (just install)
│   └── lib/             # release build blocks composed by `just build` — ADR 0010
│       ├── sync-vendors.sh  # declarative vendor sync from Brewfile vendor-meta
│       ├── bump-version.sh
│       ├── release-notes.sh
│       └── package.sh
└── install.sh           # curl-able installer; copies src/ into ~/.cli-setup, vendors gum + jq, symlinks the entrypoint (later slice)
```

`maintenance/` holds scripts that operate on the repo itself (linting, CI helpers)
rather than shipping to the user — so it stays outside `src/` (the installable
payload), alongside `spec/` and `docs/`.

## Layer responsibilities

| Layer | Responsibility |
| --- | --- |
| `src/bin/cli-setup` | Parse the subcommand + flags and dispatch to a handler. Sources `boot/bootstrap.sh` once, then loads libs via `source_lib`. No business logic. |
| `src/boot/` | Runtime infrastructure: idempotent bootstrap, install-root resolution, module loading. Sourced once from the entrypoint and the test harness. |
| `src/lib/` | Application helpers: semver, version, flags, help, logging, graph resolution. Loaded on demand via `source_lib`. Pure where possible. |
| `src/vendor/` | Vendored runtime binaries and per-library wrappers (`jq.sh` → `jq()`, …). Populated by `maintenance/lib/sync-vendors.sh`; gitignored like `node_modules`. |
| `src/flags.json` | Committed flag manifest (`state`, `since`). Read by `flag_enabled` in `src/lib/flags.sh`. |
| `src/tools/<id>` | Self-contained knowledge to `check` and `install` one tool. Added without touching the core. |
| `src/profiles/<id>.json` | Declarative list of tool ids. Built without touching the resolver. |

## Test seams

Tests live in `spec/`, which mirrors the repo root one-to-one: a test sits at the
same path as what it covers, prefixed by `spec/` (e.g. `src/bin/cli-setup` →
`spec/src/bin/cli-setup_spec.sh`, `maintenance/lib/package.sh` →
`spec/maintenance/lib/package_spec.sh`). This also draws the boundary that
matters: `spec/src/**` covers the shipped application, while `spec/maintenance/**`
covers repo tooling that never ships.

The application tests target two seams (see the PRD's testing decisions):

1. **CLI end-to-end** — invoke `src/bin/cli-setup <subcommand>` with external
   commands (`brew`, `curl`, `rbenv`, `nvm`, `gem`, `sdkmanager`, `xcodes`, …)
   mocked. Assert observable behavior: status/table output, plan preview,
   `--dry-run` applies nothing, exit codes, managed `~/.zshrc` block content,
   log written, idempotent re-run, skip-with-reason on blocking failure.
2. **Pure functions and deep modules in `lib` / `boot` / `vendor`** — semver
   comparison, flag resolution, install-root discovery, and vendor execution,
   tested directly with external commands (`curl`, `brew`) mocked at the boundary.

Prefer the highest seam: each tool's `check`/`install` is exercised through
seam 1 with mocked externals.

## Conventions

- Bash 3.2 compatible (macOS system Bash) — no `declare -A` or Bash 4+ features.
- Tool and profile contracts are JSON, read with the vendored `jq` (ADR 0004).
- Directories currently hold `.gitkeep` placeholders until their slices land.
