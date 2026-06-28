# Issue tracker: GitHub

Issues and PRDs for this repo live as GitHub issues. Use the `gh` CLI for all operations. PRDs carry the `prd` label — filter them with `gh issue list --label prd`.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v` — `gh` does this automatically when run inside a clone.

## Milestones

GitHub milestones have no first-class `gh` command — use the API:

- **Create a milestone**: `gh api repos/:owner/:repo/milestones -f title="..." -f description="..."` (use a heredoc for a multi-line description).
- **List milestones**: `gh api repos/:owner/:repo/milestones --jq '.[] | {number, title}'`
- **Attach an issue to a milestone**: `gh issue create --milestone "<title>"` (on creation) or `gh issue edit <number> --milestone "<title>"`.

## Pull requests as a triage surface

**PRs as a request surface: no.**

External PRs are not treated as issues for triage purposes — manage them separately.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.
