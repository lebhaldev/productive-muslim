# 05 — Design sync

## Why this exists
The design is made in Claude Design (`Nurday.dc.html`) by a separate agent that this project cannot reach directly. The two agents coordinate through the user and through this file.

## Rules
- DS-1 **Design wins on look and layout**: colours, type, order of sections, labels, copy. The specs update to match.
- DS-2 **Specs win on rules**: content-sourcing (CR-x), privacy, offline, data model. If a design breaks one, it is flagged back to the design agent, not silently built.
- DS-3 Anything not visible in a design is an open question below, never invented.
- DS-4 Every sync adds a dated snapshot to `design/` and a row to the sync log.

## How to sync (the user's part)
1. When the design agent finishes a change, either export/download `Nurday.dc.html` or take screenshots of every changed screen.
2. Drop them in the Nurday specs thread with "design updated".
3. Claude diffs them against the specs, updates 01/03 (and 02 if data changes), logs it below, and lists any rule conflicts to pass back.
4. To pass decisions back to the design agent, paste the "Message for the design agent" block Claude gives you into Claude Design.

## Sync log

| Date | Design input | What changed in specs |
|---|---|---|
| 2026-10-05 | Screenshot of Today (hadith → journal) + design agent notes | Initial specs. Palette switched to sage/terracotta, no gold. Placeholders for scripture confirmed as intended. |
| 2026-10-05 | Reviewer thread findings (review/01, review/02) | No grading line (source has none); no "App summary" until a person reviews notes; offline ayah labelled "Last saved ayah"; The Clear Quran hidden until licence and endpoint confirmed (spec rule wins over design, DS-2); 120 hadith incl. Sahih Muslim without links. |
| 2026-10-05 | Full export `design/2026-10-05-Nurday.dc.html` (all tabs) | 01 rewritten to v0.2 with every screen; 03 tokens mapped to Organic DS names; OQ-1–8, 13, 14 closed. |

## Conflicts between brief and design (resolved)
- Palette: brief said deep green + gold; design uses sage + terracotta, no gold → **design wins**.

## Open questions

Closed by the 2026-10-05 export: OQ-1 (header + weather chip + ayah card), OQ-2 (Habits, Calendar, Journal), OQ-3 (More → Activities, Reflect, Settings), OQ-4 (labels shown), OQ-5 (expanded card), OQ-6 (selected mood), OQ-7 (activity form), OQ-14 (weather chip on Today).

| ID | Question | Default used in build |
|---|---|---|
| OQ-8 | First-install empty states beyond "Nothing logged yet." | Plain text prompts in the same style |
| OQ-9 | Organic DS exact hex values and heading font | Sampled hex, Fraunces |
| OQ-10 | Dark theme | Light only until designed |
| OQ-11 | Default translation | Saheeh International (`en.sahih`); The Clear Quran selectable |
| OQ-12 | Hadith dataset and licence | Bundled subset with sunnah.com references |
| OQ-13 | Daily ayah pool | Curated list of ayah references, text fetched from AlQuran Cloud |
| OQ-15 | How a per-habit reminder time is set | Tap the "No reminder" line to pick a time |
| OQ-16 | Greeting by time of day | Good morning / afternoon / evening |
| OQ-17 | Does hiding faith cards also hide the quote? (in design: yes) | Follow design: hides all three |
| OQ-18 | Confirm before deleting a habit | Confirm dialog |
| OQ-19 | Can an activity be logged for a past day? | Today only, as in design |
| OQ-20 | "Use my location" button for weather | Small button next to City override |
