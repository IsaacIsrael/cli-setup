# CI/CD strategy: reusable-workflow gates, trunk-based rebase-only, tag-sourced releases

We run CI as a set of **reusable per-gate workflows** (`on: workflow_call`) composed by thin event orchestrators (`pr.yml`, `main.yml`, `publish.yml`), sharing one composite action (`.github/actions/setup`) for toolchain install; we develop **trunk-based** on a single `main` with **rebase-only** merges and linear history; and we release with the **git tag as the single source of truth** — a release *only* creates a tag `vX` and a GitHub Release, never a commit to `main`, so neither `VERSION` nor `CHANGELOG.md` is committed. `hotfix/*` PRs **auto-publish a patch release on merge**; `feature/*`/`bugfix/*` work accumulates in a **draft Release** published on demand from the native **"Publish release"** button. AI code review (CodeRabbit) acts as a blocking gate, not just comments. We chose this because it keeps each quality gate independently reusable and named by purpose, keeps history bisectable, and keeps exactly one home for the version (the tag) and the changelog (the Release) — eliminating the dual-source races of a committed `VERSION`/`CHANGELOG`, and needing **no privileged release bot** because releases never push to `main`.

This ADR is meant to be concrete enough that slices #4–#10 can wire their CI/release jobs with no further design.

## Workflow shape

- **Composite action** `.github/actions/setup/action.yml` — the shared environment block: `brew bundle` from the `Brewfile` (single source of truth, parity with local) plus a Homebrew cache. Every gate calls it as its first step.
- **Reusable workflows** (`on: workflow_call`), each a single composable unit named by **purpose**, tool-agnostic. Their filenames carry a leading `_` to mark them as *callable* (never triggered directly), distinguishing them from the event orchestrators (`pr.yml`, `main.yml`, `publish.yml`). Two families:
  - _Gates_ (PR quality checks): `_gate-commit-lint`, `_gate-branch-lint`, `_gate-code-lint`, `_gate-format-check`, `_gate-test`, `_gate-generate-docs`.
  - _Deploy/release blocks_ (actions, not gates — they never block a PR): `_deploy-docs` (Pages) and **`_release`** — a single workflow whose **`draft` input selects the behavior**: `draft: true` updates the accumulating draft Release (a `feature/*`/`bugfix/*` merge); `draft: false` publishes a patch Release now (a `hotfix/*` merge). Kept out of the gate namespace precisely because they are not merge gates.
- **Event orchestrators** are thin — they only compose reusable workflows, never inline job bodies:
  - `pr.yml` (`on: pull_request`) calls every gate.
  - `main.yml` (the **merge router**, `on: pull_request: types: [closed]`, `if: merged`) reads the merged branch prefix: `hotfix/*` → `_release` with `draft: false` (+ `_deploy-docs`); anything else → `_release` with `draft: true`. (All branches target `main`, so a closed-and-merged PR is the single "landed on `main`" event.)
  - `publish.yml` (`on: release: published`) calls only `_deploy-docs` — the native "Publish release" button already created the tag and published the draft; the asset was pre-attached to the draft and the `changelog-base` cursor self-advances on the next draft update, so nothing else runs at publish.
- **Docs deploy on release, not on `main`**: `_deploy-docs` runs after a release is cut (from `publish.yml` on a feature publish, and chained after the hotfix `_release` in `main.yml` — a `GITHUB_TOKEN`-created release does not fire `release: published`). So GitHub Pages reflects the *released* version. Deploying on every merge would publish docs for unreleased/feature-flagged work sitting on the trunk. (The `_gate-generate-docs` PR check still verifies the docs *build* on every PR.)
- **Runners**: `ubuntu-latest` for every gate — no gate needs macOS.
- **Per-slice convention (fill-in the skeleton)**: the `_gate-*.yml` workflows ship now as valid running placeholders (each step just `echo …`) already wired into `pr.yml`. Each toolchain slice (#4–#9) replaces its placeholder body with the real `just` recipe / command, and only then is that check added to the branch-protection required-checks set.
- **Branch-name lint runs in both places**: the Lefthook `pre-push` hook gives fast, actionable feedback before a branch leaves the machine; `_gate-branch-lint` in CI is the unbypassable backstop that blocks a merge if a bad name slipped past a skipped or uninstalled hook. The branch prefix is also functional — base-branch resolution reads it (see `../branch-issue-resolution.md`).

## Development model and branch protection

- Trunk-based: single `main`, short-lived branches, **rebase-only** merges (squash and merge-commit disabled), linear history, `delete_branch_on_merge` on.
- Branch protection is enforced by a **ruleset** targeting `~DEFAULT_BRANCH` (so the `master`→`main` rename carried it over automatically): PR required (no direct push), no force-push or deletion, no bypass actors (administrators included), 0 required approvals.
- **Deltas applied as slices land**: add each gate to the required status-check set once its placeholder is replaced with real logic; enable required conversation resolution; optionally add an explicit linear-history rule. "Require branches to be up to date before merging" stays **off** (it serializes merges and forces constant rebases for little safety benefit on a low-traffic trunk).

## Code review policy

AI review acts as a **gate**, not just advisory comments. **CodeRabbit** is the reviewer: free forever on public repos, and its **Agentic Pre-Merge Checks** in `mode: error` (plus the Request Changes Workflow) produce a *failing* required status check — the only thing GitHub actually blocks a merge on (comments and neutral checks never block). Its check is added to the required-checks set once verified live on a PR. Human approvals stay at 0: the gate does the vetting, and CodeRabbit itself submits approve / request-changes.

CodeRabbit's coding-guideline detection is **directory-scoped** — a guideline file only governs the tree it lives in, and our authoritative rules/skills live under `.agents/` (no application code). So our standards are delivered two ways: (1) the review-relevant rules and skill criteria are distilled into `.coderabbit.yaml` → `reviews.instructions`, which is global and bypasses directory-scoping; and (2) `knowledge_base.code_guidelines.enabled` stays on so the root `AGENTS.md` and `.cursorrules` are auto-detected repo-wide. A generated root/`src` carrier synced from `.agents/rules` is recorded here as a **deferred option** if instruction drift becomes a problem.

GitHub Copilot review stays enabled as advisory comments only.

## Release model: tag-sourced, two flows

Supersedes #10's original "standing `chore(release)` PR" wording and the earlier draft-Release + committed-`VERSION` variant.

**Single source of truth = the git tag.** A release *only* creates a tag `vX` and a GitHub Release; it never commits to `main`. Nothing is committed as a version or changelog source: a committed `VERSION` or `CHANGELOG.md` would be a *second copy* of what the tag and the Release already hold, and that duplication is exactly what races and drifts (two `hotfix/*` PRs both writing `VERSION=1.2.1`, a stale pre-committed number, a tag/file mismatch). Instead:

- **Version**: `cog` **recomputes** the number at release time from the existing `v*` tags (never a pre-committed number); the build **stamps** it into the release asset (filename + a metadata line); `install.sh` **materializes** `~/.cli-setup/VERSION` on the user's machine from that stamped metadata, so `--version` and offline installs work without a `.git` present.
- **Changelog**: lives only in the GitHub Releases. `cog` generates the notes text for a commit range and writes it into the Release body — no committed file. The mdBook site may render a changelog page *derived* from the Releases at build time.

Because a release only tags + publishes (no push to `main`), it needs **no privileged bot**: the default `GITHUB_TOKEN` (`contents: write`) suffices and branch protection is never in play.

Two flows, both handled by the single `_release` workflow, routed by branch prefix on merge (all branches target `main`):

- **Hotfix — automatic** (`main.yml` router → `_release` with `draft: false`): merging a `hotfix/*` PR forces a **patch** (`cog`), tags `vX` at the new `main` HEAD, stamps + uploads the asset, and publishes a Release whose notes are **scoped to that PR**. It does **not** advance the changelog cursor. Then `_deploy-docs` runs.
- **Feature — on demand** (`main.yml` router → `_release` with `draft: true`): `feature/*` (and `bugfix/*`) merges accumulate into a **draft** Release (notes from `changelog-base..HEAD`), and the draft run **stamps + attaches the asset** built for the pending version. When ready, the maintainer clicks the native **"Publish release"** button; GitHub creates the tag, flips the draft to published (the pre-attached asset carries over), and `publish.yml` deploys the docs. No `_release` run happens at publish time.

**The `changelog-base` cursor**: a tag *without* the `v` prefix, so `cog` ignores it for versioning (`tag_prefix = "v"`). Feature notes come from `changelog-base..HEAD`, so interleaved hotfix `v*` tags don't make the draft lose accumulated features. Because nothing runs at publish, the cursor **self-advances in the draft flow**: before recomputing the draft, `_release (draft)` moves `changelog-base` up to the latest **published feature (minor/major)** `v*` tag (patch/hotfix tags are skipped). De-dup **by type**: hotfix Releases carry the `fix:` they ship; feature Releases carry `feat:`/breaking plus any `bugfix/*` `fix:` not already shipped by a hotfix.

**Constraints of the no-publish-workflow shape**: the asset is built at draft time with the *pending* version, so the maintainer must not edit the version on the publish form (re-cut instead); and the cursor is only advanced on the next draft run, which is fine because nothing reads it in between.

**Concurrency**: `main.yml` and `publish.yml` share a `concurrency: release` group so tag creation and cursor moves never race; tag creation is atomic, so two releases cannot both mint `vX`.

## Release identity

**No release bot is needed.** Since releases only create a tag and a GitHub Release — never a commit or PR against the protected `main` — the workflow's default `GITHUB_TOKEN` (`contents: write`, plus `pages: write`/`id-token: write` for docs) is sufficient. This drops the earlier `release-bot` GitHub App and its secrets, and keeps CI free of the one JS token-minting action, so the no-Node rule (ADR-0002) holds in CI too.

## Feature-flag dependency (note only)

Trunk-based development means incomplete work merges to `main` dormant behind flags. To keep `cog` honest, incomplete work lands under **non-releasable commit types** (`chore`/`refactor`/…), and the releasable `feat:`/`fix:` commit that flips a flag on lands only when the feature is ready. The **flag mechanism itself is out of scope here** and is designed in a separate issue/ADR (tracked for milestone "M1: Project infrastructure").

## Target file layout

```text
.github/
├── actions/
│   └── setup/action.yml         # composite: placeholder (echo); #4 adds brew bundle + cache
├── dependabot.yml               # github-actions ecosystem, weekly
└── workflows/
    # Reusable workflows use a leading "_" so they group together and sort
    # above the event orchestrators (GitHub forbids subfolders here).
    ├── _gate-commit-lint.yml    # workflow_call → setup + placeholder (#4: cog check)
    ├── _gate-branch-lint.yml    # workflow_call → setup + just brlint (Git Flow names, CI backstop) (#5, landed)
    ├── _gate-code-lint.yml      # workflow_call → setup + placeholder (#6: ShellCheck)
    ├── _gate-format-check.yml   # workflow_call → setup + just fmt (shfmt + .editorconfig) (#7, landed)
    ├── _gate-test.yml           # workflow_call → setup + placeholder (#8: ShellSpec)
    ├── _gate-generate-docs.yml  # workflow_call → setup + placeholder (#9: mdBook build)
    ├── _deploy-docs.yml         # workflow_call → setup + placeholder (#9: mdBook build + Pages deploy; runs on release)
    ├── _release.yml             # workflow_call (input: draft) → placeholder (#10: draft update+cursor / hotfix patch+publish)
    ├── pr.yml                   # on: pull_request → calls all gates
    ├── main.yml                 # on: pull_request closed (merged) → router: hotfix/* → release(draft:false)+deploy-docs; else → release(draft:true)
    └── publish.yml              # on: release published → calls deploy-docs only
```

`.coderabbit.yaml` lives at the repo root. All workflow files ship now as valid, running **placeholders** so the pipeline executes end-to-end and every check appears on a PR (proving the wiring); none are added to required checks until its slice replaces the placeholder with real logic.

## Flow

```mermaid
flowchart TD
    A["Open PR (feature/*, bugfix/*, hotfix/*)"] -->|pr.yml runs all gates| B{Gates green?}
    B -- no --> A
    B -- yes --> C["Rebase-merge into main"]
    C -->|"main.yml router (PR closed), concurrency: release"| R{"head.ref prefix?"}
    R -- "hotfix/*" --> HF["_release (draft:false): cog patch -> tag vX at HEAD<br/>+ Release scoped to the PR (no cursor move)"]
    HF --> J["deploy-docs: publish Pages"]
    R -- "feature/* or bugfix/*" --> D["_release (draft:true): advance changelog-base to last feature tag<br/>update draft notes from changelog-base..HEAD + attach asset"]
    D -.->|more work lands| C
    F["Click native 'Publish release' on the draft"] -->|"GitHub tags + publishes; asset carries over"| P["publish.yml (release: published)"]
    P --> J
```

## Considered Options

- **Single mega-workflow** with all gates inline: rejected — not reusable, and a change to one gate churns the whole file. Per-gate reusable workflows keep each gate an independent, composable unit.
- **One file per gate without `workflow_call` reuse**: rejected — orchestrators could not compose them across PR/main/publish events without duplicating job bodies.
- **macOS runners**: rejected — no gate needs macOS; `ubuntu-latest` is faster and cheaper. (Product runtime targeting macOS/Bash 3.2 is a separate concern from where lint/test run.)
- **Squash or merge-commit merges**: rejected — squash discards the Conventional Commit granularity `cog` relies on for versioning/changelog; merge commits break linear history and bisection.
- **Committed `VERSION` as the source of truth** (the earlier #4 model, bumped before the tag): rejected — it duplicates the version the tag already encodes, and two copies drift. Under trunk protection the bump also has to reach `main` somehow (a merged release PR + a privileged bot, or a tag-move after the native button), adding a race window and a JS token-minting action. The tag-as-source model deletes all of that.
- **GitHub App (`release-bot`) / PAT to push the release commit**: rejected together with committed `VERSION` — needed *only* because a release had to write to the protected `main`. With releases that only tag + publish, no bot, secret, or PR is required; the default `GITHUB_TOKEN` suffices.
- **Standing `chore(release)` PR** (the original #10 model): rejected in favor of a draft Release, which needs no long-lived branch and keeps the pending version out of the repo until publish.
- **Actions-tab `workflow_dispatch` "Publish" button**: rejected — the trigger lives in the Actions tab, not the Release page; the maintainer wants to publish from the native Release UI where the accumulated draft lives. (With tag-as-source there is no bump to sequence, so the native button works directly.)
- **Version in the tag, materialized by the installer** (chosen): `cog` recomputes the number from `v*` tags at release time, the build stamps it into the asset, and `install.sh` writes `~/.cli-setup/VERSION` from that stamped metadata. Offline installs still work because the number travels *inside the asset*, not via `.git`. Changelog lives only in the Releases. One home per fact, no push to `main`, no bot.
- **Code-review tools**: Cursor Bugbot (a real gate but paid — usage-based + Cursor Business); Claude Code review / Macroscope (checks conclude *neutral*, so they never actually block); Qodo self-host (free engine but paid LLM tokens); Greptile (comments, not a gate). CodeRabbit is the only free-for-public-repos option that produces a genuinely blocking check.

## Consequences

- Adding a new gate is a small, self-contained workflow file plus one line in `pr.yml`; making it required is a separate, deliberate step once it does real work.
- Because required checks can only reference checks that exist, there is a chicken-and-egg ordering: a gate must run at least once on a PR before it can be marked required (documented in the setup runbook).
- The release path needs **no GitHub App, secret, or release PR** — it only creates tags and Releases with the default `GITHUB_TOKEN`. This removes a whole class of manual setup and keeps CI Node-free.
- The version has exactly **one home (the git tag)** and the changelog exactly one (the GitHub Release), so there is nothing to drift or race. The trade is that `install.sh` must stamp/read the version into the asset (a slice-`#4`/installer responsibility) and readers get the changelog from the Releases (or a derived docs page), not a committed `CHANGELOG.md`.
- The `changelog-base` cursor is an extra tag to maintain: the `_release (draft)` flow self-advances it to the latest published feature tag on the next draft update (no publish workflow does it), and tag protection must be scoped to `v*` so the cursor tag stays movable (setup runbook).
- Merging the three release behaviors into one `_release` workflow (input `draft`) removes duplicated boilerplate, but shifts two responsibilities onto the draft flow: it builds/attaches the asset at draft time (so the version must not be edited on the publish form) and it moves the cursor lazily on the next run.
- Hotfix auto-release depends on the `hotfix/*` prefix being used correctly; a fix landed under `feature/*`/`bugfix/*` rides the next feature release instead of publishing immediately (by design).
- CodeRabbit's directory-scoping means our standards must be maintained in `.coderabbit.yaml` instructions (or a future generated carrier), not only in `.agents/`; this is a small duplication surface to watch.
