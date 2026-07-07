# `cli-setup --version`

```bash
cli-setup --version
```

Prints the installed version and exits.

- The version is materialized on your machine by the installer from the released
  tag (see [ADR 0010](https://github.com/IsaacIsrael/cli-setup/blob/main/.agents/docs/adr/0010-ci-cd-strategy.md)).
  In a source checkout without that file, it prints the sentinel `0.0.0-dev`.
- Exit code: `0`.
