---
name: triage
description: Router for triage — dispatches to issue triage or leftover triage based on what you point it at.
disable-model-invocation: true
---

# Triage (router)

The single entry point for triage. It reaches one of two leaf skills; it does no triage work itself.

- [`triage-issue`](../triage-issue/SKILL.md) — the issue/PR state machine (category + state roles, briefs).
- [`triage-leftover`](../triage-leftover/SKILL.md) — end-of-milestone effort-impact triage of a `leftover` container.

## Dispatch

**With a target** (`/triage #42`): read the target's labels.

- Carries `leftover` → follow [`triage-leftover`](../triage-leftover/SKILL.md).
- Otherwise → follow [`triage-issue`](../triage-issue/SKILL.md).

**With no target** ("what needs attention?"): show two sections, then let the maintainer pick.

1. **Issues** — hand off to [`triage-issue`](../triage-issue/SKILL.md)'s "show what needs attention" buckets.
2. **Leftovers ready for review** — milestones whose `leftover` container has **no open non-leftover issue left** in the milestone (the milestone is wrapping up). List each and offer to run [`triage-leftover`](../triage-leftover/SKILL.md).

Query for section 2: list open `leftover` containers (`gh issue list --label leftover --state open`), and for each, check its milestone has no other open non-leftover issue.
