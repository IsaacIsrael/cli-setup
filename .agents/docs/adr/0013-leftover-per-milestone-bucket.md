# Leftover: per-milestone bucket + effort-impact triage

Tech debt and lateral changes noticed mid-work should derail neither the current issue nor the milestone, so we park them in a **Leftover** — one container issue per milestone (labelled `leftover`, a content type with no triage roles), created lazily on the first item. Each item is a checklist line; the agent stages captures under `.scratch/` (ADR 0007) and flushes them into the container in one batch at work wrap-up. At the end of the milestone, **effort-impact triage** scores every item on effort (a soft ~1h "aggregatable" anchor) against impact (user-facing, unblocks future work, or reduces risk) and sorts it into a quadrant: ⚡ quick win → the milestone's Milestone refinement issue; 🏆 real win → judgment call (address now, or graduate to its own tracer-bullet issue in a later milestone); 🍬 nice win → address if time, else discard; 🕳️ time sink → discard. Refinement and graduated issues then follow the normal issue flow. The agent never executes a routing decision, and never closes a milestone, without human confirmation via the ask modal.

## Considered Options

- **One issue per leftover item**: rejected — filing a full tracer-bullet issue mid-work is itself a derail; a per-milestone bucket keeps capture trivial and defers the graduation decision to review.
- **Fold leftover triage into `/triage`**: rejected — issue triage (a state machine) and effort-impact triage (a scoring evaluation) are different in kind; a router (`/triage`) over two leaf skills (`/triage-issue`, `/triage-leftover`) keeps each cohesive.
- **Tracker-agnostic tooling**: out of scope — GitHub-only for now (issue form, labels, milestones); this repo is GitHub.

## Consequences

- **`triage` is repurposed.** `/triage` becomes the router and the issue state machine moves to `/triage-issue`. `triage` was the mattpocock-pack skill name, so a future re-import of that pack could drop a fresh `triage` (issue flow) alongside our `triage-issue` — a re-import must know the issue state machine now lives in `triage-issue`.
- **"triage" is always qualified** in docs and skills — *issue triage* vs *effort-impact triage*, never bare.
- Effort-impact triage applies to leftovers only, not normal issues.

Refs: ADR 0007 (`.scratch/` for ephemeral artifacts).
