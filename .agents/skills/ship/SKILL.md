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

Push the branch, then detect whether a PR already exists for it: `gh pr view --json number,state,isDraft` (or `gh pr list --head <branch>`). The push already updated the diff either way; the two cases differ only in whether you create the PR or adjust the existing one.

**No PR yet — create it** with `gh pr create`, filling `.github/PULL_REQUEST_TEMPLATE.md`:

- **Title** — `[Type] description`, where `Type` is a Git Flow type with its first letter uppercase (`Feature`, `Bugfix`, `Release`, `Hotfix`) matching the branch prefix. Start the description with a capital letter, and wrap commands, file names, and identifiers in `` `backticks` ``, e.g. ``[Feature] Add `doctor` command``.
- **Summary** — the why + narrative: why the PR exists and the story of the change. Keep it to motivation/context, not a deliverables list (those belong under "What this PR generates").
- **What this PR generates** — the deliverables/outcomes: what exists after this merges (distinct from the Summary's why). Product-focused bullet points in general terms (e.g. adds a command, updates the docs, establishes future docs structure), not a file list.
- **Test plan** — a checklist split into two groups. Under "Automated / verified by the agent", list the steps you actually ran and check them (`- [x]`), each with the command and observed result. Under "Manual — for the reviewer to verify", list steps you could not run and leave them unchecked (`- [ ]`), each with the command and expected result.
- **Notes for reviewers** — focus areas, trade-offs, follow-ups.
- **Related issue** — `Closes #<n>` (last section).

CI/CD runs the quality gates (`cog check`, `shellcheck`, `shfmt`, `shellspec`, Bash 3.2 compatibility), so do not restate them as a checklist in the PR body.

Gate the new PR's state on the verdicts from step 3:

- **All criteria met** → open a ready PR.
- **Any criterion unmet** → open a **draft** PR (`--draft`) and list the unmet criteria under "Notes for reviewers" so the gap is visible.

**PR already exists — update it, never recreate.** The push above is the update; **preserve the existing body** (do not overwrite manual edits). Then adjust the draft/ready state from the step-3 verdicts, **bidirectionally**:

- **All criteria met** → promote to ready (`gh pr ready <n>`).
- **Any criterion unmet** → demote to draft (`gh pr ready --undo <n>`) and **warn prominently**, calling out any criterion that **regressed** (was met, now unmet).

Return the PR URL.
