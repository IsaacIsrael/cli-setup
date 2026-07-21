# HTML Report Format

The effort-impact triage is rendered as a single self-contained HTML file in the OS temp directory — never in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/leftover-triage-<timestamp>.html` so each run gets a fresh file. Open it (`open` on macOS, `xdg-open` on Linux, `start` on Windows) and tell the developer the absolute path.

The report is a **proposal for review**, not a record of action: it shows the classification and proposed routing that the developer approves (or adjusts) at the confirmation gate. Nothing has been executed when it opens.

## Always use the template

**Do not freehand the HTML.** Copy [`report.template.html`](./report.template.html) and substitute every `{{TOKEN}}`. Keep the scaffold, CSS classes, Mermaid init, section order, and dark palette exactly as in the template — only token values and repeated card/pie lines change.

Generation steps:

1. Read `report.template.html` from this skill directory.
2. Build the token values (cards, pie lines, footer note).
3. Write the filled file to `$TMPDIR/leftover-triage-<timestamp>.html`.
4. Open it and show the absolute path.
5. Capture a **tall-viewport PNG** of the report (matrix + pies + footer) with **Google Chrome headless** — do **not** use `npx playwright`. Chrome is declared in the repo [`Brewfile`](../../../Brewfile) (`cask "google-chrome" if OS.mac?`); ensure it is present via `just install` / `brew bundle`.

   On macOS the cask installs **only** `Google Chrome.app` — there is **no** `google-chrome` binary on `PATH`. Always call the app binary (quote the path; it contains spaces):

   ```bash
   CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
   # Linux only (if present): CHROME=$(command -v google-chrome || command -v google-chrome-stable)
   "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
     --virtual-time-budget=8000 --window-size=1280,2500 \
     --screenshot="$TMPDIR/leftover-triage-<timestamp>.png" \
     "file://$TMPDIR/leftover-triage-<timestamp>.html"
   ```

   Chrome's CLI `--screenshot` is viewport-sized (not full-page scroll capture). Start at **`1280,2500`** — tall enough for a typical leftover report without a huge empty band under the pies. If the footer/pies are clipped, bump height in ~200px steps and re-capture; if there is a large empty dark region at the bottom, the window was too tall — lower it and re-capture. If the `.app` is missing, stop and ask the developer to run `just install` (or `brew bundle`) — do not invent a screenshot or skip the image.
6. After the developer approves routing, upload that PNG **before** posting the decision-report: `gh image <png> --repo <owner/repo>` (install `gh extension install drogers0/gh-image` if needed), then include the printed markdown image in the **single** `gh issue comment` for that triage run (see SKILL.md — no follow-up comment for the screenshot). Prefer `GH_SESSION_TOKEN` from `gh image extract-token` when the default browser cookie extract fails.

## Tokens

| Token | Value |
| --- | --- |
| `{{MILESTONE}}` | Milestone title |
| `{{DATE}}` | ISO date (`YYYY-MM-DD`) |
| `{{ITEM_COUNT}}` | Total leftover items scored |
| `{{QUICK_WIN_CARDS}}` | Matrix cards for ⚡ (or empty-state) |
| `{{REAL_WIN_CARDS}}` | Matrix cards for 🏆 |
| `{{NICE_WIN_CARDS}}` | Matrix cards for 🍬 |
| `{{TIME_SINK_CARDS}}` | Matrix cards for 🕳️ |
| `{{PIE_BY_ROUTE}}` | Mermaid pie rows for destinations |
| `{{PIE_BY_QUADRANT}}` | Mermaid pie rows for quadrants |
| `{{FOOTER_NOTE}}` | Optional reclassification note (or empty string) |

## Card snippets (required shapes)

**Matrix item card** — full title + one-line reason + route badge. Prefer cards over plot dots so labels never overlap.

```html
<div class="item-card">
  <p class="text-sm font-medium">CI: Node 20 deprecation</p>
  <p class="text-xs text-zinc-300 mt-0.5">Bump pinned actions; clears runner warnings</p>
  <span class="route-badge badge-ref">Refinement</span>
</div>
```

Route badge classes:

- Refinement → `badge-ref`
- Graduate → `badge-grad` (label e.g. `Graduate → M2`)
- Discard → `badge-disc`

**Empty quadrant:**

```html
<p class="empty">None</p>
```

## Pie lines

Each pie token is one or more indented Mermaid rows (omit zero slices):

```text
    "Refinement" : 6
    "Graduate → M2" : 8
    "Discard" : 2
```

```text
    "Quick win" : 4
    "Real win" : 8
    "Nice win" : 4
```

## Layout contract (do not redesign)

1. **Header** — milestone, date, item count, four-quadrant legend. No intro paragraph.
2. **Effort–impact matrix** — hand-built 2×2 of **item cards** (not Mermaid `quadrantChart` dots). No axis labels — each quadrant header already states effort/impact. Quadrants: top-left ⚡ Quick win, top-right 🏆 Real win, bottom-left 🍬 Nice win, bottom-right 🕳️ Time sink. Coloured cells come from the template CSS (`.quad-quick` / `.quad-real` / `.quad-nice` / `.quad-sink`). Route badges on each card carry the proposed destination.
3. **Distribution pies** — two Mermaid `pie showData` charts (by route, by quadrant). Mermaid stays dark + colourful via the template's `themeVariables`.

Use the glossary's quadrant names verbatim. Dark mode only — never light, never system-preference.
