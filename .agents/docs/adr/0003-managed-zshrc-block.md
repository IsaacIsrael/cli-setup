# Shell environment changes via a managed `~/.zshrc` block

cli-setup writes all shell environment changes (PATH, `brew shellenv`, `JAVA_HOME`, `ANDROID_HOME`, `rbenv`/`nvm` init, etc.) into a single demarcated, idempotent block in `~/.zshrc` (taking a backup first), rather than printing the lines for the user to paste or appending unmarked lines. We chose this so the changes are reversible and re-runnable without duplicating entries.

## Considered Options

- **Print-only** (tell the user which lines to add): rejected — relies on the user and is not idempotent.
- **Unmarked appends**: rejected — impossible to update or remove cleanly on a later run.
