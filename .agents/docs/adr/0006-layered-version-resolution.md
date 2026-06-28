# Layered version resolution with optional team config (config dist)

Tool versions resolve by precedence, strongest to weakest: CLI flag > project version file (`.nvmrc`/`.ruby-version`/…) > team config > profile override > tool default. On a project×team conflict, `setup` lets the **project win** while `doctor` flags the drift and `update` reconciles to the team standard. The team config is a JSON document fetched from a URL (config dist) — not a git clone — optional at install (`--team-config <url>`) and configurable later; it may also customize a profile (`add`/`remove`/`versions`), restricted to built-in tools for now.

## Considered Options

- **Team config overrides the project**: rejected — it would break the project a developer is currently working on; surfacing drift (and reconciling on demand) is safer than silent override.
- **Git clone for team config**: rejected in favor of a single JSON over HTTP (simpler, no working copy, cache + refresh).

## Consequences

- Custom team tools with externally supplied definitions are out of scope until a trust/execution model exists, because the team config would be running `check`/`install` code we don't ship.
