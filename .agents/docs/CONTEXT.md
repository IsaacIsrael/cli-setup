# Planning Workflow

The vocabulary the engineering skills use to turn a problem into shippable work: a PRD frames the problem, milestones organize the work into deliverable increments, and issues are the individual slices that implement them.

## Language

**PRD**:
A document that frames the user's problems and the proposed solution, with user stories.
_Avoid_: spec, requirements doc

**Milestone**:
The smallest set of issues that delivers shippable user value — an ordered release increment, where M1 is the thinnest end-to-end product that is already useful.
_Avoid_: epic, sprint, phase

**Issue (tracer bullet)**:
A thin vertical slice that cuts through every layer end-to-end and is verifiable on its own.
_Avoid_: task, ticket, story

**Acceptance criterion**:
A single verifiable, checkbox condition on an issue that defines "done" for that slice.
_Avoid_: requirement, definition of done, spec item

**Acceptance gate**:
The met/unmet verdict over all of an issue's acceptance criteria, judged against the branch diff; it decides whether a PR opens ready or draft.
_Avoid_: sign-off, approval, QA gate

**Quality gate**:
An executable repository check (e.g. `shellcheck`, `shfmt`, `shellspec`, `cog check`) run as evidence that a criterion holds.
_Avoid_: CI check, test, lint

**Review thread**:
A GitHub conversation anchored to one location on a PR's diff; the atomic unit of resolution, since resolving happens per thread, not per comment.
_Avoid_: comment, remark

**Disposition**:
The classification assigned to an unresolved review thread — one of Address, Respond, or Escalate.
_Avoid_: category, status

**Address**:
A disposition for a review thread whose requested change is valid: the change is implemented, the thread is replied to, and the thread is resolved.
_Avoid_: fix, apply

**Respond**:
A disposition for a review thread that needs no code change: the thread is replied to and left open.
_Avoid_: answer, dismiss

**Escalate**:
A disposition for a review thread that needs a human decision: the thread is flagged to the user and left open.
_Avoid_: defer, punt

**Clear**:
The state in which every review thread on a PR has reached a decided outcome — resolved or replied to.
_Avoid_: triage, sweep

---

# cli-setup

The application this repo ships: a native Bash CLI for macOS that diagnoses, installs, and reconciles a developer's environment.

## Language

**Tool**:
A self-describing, reusable unit that knows how to check for and install one piece of the environment (e.g. Node, Xcode, Watchman).
_Avoid_: package, dependency, module

**Blocking dependency**:
A dependency whose failure stops its dependents from running; the dependents are skipped with a stated reason while independent branches continue.
_Avoid_: hard dependency, required tool

**Profile**:
A named selection of tools that defines an environment to set up (e.g. `mobile`).
_Avoid_: preset, template, bundle

**Environment**:
The set of tools and shell configuration a developer needs to build a given kind of project.
_Avoid_: setup, stack

**Plan**:
The ordered set of tools a run will act on, resolved from the profile's dependency graph and shown as a dependency tree before anything is applied.
_Avoid_: batch, queue, list

**Team config** (a.k.a. **config dist**):
An optional JSON document, published at a URL, that a team uses to pin tool versions and customize a profile.
_Avoid_: settings, manifest, profile

**Version resolution**:
The layered precedence that decides which version of a tool to install (flag > project file > team config > profile override > tool default).
_Avoid_: version selection, version picking

**Drift**:
A divergence between an installed tool and the version or selection the team config expects.
_Avoid_: mismatch, out-of-date

**Managed block**:
The single demarcated, reversible region that cli-setup owns inside the user's `~/.zshrc`.
_Avoid_: shell config, dotfile edits

**Idempotency**:
The property that re-running setup only touches what is still missing, so a run after a failure resumes with no separate state to manage.
_Avoid_: retry, rerun

**Doctor**:
The read-only command that diagnoses the environment and reports status and drift.
_Avoid_: check, diagnose

**Setup**:
The command that installs and adjusts the missing tools for a profile.
_Avoid_: install, provision

**Update**:
The command that reconciles installed tools to the team config.
_Avoid_: upgrade, sync

**Config**:
The command that manages the team config (`set-team`/`show`/`refresh`).
_Avoid_: settings

---

# Releases

The vocabulary of the tag-sourced release model (ADR 0010): the git tag is the single source of truth, and a release only creates a tag and a GitHub Release.

## Language

**Release asset**:
The `.tar.gz` the release build produces and attaches to a GitHub Release — a copy of the installable payload with the version stamped into a bundled `VERSION` file.
_Avoid_: artifact, bundle, package

**Feature release**:
A release that bumps at least a minor (`vX.Y.0`), cut on demand by publishing the accumulating draft Release.
_Avoid_: minor release, main release

**Hotfix release**:
A patch release (`vX.Y.Z`, Z>0) auto-published when a `hotfix/*` branch merges, with notes scoped to that PR.
_Avoid_: patch release, emergency fix

**Pending version**:
The floating version a draft Release previews; recomputed on every merge and only minted as a real tag when the draft is published.
_Avoid_: next version, draft version

**Shipped-SHAs marker**:
The hidden HTML comment in a hotfix Release body listing the commit SHAs it published, read by the feature flow to de-dup those commits from the next draft's notes.
_Avoid_: changelog marker, commit list
