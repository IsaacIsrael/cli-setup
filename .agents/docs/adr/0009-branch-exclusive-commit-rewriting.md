# `/commit` may rewrite commits exclusive to the current branch, even if pushed

The `/commit` skill absorbs changes into existing commits (via amend or fixup+autosquash) to keep a branch's history clean, so it needs to rewrite already-made commits — which contradicts the conservative default in `git-safety.mdc` ("avoid `--amend` unless the commit has not been pushed"). We scope the rewrite to commits **exclusive to the current branch** (proven via `git branch -a --contains` and the `<base>..HEAD` range), allow it even when those commits are already on `origin`, and never touch history shared with the base or another branch; when exclusivity cannot be proven the skill falls back to a new commit, and it never pushes (it only warns that a `--force-with-lease` is needed).

## Considered Options

- **Never rewrite pushed commits (the strict git-safety default)**: rejected — it defeats the skill's purpose of folding follow-up work into the commit it belongs to on branches that are routinely pushed for backup or review.
- **Rewrite any unpushed commit but never a pushed one**: rejected — the user explicitly wants to keep a branch's own pushed commits tidy; the danger is not "pushed" but "shared", so the boundary is exclusivity, not push state.
- **Auto `--force-with-lease` after rewriting**: rejected — pushing is a separate, explicit action (`/ship` or the user), per git-safety.

## Consequences

- After absorbing into a pushed commit, the branch diverges from `origin` and syncing requires `git push --force-with-lease`; the skill surfaces this rather than pushing.
- `git-safety.mdc` carries an explicit exception pointing to `/commit` so the rule and the skill do not contradict each other.
