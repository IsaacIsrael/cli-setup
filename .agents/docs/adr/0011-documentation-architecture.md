# Documentation lives by audience, with one source of truth per fact

`cli-setup` keeps four documentation homes, one per audience, and requires every fact to have exactly one canonical home that the others link to rather than copy. The content map:

| Home | Audience | Holds | Does not hold |
| --- | --- | --- | --- |
| `README.md` (root) | GitHub visitor / evaluator ("should I care?") | one-paragraph pitch, status, the hero, one install snippet, a compact command index table (command + one line + status), links out | glossary/concept reference, the full command reference, tutorials |
| `CONTRIBUTING.md` (root) | contributor ("how do I work on this repo?") | toolchain setup, commit/branch conventions, PR flow, local `just` commands, project layout | product/user docs |
| `docs/` → mdBook → Pages | CLI end user ("how do I use it?") | user-facing concepts, command reference, how-to guides, roadmap | internal rationale, ADRs |
| `.agents/docs/` | maintainers + agents | `CONTEXT.md` glossary (the ubiquitous-language source of truth), ADRs, layout, runbooks | end-user tutorials |

The README is deliberately thin and links to the site for deep reference; the site's user-facing concepts page is a rendition of the authoritative `CONTEXT.md` glossary and must not contradict it. We chose this because the repo had begun accumulating the same facts in three places (the `CONTEXT.md` glossary, a README "Core concepts" table, and the site's concepts page) — exactly the duplication that drifts.

Docs are part of "done" only for changes that alter user-facing behavior or the CLI's observable contract. Internal infrastructure, pure refactors, and agent tooling (skills/rules) are exempt — their documentation is the `.agents/` guidance itself, not the user site. This mirrors the non-behavioral exemption the `code-changes` rule already applies to TDD.

The decision is carried by two artifacts plus existing process: an always-applied rule (`.agents/rules/documentation.mdc`) encodes the content map, the source-of-truth principle, and the user-facing-only docs trigger; a `writing-docs` skill provides per-type templates (concept page, how-to, command reference) and a required-contents checklist for *how* to write a page; and the definition-of-done is enforced through the existing issue lifecycle (`/to-issues` adds a docs acceptance criterion for user-facing slices, `/implement` ships the docs, `/code-review`'s Spec axis and `/verify-acceptance` catch omissions) rather than a dedicated CI gate.

## Considered Options

- **Fat README as the primary doc, site secondary**: rejected — the README is the one page every GitHub visitor sees; loading it with the full concept/command reference makes it long and turns it into a second copy of the site, which drifts.
- **Allow intentional duplication (no single-source rule)**: rejected — the three-way glossary copy already showed how fast wording diverges; stopping that is the whole point.
- **Generate the site's concepts page from `CONTEXT.md` at build time**: not now — the cleanest single-source solution, but it needs a parser/generator; recorded as a future option once drift between the two renditions proves painful.
- **A CI gate that fails when `src/` changes without `docs/`**: rejected — too blunt; it cannot tell user-facing changes from internal ones and would nag on exactly the exempt cases. The issue-level acceptance criterion targets the real trigger instead.
- **Rule only (no ADR) / ADR only (no rule)**: rejected — the rule without the ADR loses the rationale and alternatives; the ADR without the rule is not always-applied, so agents would not honor it by default. We keep both.
- **A dedicated `/document` skill vs. folding into existing skills**: chose a `writing-docs` skill for the *how* (templates + checklist) but kept the *whether/when* in the existing issue/implement/review flow, avoiding a parallel process.

## Consequences

- The README shrinks to a pitch that links to the site; deep concept/command content is canonical in `docs/`. Until the first Pages deploy (docs deploy on release, per [ADR 0010](0010-ci-cd-strategy.md)), those README links point at a site that is not yet live — an accepted, temporary wart consistent with the repo's other forward-looking ("Not yet available") sections.
- `CONTEXT.md` stays the authoritative glossary; the site's `concepts.md` must be kept consistent with it by hand until (and unless) generation is adopted. That is a small, watched duplication surface.
- New user-facing behavior now carries a docs obligation as part of its acceptance criteria; internal/agent work does not, keeping the obligation proportional.
- Two new always-on surfaces to maintain — the `documentation.mdc` rule and the `writing-docs` skill — join the existing rule/skill set indexed by `AGENTS.md`.
