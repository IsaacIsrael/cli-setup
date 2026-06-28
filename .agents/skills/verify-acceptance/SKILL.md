---
name: verify-acceptance
description: Verify a linked issue's acceptance criteria against the branch diff, run the repo's quality gates as evidence, sync the issue's checkboxes to the verdict, and publish a met/unmet report as a single issue comment. Use when the user wants to check, verify, or mark the acceptance criteria of an issue, or asks whether the work satisfies the issue.
argument-hint: "[issue ref] [base branch]"
disable-model-invocation: true
---

# Verify acceptance

Judge every acceptance criterion of the linked issue against the actual branch diff, prove the work runs, and record the verdict on the issue. This skill is the **acceptance gate**: it owns criterion verdicts and the issue's checkboxes. It does **not** open or modify pull requests — `ship` does that and calls this skill for the gate.

## Process

### 1. Resolve issue + base

Resolve the linked issue and the base branch per [.agents/docs/branch-issue-resolution.md](../../docs/branch-issue-resolution.md), honoring the optional `[issue ref]` and `[base branch]` arguments (when called by `ship`, both are passed in).

Fetch the issue with `gh issue view <n> --comments` (see [.agents/docs/issue-tracker.md](../../docs/issue-tracker.md)) and read its `## Acceptance criteria` block.

- No issue could be resolved -> ask the user for the issue ref; do not guess.
- Issue has no `## Acceptance criteria` section -> report "no acceptance criteria defined", make **no** edits to the issue, skip steps 4-5, and stop. (When invoked by `ship`, this is a blocker to clarify, not a pass.)

### 2. Verify each criterion against the diff

For **every** criterion, judge it against `git diff <base>...HEAD` and the code it touches, and mark it **met** or **unmet** with one line of evidence quoted from the diff.

A criterion is met only when the diff demonstrably satisfies it. A pre-checked box on the issue does **not** count as met — verify it fresh every time.

### 3. Prove it works (adaptive)

Detect the repo's **quality gates** and run the ones that exist — e.g. `cog check`, `shellcheck`, `shfmt`, `shellspec`, Bash 3.2 compatibility. For each criterion, record whether it was verified by **execution** (a gate ran and passed) or by **inspection** (diff reasoning only).

If the repo has no quality gates yet, say so explicitly and rely on diff inspection — do not fabricate a passing gate.

### 4. Sync the checkboxes to the verdict

The verification is the source of truth for the checkboxes (see ADR 0008). Edit the issue body with `gh issue edit <n> --body` so each criterion's box reflects the current verdict:

- met -> `- [x]`
- unmet -> `- [ ]`

This means unchecking a box whose criterion is now unmet. Never invent, reword, reorder, or drop criteria — only flip the `[ ]`/`[x]` marker. Note every box you changed, and call out **regressions** (a box that was `[x]` and is now `[ ]`) prominently.

### 5. Publish the report as a single issue comment

Keep one report comment, marked with a hidden HTML marker so it can be updated in place instead of spamming the issue:

```
<!-- verify-acceptance-report -->
```

Find the existing marked comment and edit it; create it (with the marker) only if none exists. `gh issue comment` cannot target a comment by marker, so look it up via the API:

```bash
# find the marked comment id (empty if none yet)
id=$(gh api "repos/{owner}/{repo}/issues/<n>/comments" \
  --jq '.[] | select(.body | contains("<!-- verify-acceptance-report -->")) | .id' | head -n1)

if [ -n "$id" ]; then
  gh api -X PATCH "repos/{owner}/{repo}/issues/comments/$id" -f body="$BODY"   # update in place
else
  gh issue comment <n> --body "$BODY"                                          # first run
fi
```

Build `$BODY` with a heredoc. It must contain the marker plus, for every criterion, its met/unmet verdict and one line of evidence, the quality-gate results, and the execution-vs-inspection note. Report against the current `HEAD` so a reader knows what was verified.

Return the same report in the chat.

## Report template

```markdown
<!-- verify-acceptance-report -->
## Acceptance verification

Base `<base>` -> HEAD `<short-sha>`.

| # | Criterion | Verdict | Evidence | Verified by |
|---|-----------|---------|----------|-------------|
| 1 | <text>    | met     | <diff evidence> | execution / inspection |
| 2 | <text>    | unmet   | <what's missing> | inspection |

**Quality gates:** <gates run and their results, or "none present in this repo yet">.

**Checkbox changes:** <boxes ticked/unticked, regressions called out, or "none">.

**Gate:** <N> of <M> criteria met.
```
