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
│   ├── lib/             # shared Bash helpers sourced at runtime
│   │   ├── (log)        # tee + verbosity routing over gum (spin/log/table/style)
│   │   ├── (semver)     # awk-based version comparison (no reliable `sort -V` on macOS)
│   │   └── (graph)      # dependency-graph / topological-order resolution
│   ├── tools/           # tools as plugins (ADR 0004)
│   │   └── <id>/
│   │       ├── tool.json  # metadata: id, dependencies, blocking, version policy, exports, install kind, gui, duration hint
│   │       └── tool.sh    # exposes `check` and `install`
│   └── profiles/        # profiles as selections (ADR 0005)
│       └── <id>.json    # lists tool ids; the core resolves the dependency graph
├── spec/                # ShellSpec tests (not installed)
├── docs/                # mdBook documentation site source (not installed)
├── maintenance/         # repo tooling scripts (not installed) — e.g. lint.sh, which finds the shell files and runs the ShellCheck gate
│   └── lib/             # release build blocks composed by `just build` (bump-version, release-notes, package) — ADR 0010
└── install.sh           # curl-able installer; copies src/ into ~/.cli-setup, vendors gum + jq, symlinks the entrypoint (later slice)
```

`maintenance/` holds scripts that operate on the repo itself (linting, CI helpers)
rather than shipping to the user — so it stays outside `src/` (the installable
payload), alongside `spec/` and `docs/`.

## Layer responsibilities

| Layer | Responsibility |
| --- | --- |
| `src/bin/cli-setup` | Parse the subcommand + flags and dispatch to a handler. No business logic. |
| `src/lib/` | Reusable primitives: logging, semver comparison, graph/topological resolution. Pure where possible. |
| `src/tools/<id>` | Self-contained knowledge to `check` and `install` one tool. Added without touching the core. |
| `src/profiles/<id>.json` | Declarative list of tool ids. Built without touching the resolver. |

## Test seams

Tests live in `spec/` and target two seams (see the PRD's testing decisions):

1. **CLI end-to-end** — invoke `src/bin/cli-setup <subcommand>` with external
   commands (`brew`, `curl`, `rbenv`, `nvm`, `gem`, `sdkmanager`, `xcodes`, …)
   mocked. Assert observable behavior: status/table output, plan preview,
   `--dry-run` applies nothing, exit codes, managed `~/.zshrc` block content,
   log written, idempotent re-run, skip-with-reason on blocking failure.
2. **Pure functions in `lib`** — semver comparison and dependency-graph /
   topological resolution, tested directly with no side effects.

Prefer the highest seam: each tool's `check`/`install` is exercised through
seam 1 with mocked externals.

## Conventions

- Bash 3.2 compatible (macOS system Bash) — no `declare -A` or Bash 4+ features.
- Tool and profile contracts are JSON, read with the vendored `jq` (ADR 0004).
- Directories currently hold `.gitkeep` placeholders until their slices land.
