# Branch to issue and base resolution

Shared procedure for skills that operate on the current branch's work against its originating issue — `ship` and `verify-acceptance` need both answers, and `commit` uses the base resolution to bound its history rewrites. The logic lives here once.

## Find the linked issue

Resolve the issue number in this order; stop at the first hit:

1. **Explicit argument** — an issue ref the caller passed (number, `#N`, or URL).
2. **Branch name** — an issue number embedded in the current branch (e.g. `feature/42-foo` -> `42`).
3. **Commit messages** — an issue reference in the commits on this branch (`Closes #N`, `Fixes #N`, or a bare `#N`), via `git log <base>..HEAD`.

If none of these yields an issue, **ask the user** for the issue ref — do not guess.

Fetch the resolved issue with `gh issue view <n> --comments` (see [issue-tracker.md](issue-tracker.md)).

## Resolve the base branch

The base is the branch this work merges into. Honor an explicit base argument if the caller passed one; otherwise derive it from the Git Flow branch prefix:

| Current branch prefix   | Base branch        |
| ----------------------- | ------------------ |
| `feature/*`, `bugfix/*` | the integration branch |
| `release/*`, `hotfix/*` | the default branch |

Default to the repository's default branch when the prefix is unknown or absent.

## Confirm before proceeding

Before any skill acts on the diff, confirm both:

- The base resolves: `git rev-parse <base>` succeeds.
- The diff is non-empty: `git diff <base>...HEAD` has changes (three-dot, so the comparison is against the merge-base).

A bad ref or empty diff should fail here, with a clear message, rather than deeper in a skill's flow.
