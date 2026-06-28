# Acceptance verification is the source of truth for AC checkboxes

The `verify-acceptance` skill judges each acceptance criterion against the branch diff and rewrites the issue's checkboxes to match its verdict on every run — ticking met criteria and, crucially, **unticking** any box whose criterion is no longer satisfied. We chose this over treating a human's tick as authoritative, so the boxes always reflect what the diff actually does rather than what someone believed at some past moment.

The trade-off: we give up manual override of the checkboxes (a human tick can be reverted by the next verification) in exchange for boxes that never lie about the current diff, and a gate that can't be passed by pre-checking. Regressions (a box that was `[x]` and is now `[ ]`) are surfaced prominently rather than silently trusted. The report itself is preserved as a single, updated-in-place issue comment so the audit trail lives alongside the criteria.
