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

## Leftover containers

A [`leftover`](CONTEXT.md) is one container issue per milestone that parks tech-debt items noticed while working. See ADR 0013.

- **Lazy creation**: create it only when the first item needs parking — never up front. Title `Leftover — <milestone>`, label `leftover`, attached to that milestone. The `.github/ISSUE_TEMPLATE/leftover.yml` form seeds this for humans; agents create it via `gh issue create --label leftover --milestone "<title>"`.
- **Adding items**: append one `##` section per item to the body — short title, one or two lines of context, and a link to where it surfaced. `/leftover` stages captures under `.scratch/leftover/` and flushes them in a batch (see the skill).
- **End-of-milestone review**: when a milestone has no open non-leftover issue left, run effort-impact triage (`/triage-leftover`). It scores each item on effort against impact and routes it:
  - **⚡ Quick win** (low effort, high impact) → the milestone's **Milestone refinement** issue.
  - **🏆 Real win** (high effort, high impact) → address now, or **graduate** to its own tracer-bullet issue in a later milestone.
  - **🍬 Nice win** (low effort, low impact) → refinement if time allows, else discard.
  - **🕳️ Time sink** (high effort, low impact) → discard.
  - Effort boundary: **low** ≈ aggregatable into the refinement issue (~1h anchor); **high** deserves its own issue. Impact is **high** if it affects the end user, unblocks future work, or reduces risk.
- **Dispositions in the body**: routed/graduated items link to the new issue; discarded items are struck through (`~~…~~`) with 🕳️ and kept for dedup. Close the container once every item is destined; **never close the milestone automatically** — only suggest it.
- **Refinement / graduated issues** follow the normal issue flow after creation (one PR each, standard template). Both are created as **children** of the leftover container (`parentIssueId`) and born `needs-triage` + category. End-of-milestone triage posts **exactly one** decision-report comment per run on the container (disclaimer + routing + screenshot; edit that comment if something is missing — no follow-ups), closes the container with `gh issue close` **without** `--comment`, and strikes unaddressed items. Do not create an empty refinement issue.

## Pull requests as a triage surface

**PRs as a request surface: no.**

External PRs are not treated as issues for triage purposes — manage them separately.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.
