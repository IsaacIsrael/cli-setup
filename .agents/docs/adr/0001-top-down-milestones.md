# Top-down milestones with allocation at issue creation

We derive milestones top-down from a PRD's user stories (`to-milestones` groups coherent stories into an ordered release sequence, M1 being the thinnest useful product) and have `to-issues` slice one milestone at a time, attaching each issue to its milestone at creation time. We chose this over generating the whole backlog up front and grouping issues into milestones afterwards.

The trade-off: we give up an up-front view of the distant backlog in exchange for issues that don't go stale before they're started and for never having an orphan (milestone-less) issue. This changes the `to-issues` contract — it must be milestone-aware — and adds a consistency rule: an issue's "Blocked by" may not point at a later milestone.
