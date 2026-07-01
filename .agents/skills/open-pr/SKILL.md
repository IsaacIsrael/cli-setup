---
name: open-pr
description: Open or update the current branch's pull request — push, resolve the base and linked issue, fill the PR template, create the PR or update the existing one, and set its draft/ready state. Use when the user wants to open, create, or raise a PR, or when another skill (e.g. ship) needs to open or update the PR.
argument-hint: "[base branch] [--draft | --ready]"
---

# Open PR

Open or update the pull request for the current branch. This skill owns the PR **mechanics** — push, template, create-vs-update, draft/ready — so callers don't restate them.

Invoking `/open-pr` is the explicit authorization to push the branch and open or update the PR (see [git-safety.mdc](../../rules/git-safety.mdc)), the same way `/ship` is.

## The draft/ready decision is an input

This skill does **not** judge acceptance criteria — that gate belongs to `verify-acceptance`, and `ship` owns the flow that runs it. The caller decides the state; honor it:

- A caller (e.g. `ship`) passes a verdict — any unmet criterion means **draft**; all met means **ready**.
- Invoked standalone with `--draft` or `--ready` — honor the flag.
- Nothing given — default **ready**.

## Process

### 1. Pin the base and issue

Resolve the base branch and linked issue per [branch-issue-resolution.md](../../docs/branch-issue-resolution.md), honoring the `[base branch]` argument if given. The base and issue feed the PR title's type and its `Closes #` footer.

Confirm the base resolves (`git rev-parse <base>`) and `git diff <base>...HEAD` is non-empty before going further.

If `git status --porcelain` shows uncommitted changes, offer to run `/commit` first (⭐ the recommended choice, per [recommendation-marker.mdc](../../rules/recommendation-marker.mdc)) — the PR reflects only pushed commits, so uncommitted work would silently fall outside it. If the user declines, proceed but warn that those changes won't be part of the PR.

### 2. Push, then detect whether a PR exists

Push the branch. Then check for an existing PR for it: `gh pr view --json number,state,isDraft` (or `gh pr list --head <branch>`). The push already updated the diff either way; the two cases below differ only in whether you create the PR or adjust the existing one.

### 3a. No PR yet — create it

`gh pr create`, filling [.github/PULL_REQUEST_TEMPLATE.md](../../../.github/PULL_REQUEST_TEMPLATE.md):

- **Title** — `[Type] description`, where `Type` is a Git-Flow-style branch type with its first letter uppercase (`Feature`, `Bugfix`, `Hotfix`) matching the branch prefix. Start the description with a capital letter, and wrap commands, file names, and identifiers in `` `backticks` ``, e.g. ``[Feature] Add `doctor` command``.
- **Summary** — the why + narrative: why the PR exists and the story of the change. Motivation/context, not a deliverables list.
- **What this PR generates** — the deliverables/outcomes: what exists after this merges (distinct from the Summary's why). Product-focused bullets in general terms (adds a command, updates the docs), not a file list.
- **Test plan** — a checklist in two groups. Under "Automated / verified by the agent", list the steps you actually ran and check them (`- [x]`), each with its command and observed result. Under "Manual — for the reviewer to verify", list steps you could not run and leave them unchecked (`- [ ]`), each with its command and expected result.
- **Notes for reviewers** — focus areas, trade-offs, follow-ups. When the state is **draft**, list the unmet criteria the caller passed so the gap is visible, calling out any criterion that **regressed** (was met, now unmet).
- **Related issue** — `Closes #<n>` (last section).

Set the initial state from the draft/ready decision: ready → a ready PR; draft → `--draft`.

CI/CD runs the quality gates (`cog check`, `shellcheck`, `shfmt`, `shellspec`, Bash 3.2 compatibility), so don't restate them as a checklist in the PR body.

### 3b. PR already exists — update it, never recreate

The push in step 2 is the update. **Preserve the existing body** — do not overwrite manual edits. Then move the draft/ready state to match the decision, **bidirectionally**:

- ready → promote (`gh pr ready <n>`).
- draft → demote (`gh pr ready --undo <n>`) and **warn prominently**, calling out any criterion that **regressed**.

### 4. Return the PR URL
