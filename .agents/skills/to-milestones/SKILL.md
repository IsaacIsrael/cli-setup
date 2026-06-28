---
name: to-milestones
description: Organize a PRD's user stories into an ordered sequence of shippable milestones and publish them to the project issue tracker.
disable-model-invocation: true
---

# To Milestones

Turn a PRD into an ordered sequence of **milestones** — the smallest sets of issues that each deliver shippable user value. This sits between `/to-prd` and `/to-issues`: milestones are created here (empty), then `/to-issues` slices them into issues one at a time, attaching each issue to its milestone.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a PRD reference (issue number, URL, or path) as an argument, fetch it from the issue tracker and read its full body, especially the user stories. If no reference is passed and the PRD is not already in context, locate it on the issue tracker by its `prd` label (e.g. `gh issue list --label prd`).

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Milestone titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

### 3. Draft an ordered sequence of milestones

Group the PRD's user stories into milestones using these rules:

<milestone-rules>

- Each milestone is **independently shippable** and delivers user-visible value.
- The sequence is **ordered**: M1 → M2 → M3, each an increment built on the previous one.
- **M1 is the thinnest end-to-end product that is already useful** — the minimum viable increment.
- Prefer **few** milestones, each genuinely deliverable. When in doubt, fold work into a later milestone rather than splitting hairs.
- Every user story in the PRD belongs to exactly one milestone.

</milestone-rules>

### 4. Quiz the user

Present the proposed sequence as an ordered, numbered list. For each milestone, show:

- **Title**: short descriptive name. Start with a capital letter and wrap commands and identifiers in backticks (e.g. `` `doctor mobile` ``); the tracker renders titles as plain text, so backticks show literally as visual emphasis.
- **Deliverable**: one line on what becomes usable when this milestone ships
- **User stories covered**: which PRD user stories this milestone owns

Ask the user:

- Is M1 genuinely the thinnest useful product, or is it carrying scope that belongs later?
- Is the ordering right — does each milestone build on the previous one?
- Should any milestones be merged or split?

Iterate until the user approves the sequence.

### 5. Publish the milestones to the issue tracker

For each approved milestone, create a milestone in the issue tracker using its native milestone primitive — see `.agents/docs/issue-tracker.md` for the commands.

Publish in sequence order so the milestone ordering is preserved. Use the body template below: focus on the **deliverable**, not the implementation. Do NOT list the milestone's issues — those change as the work is sliced; the issues reference the milestone, not the other way around.

<milestone-body-template>
## Deliverable

What becomes usable for the user when this milestone ships. One short paragraph, from the user's perspective.

## Shippable when

The condition that makes this milestone genuinely releasable — the bar for "done and valuable", not a list of tasks.

## User stories covered

The PRD user stories this milestone owns. `/to-issues` reads these to decide which milestone each issue belongs to.

## PRD

A link back to the source PRD.

</milestone-body-template>

Then hand off to `/to-issues` to slice the first milestone into issues.
