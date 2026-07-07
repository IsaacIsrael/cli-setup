# Command reference

`cli-setup` is invoked as:

```bash
cli-setup [command] [options]
```

> **Status:** early development. Only the global flags and the command dispatcher
> are implemented today. Profile commands (`doctor`, `setup`, `update`, `config`)
> are **planned** — see the [roadmap](roadmap.md) — and currently report "not
> implemented". This page documents exactly what works now, and each command is
> added here as it lands.

## Errors

- Unknown option (e.g. `cli-setup --nope`) — prints an error to stderr and
  `Run 'cli-setup --help' for usage.`, then exits `2`.
- Unknown command (e.g. `cli-setup bogus`) — same behavior, exits `2`.
- A planned command that is not implemented yet (e.g. `cli-setup doctor`) —
  reports that it is not implemented yet and exits `2`.
