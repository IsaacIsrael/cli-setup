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

---

# cli-setup

The application this repo ships: a native Bash CLI for macOS that diagnoses, installs, and reconciles a developer's environment.

## Language

**Tool**:
A self-describing, reusable unit that knows how to check for and install one piece of the environment (e.g. Node, Xcode, Watchman).
_Avoid_: package, dependency, module

**Profile**:
A named selection of tools that defines an environment to set up (e.g. `mobile`).
_Avoid_: preset, template, bundle

**Environment**:
The set of tools and shell configuration a developer needs to build a given kind of project.
_Avoid_: setup, stack

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
