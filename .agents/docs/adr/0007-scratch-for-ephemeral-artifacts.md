# Ephemeral agent artifacts live in a gitignored `.scratch/`

Skills that generate runtime artifacts which should not be committed — notably the `teach` learning workspace (`MISSION.md`, `lessons/`, `reference/`, `learning-records/`, `assets/`) — write them under the gitignored `.scratch/` directory at the repo root. The vendored `teach` skill is locally forked to use a per-topic directory `.scratch/<topic>/` as its workspace, instead of "the current directory", so its output never lands in version control or in `.agents/`, which is reserved for agent guidance (skills, rules, docs, activities), not study content. Skills that already write to the OS temp directory (`handoff`, `improve-codebase-architecture`) or that create throwaway code deleted on completion (`prototype`, `diagnosing-bugs`) need no special handling.

## Considered Options

- **Put generated assets under `.agents/`**: rejected — per `layout.md`, `.agents/` holds agent guidance, not personal learning content or ephemeral scratch.
- **Gitignore generic output names (`lessons/`, `reference/`)**: rejected — too broad; would clash with real project directories. A single scoped `.scratch/` is safer.
- **Keep `teach` writing to the current directory and rely on a convention**: rejected — the skill text would still say "current directory", so staying out of the repo would depend on the human remembering to `cd` first. Forking the skill to name `.scratch/<topic>/` makes it self-enforcing.

## Consequences

- `.scratch/` is no longer available for the local-markdown issue-tracker convention some vendored skills mention. This repo uses GitHub Issues, so that is moot unless the tracker changes.
- The local `teach` fork diverges from its upstream lockfile hash, like the other repo-fitted skills (`ask-matt`, `review`, `implement`, `improve-codebase-architecture`).
