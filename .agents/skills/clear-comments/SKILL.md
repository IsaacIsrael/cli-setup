---
name: clear-comments
description: Drive every unresolved review thread on a PR to a decided outcome — implement and resolve the valid ones, reply to the rest, escalate the ambiguous ones.
argument-hint: "[pr ref]"
disable-model-invocation: true
---

# Clear comments

**Clear** the PR: take every unresolved **review thread** to a decided outcome. Each thread gets one **disposition**:

- **Address** — the requested change is valid: implement it, reply, and resolve the thread.
- **Respond** — no code change is warranted (answer a question, decline a nit, disagree with reason): reply and leave the thread open.
- **Escalate** — the thread needs a human decision: flag it to the user and leave it open.

Scope is review threads only — CI and merge conflicts belong to `babysit`. This skill does not review the diff (`/code-review` does) and does not gate acceptance (`/verify-acceptance` does). It composes existing skills: `/commit` turns the fixes into commits and `/ship` publishes them.

Invoking `/clear-comments` authorizes the reply, resolve, and (via `/commit` + `/ship`) commit and push actions on this branch, per [git-safety.mdc](../../rules/git-safety.mdc).

## Process

### 1. Resolve the PR and require a clean tree

Resolve the PR from the current branch with `gh pr view --json number,url,headRefName`, or from the `[pr ref]` argument if given. No PR resolves -> ask the user; do not guess. Record `owner`/`repo` from `gh repo view --json owner,name`.

Require a **clean working tree**: if `git status --porcelain` is non-empty, stop and tell the user — `/commit` in step 5 must capture only the review fixes, nothing pre-existing.

### 2. Fetch unresolved threads

Pull the review threads, keeping only `isResolved == false`. Carry each thread's `id` and, per comment, `databaseId`, `author.login`, `body`, `path`, `line`, `createdAt`:

```bash
gh api graphql -f query='
query($owner:String!,$repo:String!,$pr:Int!){
 repository(owner:$owner,name:$repo){ pullRequest(number:$pr){
  reviewThreads(first:100){ nodes{
   id isResolved isOutdated
   comments(first:50){ nodes{ databaseId author{login} body path line createdAt } } } } } } }' \
 -f owner=OWNER -f repo=REPO -F pr=N
```

**Dedupe (idempotency):** skip a thread whose latest reply is the agent's own — identified by the hidden marker `<!-- clear-comments -->` — **unless** a human comment is newer than that marked reply, in which case re-engage. This keeps re-runs across review rounds from re-replying to threads already handled.

Validate bot comments (e.g. Bugbot) carefully: act only on the valid ones and explain when you disagree or are unsure.

**Completion criterion:** every unresolved thread is either queued for this run or explicitly skipped as already-handled.

### 3. Classify and present the plan

Assign a disposition (Address / Respond / Escalate) to each queued thread. Present a table — thread location -> disposition -> the action you will take — and wait for **one** confirmation before touching anything. Write nothing until the user approves.

### 4. Implement the Address threads

Apply the changes for every Address thread, reusing `/implement` and `/tdd` at pre-agreed seams where it fits. Run the repo's existing quality gates (`shellcheck`, `shfmt`, `shellspec`, `cog check`) where applicable.

### 5. Commit

Call `/commit` to turn the fixes into meaningful, atomic commits — absorbing each fix into the original commit whose work it continues where that applies.

### 6. Publish

Call `/ship` to push and update the PR. `/ship` is idempotent: it updates the existing PR rather than recreating it, and adjusts draft/ready from the acceptance gate. Replies and resolves happen only after this step, so a resolve never precedes the published fix.

### 7. Reply and resolve

For each thread, reply on the thread via REST, embedding the hidden marker in the body so step 2 can dedupe on re-runs:

```bash
gh api --method POST "repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies" \
  -f body="$(cat <<'EOF'
<!-- clear-comments -->
<your reply>
EOF
)"
```

- **Address** — reply with what changed, then resolve the thread:

```bash
gh api graphql -f query='mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } } }' -F id=THREAD_ID
```

- **Respond** — reply with the reasoning; leave the thread open (do not resolve).
- **Escalate** — reply flagging that it needs a human decision; leave open. For a valid-but-out-of-scope request, reply "out of scope, tracking separately" and **offer** to open a follow-up issue via `/to-issues`, creating it only if the user confirms.

**Completion criterion:** every queued thread has a reply, and every Address thread is resolved.

### 8. Report

Summarize: Address threads implemented and resolved, Respond threads replied (left open), Escalate threads flagged (left open), and any follow-up issues created. Report against the current `HEAD`.
