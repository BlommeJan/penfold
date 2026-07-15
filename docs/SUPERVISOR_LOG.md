# Supervisor Log — Penfold overnight run

**Started:** 2026-07-15  
**Resumed:** overnight autonomous run  
**Ground rules:** local/offline, SQLite, MIT — zero cloud/accounts/payments

## Version renumbering note

Original roadmap versions 0.2.7–0.2.12 largely shipped pre-run. Post-run versions assigned sequentially from 0.2.13. Roadmap item → shipped version mapping in **Remaining queue** below.

## Status table

| Version | Feature | Roadmap ref | Status | Tests | Commit |
|---------|---------|-------------|--------|-------|--------|
| 0.2.13 | Export crash fix | — | **DONE** | 52/52 | `6f2bdad` |
| 0.2.14 | Full-database backup + restore | 0.2.13 | **DONE** | 54/54 | `d31e633` |
| 0.2.15 | Text rotation bug fix | backlog | **DONE** | 59/59 | `3a9f668` |
| 0.2.16 | Page bookmarks + quick jump | 0.2.14 | **DONE** | 62/62 | `fe74e69` |
| 0.2.17 | Tags on notebooks | 0.2.15 | **DONE** | 67/67 | `0ed4d9e` |
| 0.2.18 | Vector PDF export | 0.2.12 | IN PROGRESS | — | — |
| 0.2.19 | Toolbar tool order customization | 0.2.16 | PENDING | — | — |
| 0.2.20 | Tape / hide-reveal | 0.2.17 | PENDING | — | — |
| 0.2.21 | Per-page template/size | 0.2.18 | PENDING | — | — |
| 0.2.22 | Mixed-orientation pages | 0.2.19 | PENDING | — | — |
| 0.2.23 | Audio + stroke timestamps | 0.2.20 | PENDING | — | — |
| 0.2.24 | OCR custom dictionary | 0.2.21 | PENDING | — | — |
| 0.2.25 | Notebook library thumbnails | 0.2.23 | PENDING | — | — |
| 0.2.26 | Lasso rotate handles | 0.2.24 | PENDING | — | — |
| 0.2.27 | Stroke smoothing toggle | 0.2.25 | PENDING | — | — |
| 0.2.28 | S Pen button settings | 0.2.26 | PENDING | — | — |
| 0.2.29 | Session persistence | 0.2.27 | PENDING | — | — |
| 0.2.30 | Page overview reorder + batch delete | 0.2.28 | PENDING | — | — |
| 0.2.31 | PDF text search at import | 0.2.29 | PENDING | — | — |
| 0.2.32 | PDF hyperlinks read-only | 0.2.30 | PENDING | — | — |
| 0.2.33 | Page-turn scroll mode | 0.2.31 | PENDING | — | — |
| 0.2.34 | Page-level audio MVP | 0.2.32 | PENDING | — | — |
| 0.2.35 | Gesture ink editing | 0.2.33 | PENDING | — | — |
| 0.2.36 | Auto table of contents | 0.2.34 | PENDING | — | — |
| 0.2.37 | HWR convert selection | 0.2.35 | PENDING | — | — |
| 0.2.38 | Page complexity warning | 0.2.36 | PENDING | — | — |
| 0.2.39 | Your data settings screen | 0.2.37 | PENDING | — | — |
| 0.2.40 | Undo persist on page switch | 0.2.38 | PENDING | — | — |

## Deferred / non-code (not in overnight queue)

| Roadmap | Item | Reason |
|---------|------|--------|
| 0.2.22 | Play Store listing | Marketing/docs only |
| 0.2.39 | Markdown OCR export | → stretch goal after 0.2.40 |
| 0.2.40 | Math LaTeX | Low priority; evaluate after core |

## Already shipped (pre/post run)

| Version | Feature |
|---------|---------|
| 0.2.7 | Toolbar polish |
| 0.2.8 | On-device OCR search |
| 0.2.9 | Partial eraser |
| 0.2.10 | Ink coalescing / perf |
| 0.2.11 | Lazy PDF import |
| 0.2.12 | Pinch zoom fix |

## Stability rules

- Do **not** re-break page layout/zoom like 0.2.7–0.2.12 regressions
- Page layout centered; ink on paper
- Test page centering, zoom, scroll after viewport/toolbar changes

## APK deliverables

| Version | Path |
|---------|------|
| 0.2.13 | `APKs/Penfold-v0.2.13-arm64.apk` |
| final | TBD at run end |
