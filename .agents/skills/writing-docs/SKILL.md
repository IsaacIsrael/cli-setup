---
name: writing-docs
description: Author or update a documentation page in the right home with the right shape. Use when writing or updating docs, adding a concept page, a how-to guide, or a command reference, or deciding where a doc belongs.
---

# Writing docs

Author docs so they land in the right home and carry the right contents. The content map and the source-of-truth principle live in the `documentation` rule ([`.agents/rules/documentation.mdc`](../../rules/documentation.mdc)); this skill is *how* to write a page once you know it is needed.

## Steps

1. **Choose the home.** Apply the content map in the `documentation` rule by audience (README / CONTRIBUTING / docs site / `.agents/docs`). If the fact already lives somewhere, link to it — never copy. A domain term's home is `CONTEXT.md`; the site may carry a user-facing rendition that must not contradict it.
2. **Choose the type** and use its template below: concept page, how-to guide, or command reference.
3. **Draft against the template** and clear that type's checklist.
4. **Register and build.** Add the page to the mdBook [`SUMMARY.md`](../../../docs/src/SUMMARY.md) and run `just docs`. Done when it builds and the checklist passes.

## Templates

### Concept page (docs site)

Explains one idea to a CLI user.

- One-sentence definition, consistent with `CONTEXT.md`.
- Why it exists / the problem it addresses.
- How it relates to neighbouring concepts (link them).

Checklist: definition matches `CONTEXT.md`; no implementation detail; siblings linked; no glossary copy left in the README.

### How-to guide (docs site)

Walks a user through one task.

- Goal — one line stating what the reader will achieve.
- Prerequisites.
- Numbered steps, each with the exact command.
- Result and how to verify it.

Checklist: task-focused (not reference); every command is copy-pasteable; the end state is verifiable.

### Command reference (docs site)

Structure: an index page (`commands.md`) covering the global flags, plus **one page per implemented command** under `commands/<cmd>.md`. Add a command's own page when it lands.

Each command/flag entry has:

- Invocation (`cli-setup …`).
- What it does.
- Options / flags.
- Exit codes and observable output.

Checklist: entries match the code in [`src/bin/cli-setup`](../../../src/bin/cli-setup) and its specs; implemented behavior is documented as working; exit codes stated.
