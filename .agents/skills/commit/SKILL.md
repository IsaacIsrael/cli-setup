---
name: commit
description: Turn the working tree into meaningful, atomic commits — proposing for each change whether it starts a new commit or is absorbed into one of this branch's own commits — and execute only after you approve.
disable-model-invocation: true
---

Turn the working tree into meaningful, atomic commits. For each logical change, decide whether it starts a **new commit** or is **absorbed** into one of this branch's own commits, propose the full plan, and execute only after the user approves.

Invoking `/commit` is the explicit authorization to rewrite **this branch's own commits** — even ones already on `origin` — per [git-safety.mdc](../../rules/git-safety.mdc), the same way `/ship` authorizes the push. It never rewrites shared history and never pushes.

Message format and commit granularity follow [conventional-commits.mdc](../../rules/conventional-commits.mdc).

## Absorb

**Absorb** = fold a change into the existing branch-local commit whose logical work it continues or fixes (`git absorb`-style), instead of adding a new commit. Absorbing is a history rewrite, so it is bounded to commits exclusive to this branch.

## Process

### 1. Survey the changes

`git status --porcelain`, `git diff` (staged and unstaged), and the untracked files. Group everything uncommitted into atomic changes per the "Commit granularity" section of `conventional-commits.mdc`. Group at file granularity; split a file into hunks (`git add -p`) only when it genuinely mixes two logical changes — and flag that split in the proposal.

### 2. Fix the rewrite boundary

Resolve the base branch per [branch-issue-resolution.md](../../docs/branch-issue-resolution.md) (trunk-based: always `main`). The **rewritable set** is the commits in `git log <base>..HEAD` that are exclusive to this branch: for each candidate, `git branch -a --contains <sha>` must show no other local or remote branch — before the first push, the current branch alone is sufficient evidence. Any commit also reachable from the base or another branch — or any case where exclusivity cannot be proven — is off-limits.

### 3. Decide absorb vs. new — per group

- Find the candidate target: the branch-local commit that last touched the changed lines (`git log -1 <base>..HEAD -- <paths>`, or blame the changed hunks).
- **Absorb** when the group continues or fixes that commit's logical work **and** the target is in the rewritable set. When it is ambiguous, prefer absorb — but only if there is a probable exclusive target; otherwise propose a new commit.
- Otherwise, **new commit**.

### 4. Propose the plan — wait for approval

List every group with its action (new commit / amend HEAD / fixup `<sha>`), the files or hunks it covers, and the proposed Conventional Commits message. Mark any target commit that is already on `origin`. When a group's absorb-vs-new call is genuinely ambiguous, present the alternatives and ⭐-mark the recommended one per [recommendation-marker.mdc](../../rules/recommendation-marker.mdc). Write nothing until the user approves.

### 5. Execute (after approval)

- New commit: stage the group (`git add <paths>` or `git add -p`) and `git commit`.
- Absorb into HEAD: `git commit --amend`.
- Absorb into an earlier commit: `git commit --fixup=<sha>` then `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>` (`-i` is required — `--autosquash` is a no-op without it; `GIT_SEQUENCE_EDITOR=:` accepts the auto-arranged todo; rebasing from `<base>` keeps shared history untouched). On a rebase conflict, `git rebase --abort` and report — never leave a half-done rebase.
- Never `--no-verify`. If a hook fails, stop and report; never amend a failed commit (git-safety).

### 6. Report

Summarize the commits created and rewritten. If any rewritten commit was already on `origin`, warn that the branch has diverged and that syncing needs `git push --force-with-lease` — but do not push.
