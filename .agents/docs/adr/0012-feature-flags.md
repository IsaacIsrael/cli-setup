# Feature flags for trunk-based development

Trunk-based development means incomplete work merges to `main` dormant behind flags. We add a native feature-flag mechanism: a committed JSON manifest at `src/flags.json` declares each flag's `state` (`on`/`off`) and the `since` version it opens at; a Bash resolver (`flag_enabled` in `src/lib/flags.sh`) decides on/off at runtime; and a public gist kill switch can force flags off without blocking the CLI when the network is unavailable.

**Precedence** (top wins):

1. Remote kill switch (OFF only)
2. Env var `CLI_SETUP_FF_<FLAG>` (`1`/`true`/`on` → on; `0`/`false`/`off` → off; unset → pass)
3. Dev (`0.0.0-dev` / no `VERSION`) → on
4. `state == "on"` AND installed version `>= since` → on
5. else off

**Activation model:** incomplete work lands as `chore(<flag>)` / `refactor(<flag>)` (omitted from the changelog). The enable commit is `feat(<flag>): …` with an `Enables: <flag>` git trailer in the same PR that flips `state` to `on` and sets `since` to the next minor. Because hotfixes bump only the patch, `installed >= since(minor)` is false on hotfix lines, so a feature never leaks through a hotfix.

**Kill switch:** a baked-in public gist raw URL (overridable via `CLI_SETUP_KILL_SWITCH_URL`) serves `{ "disabled": ["<flag>", …] }`. The resolver best-effort fetches with `curl --max-time 2`, caches the last-good copy at `<install-root>/kill-switch.cache.json` (alongside `VERSION` and `flags.json` under `~/.cli-setup` in production), and never blocks on failure — worst case is disabling features if the URL is compromised.

**Changelog:** `release-notes.sh` scans the release range for `Enables:` trailers and appends a `#### Feature enables` section alongside cog's `feat`/`fix` output.

## Considered Options

- **Hosted flag SaaS** (LaunchDarkly, Flagsmith, Unleash, …): rejected — conflicts with ADR 0002 (no Node, offline-first via curl, no secret in a public CLI).
- **`next` sentinel + post-publish concretize + CI validation**: rejected — explicit `state` + `since` is simpler, forget-proof, and hotfix-safe.
- **Per-commit "Pending" accumulation + carry-forward marker**: rejected — unnecessary once activation is a single `feat` + `Enables:` commit.
- **Custom `enable` commit type**: rejected — would require commit-lint and rule changes; `feat` + trailer reuses existing tooling.
- **User-installed `jq` on PATH**: rejected — runtime JSON uses vendored `jq` at `<root>/vendor/jq` (ADR 0004), populated by `just install` / `just install --vendor`, gitignored like `node_modules`.

## Consequences

- Incomplete features can merge to `main` without affecting users until the enable commit and version gate align.
- The kill switch is off-only; remote enable/rollout and user-facing flag registries are out of scope.
- `src/vendor/` is gitignored and populated from `# vendor-meta` lines in the `Brewfile` by `maintenance/lib/sync-vendors.sh` (invoked by `maintenance/install.sh` via `just install`, `just install --vendor`, `just install --update`). `just build` calls `install.sh --vendor --macos` before packaging. Runtime access goes through `src/vendor/vendor_exec.sh` (`vendor_exec`) and per-library wrappers like `jq.sh`.
- `src/boot/` provides one-time runtime bootstrap (`bootstrap.sh` → `source_lib` → `resolve_root`); the entrypoint and test harness source it before loading `src/lib/flags.sh`.
- Maintainers replace the placeholder kill-switch URL before relying on remote disable in production.

Refs: ADR 0010 (trunk-based releases and non-releasable commit types).
