# Glossary — Building Great Rules

The domain model for **persistent guidance**. The root virtue is **Predictability** — defined in [`writing-great-skills`](../writing-great-skills/GLOSSARY.md). This is the disclosed reference for [`writing-great-rules`](SKILL.md).

Terms shared with skills — **context pointer**, **external reference**, **no-op**, **single source of truth**, **duplication**, **sprawl**, **information hierarchy**, **progressive disclosure** — live in [`writing-great-skills`](../writing-great-skills/GLOSSARY.md). Only rule-specific terms are defined here.

**Bold terms** in any definition are themselves defined in this glossary; find them by their heading.

## Scope

How **persistent guidance** is reached — the rule counterpart to a skill's **Invocation** axis.

### Rule

**Persistent guidance** injected into the agent's context without invocation — constraints and conventions, almost always flat **reference**. Shares **predictability** with skills; differs on reach (**scope**, not invocation). Mechanics: [`.agents/rules/*.mdc`](RULES-FORMAT.md) or always-on blocks in `AGENTS.md` / `CLAUDE.md` at the repo root. A multi-step procedure you sometimes skip is a skill, not a rule.

_Avoid_: policy, guideline doc, instruction

### Persistent Guidance

The umbrella for material that shapes agent behaviour without being invoked — **rules** in the narrow sense (`.mdc`, `AGENTS.md` blocks) plus **user rules** in Cursor settings. The skill/rule split is about _shape_: flat constraint vs procedural **steps**.

_Avoid_: system prompt, instructions, context

### Always-On

**Scope** mode — `alwaysApply: true` in `.mdc`, or a block in `AGENTS.md` / `CLAUDE.md` with no glob. The rule body loads every turn. Pays **always-on load**. Reserve for constraints that hold regardless of open files.

_Avoid_: global, universal, alwaysApply

### Glob Trigger

**Scope** via file pattern — the rule loads when matching paths are in context. Escapes **always-on load** for file-type-specific conventions. Its failure mode is **missed guidance**: work outside the pattern never sees the constraint. Widen the glob, promote to **always-on**, or accept the gap — but don't pretend a narrow glob is universal.

_Avoid_: file pattern, path match, conditional rule

### Always-On Load

The cost a rule with **always-on** **scope** imposes — its body (and any co-loaded always-on rules) sit in the context window every turn, spending tokens and attention. Stronger than a **model-invoked** skill's **description** alone, because the rule body loads too. The brake on `alwaysApply: true` and on fat `AGENTS.md` blocks.

_Avoid_: permanent context, baseline noise

### Binding

How checkable a rule's constraint is — can the agent tell compliance from violation? Sharp binding ("never commit unless explicitly asked") resists drift; vague binding ("write clean code") doesn't change behaviour versus the default and is usually a **no-op**.

_Avoid_: enforceability, specificity, actionability

### Missed Guidance

_Failure mode._ The agent works on files outside a **glob trigger**'s pattern and never loads the rule — a constraint that exists but wasn't in context. Cure: widen the glob, split into a narrower **always-on** pointer, or promote to always-on if the constraint is truly universal. Distinct from **no-op** (loaded but ignored) and **duplication** (loaded twice).

_Avoid_: blind spot, scope gap, uncovered files

### Always-On Sprawl

_Failure mode._ Too many **always-on** rules, or bodies too long — **always-on load** compounds until attention thins across noise. Cure: demote file-specific material to **glob trigger**, disclose detail behind **context pointers**, prune **no-ops**, enforce one concern per rule. Distinct from **sprawl** in skills (same length problem, but always-on makes every extra line cost every turn).

_Avoid_: rule bloat, baseline creep, AGENTS.md obesity
