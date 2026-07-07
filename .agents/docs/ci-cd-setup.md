# CI/CD setup runbook

Manual, maintainer-only GitHub configuration that the CI/CD strategy
([ADR 0010](adr/0010-ci-cd-strategy.md)) depends on. Items marked **[done by the
CI/CD PR]** are already applied by the pull request that introduced this file;
everything else needs a maintainer with admin rights on the repo.

Run through this once. Re-run individual steps only when something changes.

## 1. Default branch

- **[done by the CI/CD PR]** Renamed `master` → `main` (GitHub API
  `POST /repos/:owner/:repo/branches/master/rename`). The rename migrates open
  PRs and the default-branch pointer automatically.

## 2. Merge strategy

- **[done — verify]** Allow **rebase merging only**; disable squash and
  merge-commit. Enable "Automatically delete head branches".
  Settings → General → Pull Requests.

  ```bash
  gh api -X PATCH repos/IsaacIsrael/cli-setup \
    -F allow_rebase_merge=true \
    -F allow_squash_merge=false \
    -F allow_merge_commit=false \
    -F delete_branch_on_merge=true
  ```

## 3. Branch protection on `main`

An active **ruleset** targeting `~DEFAULT_BRANCH` already enforces: PR required
(no direct push), no force-push or deletion, no bypass actors (administrators
included), 0 required approvals. Because it targets `~DEFAULT_BRANCH`, the rename
carried it over — no re-targeting needed.

Remaining deltas (Settings → Rules → Rulesets → edit the ruleset):

- [x] **Required status checks** — `CodeRabbit` plus all six gate checks
      (`commit-lint / commit-lint`, `branch-lint / branch-lint`,
      `code-lint / code-lint`, `format-check / format-check`, `test / test`,
      `generate-docs / generate-docs`) are in the required set now, while the
      gates are still placeholders. "Require branches to be up to date before
      merging" is left **off**. Update a context string if a slice renames its
      job, or merges will block (see step 8).
- [x] **Require conversation resolution before merging** — enabled.
- [x] Explicit **linear-history** rule present (rebase-only already implies it).

## 4. Tag protection (release tags)

Releases only create tags and GitHub Releases — no commit or PR touches the
protected `main`, so **no GitHub App, secret, or "Actions can open PRs" toggle is
needed** (the workflow's default `GITHUB_TOKEN` suffices). Protect the version
tags but leave the changelog cursor movable:

- [x] Tag ruleset "protect release tags" targeting `v*` is active: deletion and
      force-updates blocked, so a published `vX` is immutable.
- [x] `changelog-base` is **not** covered — the `_release (draft)` flow must move
      it forward (see step 5).

## 5. Changelog cursor (`changelog-base`)

Feature release notes are generated from `changelog-base..HEAD`, so the cursor
decouples the accumulating draft from interleaved hotfix `v*` tags. `cog` ignores
it for versioning because it lacks the `v` prefix (`tag_prefix = "v"`).

- [ ] Create the initial cursor (at the first release point, or now):

  ```bash
  git tag changelog-base && git push origin changelog-base
  ```

- [ ] The `_release (draft)` flow self-advances it to the latest published feature
      (minor/major) `v*` tag on the next draft update (wired in #10); the hotfix
      flow never moves it. There is no publish workflow to move it at publish time.

## 6. GitHub Pages

For the docs deploy in `publish.yml` (runs on release; wired for real in #9):

- [x] Pages source set to **GitHub Actions** (`build_type: workflow`).
- [ ] After the first successful deploy, set the repo **homepage** to the Pages
      URL (deferred until #9 publishes).

## 7. CodeRabbit (blocking AI review gate)

CodeRabbit is free for public repos and is configured via `.coderabbit.yaml`
(pre-merge checks in `mode: error`). See ADR 0010 for why it is the chosen gate.

- [x] Installed the CodeRabbit GitHub App on `IsaacIsrael/cli-setup`
      (<https://github.com/apps/coderabbitai>).
- [x] Confirmed it reviews an open PR (its review + the `CodeRabbit` status check
      appear on #13).
- [x] Added the `CodeRabbit` check to the required status-check set (step 3).
- [x] GitHub Copilot review left enabled as **advisory** comments only.

## 8. Required checks — ordering

Required checks can only reference a check GitHub has seen at least once, so
there is a chicken-and-egg order:

1. A gate ships as a placeholder and runs on a PR (its check name appears).
2. Its slice (#4–#9) replaces the placeholder with the real command.
3. Only then add that check name to the required set (step 3).

Check → slice map — the required set must use the **check-run names GitHub
reports**, not the `_gate-*` filenames. Because each `pr.yml` job calls a
reusable workflow, the reported name is the nested `<pr.yml job> / <reusable job>`
form: `commit-lint / commit-lint` (#4), `branch-lint / branch-lint` (#5),
`code-lint / code-lint` (#6), `format-check / format-check` (#7),
`test / test` (#8), `generate-docs / generate-docs` (#9). Add the exact
`CodeRabbit` check name observed on a PR once verified (step 7).

## 9. Repository metadata

- **[done by the CI/CD PR]** Description and topics set via `gh`.
- [x] **Social preview image** — uploaded manually via Settings → General →
      Social preview, using
      [`docs/src/assets/hero.png`](../../docs/src/assets/hero.png).

## 10. Triage labels

- **[done by the CI/CD PR]** Created `bug`, `enhancement`, `needs-triage`,
  `needs-info`, `wontfix` (`ready-for-agent`, `ready-for-human`, `prd` already
  existed). See [triage-labels.md](triage-labels.md).

## 11. Cutting a release

**Feature release (on demand):**

- Open the accumulated **draft Release** (Releases → the draft the `main.yml`
  router keeps updated via `_release` with `draft: true`), review the notes and
  tag-name. The asset is already attached (built at draft time for the pending
  version), so **do not edit the version on the publish form** — if you need a
  different number, re-cut instead. Click GitHub's native **"Publish release"**
  button.
- Publishing makes GitHub create the tag and flip the draft to published (the
  pre-attached asset carries over); `release: published` → `publish.yml` only
  deploys the docs. The `changelog-base` cursor is advanced later, on the next
  draft update. Nothing is committed to `main`.

**Hotfix release (automatic):**

- Merge a `hotfix/*` PR. The `main.yml` router runs `_release` with `draft: false`:
  `cog` forces a patch, tags `vX`, stamps + uploads the asset, and publishes a
  Release scoped to that PR. The cursor is not moved. Nothing is committed to `main`.

## Appendix: setup banner (Dracula theme)

ASCII banner concept for the CLI splash / social preview wordmark:

```text
 ██████╗██╗     ██╗      ███████╗███████╗████████╗██╗   ██╗██████╗
██╔════╝██║     ██║      ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
██║     ██║     ██║█████╗███████╗█████╗     ██║   ██║   ██║██████╔╝
██║     ██║     ██║╚════╝╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝
╚██████╗███████╗██║      ███████║███████╗   ██║   ╚██████╔╝██║
 ╚═════╝╚══════╝╚═╝      ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝
        Guided, idempotent macOS dev-environment setup
```

Image-generation prompt (for regenerating the social preview at 1280×640):

> A dark terminal window on a near-black background, Dracula color palette
> (background `#282a36`, purple `#bd93f9`, pink `#ff79c6`, green `#50fa7b`,
> foreground `#f8f8f2`). Centered ASCII-style wordmark reading "SETUP" in a
> purple-to-pink gradient, a green `cli-setup` prompt line above it and a green
> block cursor below, with the tagline "Guided, idempotent macOS dev-environment
> setup" in muted blue. Monospace font, crisp, minimal, high contrast.
