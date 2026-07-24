---
name: ship
description: Review the work, verify the linked issue's acceptance criteria against the diff, then open the PR — draft if any criterion is unmet, ready if they all pass.
argument-hint: "[issue ref] [base branch]"
disable-model-invocation: true
---

Ship the current branch: review it, prove it meets the issue's acceptance criteria, and open the PR. The acceptance criteria are the gate — every one must be **met against the actual diff**, not just ticked on the issue. Any criterion left unmet means the PR opens as a **draft**.

Invoking `/ship` is the explicit authorization to push the branch and open the PR (see `.agents/rules/git-safety.mdc`).

## Process

### 1. Pin the issue and the base

Resolve the linked issue and the base branch per `.agents/docs/branch-issue-resolution.md`, honoring the issue ref (first argument) and base override (second argument). Read the issue's **Acceptance criteria**. Use this base for both the review diff and the PR.

Confirm the base resolves and `git diff <base>...HEAD` is non-empty before going further.

If `git status --porcelain` shows uncommitted changes, offer to run `/commit` first (⭐ the recommended choice, per `.agents/rules/recommendation-marker.mdc`) — the review, acceptance verification, and PR all judge the committed diff, so uncommitted work would silently fall outside them. If the user declines, proceed but warn that the uncommitted changes will not be part of the review, acceptance, or PR.

### 2. Review

Run `/code-review` with the pinned base as the fixed point. Surface its Standards and Spec reports to the user. Review findings inform the ship but do not gate it — the acceptance criteria do.

### 3. Verify acceptance criteria against the diff

Run `/verify-acceptance` for the pinned issue and base. It judges every criterion against `git diff <base>...HEAD`, runs the repo's quality gates, syncs the issue's checkboxes to the verdict, and publishes the met/unmet report as an issue comment.

Use its per-criterion verdicts as the gate for step 4. If the issue has no acceptance criteria, treat that as a blocker to clarify with the user rather than a pass.

Done when every criterion has a met/unmet verdict backed by diff evidence.

### 4. Open or update the PR

Run `/open-pr` with the pinned base, passing the draft/ready decision from step 3's verdicts. `/open-pr` owns the PR mechanics — push, template, create-vs-update, and state transitions:

- **All criteria met** → ready.
- **Any criterion unmet** → draft, and hand `/open-pr` the unmet criteria so it surfaces them under "Notes for reviewers", calling out any criterion that **regressed** (was met, now unmet).

Return the PR URL it reports.

### 5. Leftover wrap-up

Two hooks, both suggestions the developer confirms — never automatic:

- **Flush staged leftovers.** If `.scratch/leftover/staged.md` has entries, run [`/leftover`](../leftover/SKILL.md)'s Phase 2 (batch confirmation via the ask modal) so nothing parked this session is lost.
- **Offer end-of-milestone triage.** If the pinned issue is the **last open non-leftover issue** in its milestone (the milestone is wrapping up) and that milestone has a `leftover` container, suggest running [`/triage-leftover`](../triage-leftover/SKILL.md). Do not run it unprompted, and never close the milestone.
