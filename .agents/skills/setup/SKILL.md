---
name: setup
description: Post-clone bootstrap — wire Cursor rule symlinks, install the dev toolchain (Homebrew + `just setup`), and install the recommended editor extensions.
disable-model-invocation: true
---

# Setup

Post-clone bootstrap. Three independent concerns: wire the Cursor rule symlinks,
install the dev toolchain, and install the recommended editor extensions. Do all
three (Part C is optional — skip it silently when no editor CLI is present).

## Part A — Cursor rule symlinks

After clone, `.cursor/rules/` is gitignored. Cursor discovers rules there; the source of truth is `.agents/rules/`. This creates the symlinks.

See [`.agents/docs/layout.md`](../docs/layout.md).

### A1. Verify sources

List every `.mdc` in `.agents/rules/`.

If the directory is missing or empty, stop and tell the user — nothing to link.

### A2. Create symlinks

From the repo root:

```bash
mkdir -p .cursor/rules

for rule in .agents/rules/*.mdc; do
  name="$(basename "$rule")"
  target="../../.agents/rules/$name"
  link=".cursor/rules/$name"

  if [ -L "$link" ]; then
    if [ "$(readlink "$link")" = "$target" ]; then
      echo "ok: $link"
    else
      ln -sf "$target" "$link"   # our own symlink, wrong target — safe to repoint
      echo "relinked: $link -> $target"
    fi
  elif [ -e "$link" ]; then
    echo "conflict: $link exists and is not a symlink — leaving it untouched" >&2
  else
    ln -s "$target" "$link"
    echo "linked: $link -> $target"
  fi
done
```

The script never overwrites a **regular file**: if one already sits where a symlink should go, it prints `conflict:` and leaves it untouched. When you see a conflict, stop and ask the user before removing it — never delete it automatically. (A stale symlink of ours pointing at the wrong target is safe, so the script just repoints it.)

### A3. Verify

**Completion criterion:** for every `.agents/rules/*.mdc`, `.cursor/rules/<same-name>` is a symlink whose target is `../../.agents/rules/<same-name>`.

Report the linked set. Remind the user that edits belong in `.agents/rules/`, not `.cursor/rules/`.

## Part B — Dev toolchain

Install the tools the project builds with. The toolchain is declared in the [`Brewfile`](../../../Brewfile); the `just setup` recipe in the [`justfile`](../../../justfile) installs it and wires the git hooks. Because `just` itself comes from the `Brewfile`, bootstrap its prerequisites first (Homebrew, then `just`), then hand off to the recipe.

### B1. Ensure Homebrew

If `brew` is not on PATH, install it and source the arch-aware prefix so it is usable in the current shell:

```bash
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for prefix in /opt/homebrew /usr/local; do
    if [ -x "$prefix/bin/brew" ]; then
      eval "$("$prefix/bin/brew" shellenv)"
      break
    fi
  done
fi
```

### B2. Install `just`, then run `just setup`

`just setup` installs the rest of the `Brewfile` toolchain and wires the git hooks, but it needs `just` present to run:

```bash
brew install just
just setup
```

`just setup` is idempotent (`brew bundle` + `lefthook install` both no-op when already satisfied), so it is safe to re-run.

### B3. Verify

**Completion criterion:** `just --list` shows the recipes and the git hooks are wired (`.git/hooks/commit-msg` exists). Report the toolchain as bootstrapped.

## Part C — Editor extensions (optional; Cursor / VS Code)

The recommended extensions live in [`.vscode/extensions.json`](../../../.vscode/extensions.json) — the editor only *prompts* to install them on open. This step installs them non-interactively for whoever bootstraps from the CLI, and pins the one version that matters. Editor extensions are a convenience that mirrors the CLI gates (ShellCheck, and shfmt via `.editorconfig`); they are **not** part of the project toolchain (ADR 0002), so this part is best-effort and skipped when no editor CLI is present.

### C1. Install (only if an editor CLI exists)

Prefer the Cursor CLI, fall back to VS Code's `code`. If neither is on PATH, skip — the extensions are optional.

```bash
editor_cli=""
for c in cursor code; do
  command -v "$c" >/dev/null 2>&1 && editor_cli="$c" && break
done

if [ -z "$editor_cli" ]; then
  echo "no 'cursor'/'code' CLI found — skipping editor extensions (optional)"
else
  "$editor_cli" --install-extension timonwong.shellcheck --force
  "$editor_cli" --install-extension EditorConfig.EditorConfig --force
  # Pin 7.2.2: shell-format 7.2.8 ships a broken package (missing
  # dist/one_ini_bg.wasm) that fails to activate, so no shellscript formatter
  # gets registered. See .vscode/extensions.json and CONTRIBUTING.md.
  "$editor_cli" --install-extension foxundermoon.shell-format@7.2.2 --force
fi
```

The pin only sets the correct *starting* version — it does not stop the editor from auto-updating shell-format back to the broken 7.2.8. Tell the user to turn off "Auto Update" for that extension (see [`CONTRIBUTING.md`](../../../CONTRIBUTING.md)). When upstream ships a fixed release, drop the `@7.2.2` pin here and the matching notes in `.vscode/extensions.json` and `CONTRIBUTING.md`.

### C2. Verify

**Completion criterion:** when an editor CLI is present, `<cli> --list-extensions --show-versions` lists `foxundermoon.shell-format@7.2.2`, `EditorConfig.EditorConfig`, and `timonwong.shellcheck`. When no editor CLI is present, report the step as skipped.
