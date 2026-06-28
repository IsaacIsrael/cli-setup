---
name: setup
description: Wire Cursor rule symlinks after clone — link `.cursor/rules/` to `.agents/rules/`.
disable-model-invocation: true
---

# Setup

After clone, `.cursor/rules/` is gitignored. Cursor discovers rules there; the source of truth is `.agents/rules/`. This skill creates the symlinks.

See [`.agents/docs/layout.md`](../docs/layout.md).

## 1. Verify sources

List every `.mdc` in `.agents/rules/`.

If the directory is missing or empty, stop and tell the user — nothing to link.

## 2. Create symlinks

From the repo root:

```bash
mkdir -p .cursor/rules

for rule in .agents/rules/*.mdc; do
  name="$(basename "$rule")"
  target="../../.agents/rules/$name"
  link=".cursor/rules/$name"

  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    echo "ok: $link"
  else
    ln -sf "$target" "$link"
    echo "linked: $link -> $target"
  fi
done
```

If a path at `.cursor/rules/$name` exists and is **not** a symlink to the expected target, stop and ask the user before overwriting.

## 3. Verify

**Completion criterion:** for every `.agents/rules/*.mdc`, `.cursor/rules/<same-name>` is a symlink whose target is `../../.agents/rules/<same-name>`.

Report the linked set. Remind the user that edits belong in `.agents/rules/`, not `.cursor/rules/`.
