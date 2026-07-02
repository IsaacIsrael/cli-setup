---
name: setup
description: Post-clone bootstrap — wire Cursor rule symlinks and install the dev toolchain (Homebrew + `just setup`).
disable-model-invocation: true
---

# Setup

Post-clone bootstrap. Two independent concerns: wire the Cursor rule symlinks,
and install the dev toolchain. Do both.

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
