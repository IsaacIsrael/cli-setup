---
name: leftover
description: Use when, mid-work, you notice tech debt or a lateral change that is out of scope for the current issue and deferrable to end of milestone — park it as a leftover item instead of derailing to fix or file it now.
---

# Leftover

Capture a [leftover item](../../docs/CONTEXT.md) without breaking flow. Parking is **two-phase**: stage silently while working, then flush the batch to the milestone's [`leftover`](../../docs/CONTEXT.md) container at wrap-up. This exists so noticing debt never costs a detour.

Only park things that are genuinely **out of scope for the current issue** and **deferrable to end of milestone**. In-scope work belongs in the current issue; an urgent break belongs fixed now — neither is a leftover.

## Phase 1 — Stage (silent, during work)

When you notice a candidate, append it to `.scratch/leftover/staged.md` (create the dir if absent) and say nothing more — no modal, no question, no pause. Keep working on the current task.

One block per item:

```markdown
## <short title>

<one or two lines: what it is, why it is out of scope / deferrable>

Spotted while working #<current issue> (<branch or commit>)
```

Never write to a GitHub issue in this phase.

## Phase 2 — Flush (batch confirmation, at wrap-up)

Triggered at task wrap-up (the [`ship`](../ship/SKILL.md) hook calls this, or the developer flushes manually). If `.scratch/leftover/staged.md` is empty or missing, do nothing.

1. **Resolve the milestone** from the current issue/branch per [branch-issue-resolution.md](../../docs/branch-issue-resolution.md); allow an explicit override. Find its `leftover` container (`gh issue list --label leftover`), or note it must be created lazily.
2. **Dedup** — scan that container (and prior containers, including struck-through discards) for items that look like a staged one. Flag each likely duplicate with a link.
3. **Confirm — ask modal.** Present the staged items **one per item** via `AskQuestion`: park / merge-into-duplicate / drop. Include the dedup flags. Nothing is written to GitHub before the developer answers.
   - **AFK (no one to answer):** leave the staged file in place and stop — never park unconfirmed.
4. **Execute** the confirmed set: create the container lazily if needed (title `Leftover — <milestone>`, label `leftover`, attached to the milestone), then append each parked item as a `##` section in the body.
5. **Clear** the staged entries you processed from `.scratch/leftover/staged.md`.

Parking only records items. Scoring and routing happen later in [`triage-leftover`](../triage-leftover/SKILL.md) at end of milestone.
