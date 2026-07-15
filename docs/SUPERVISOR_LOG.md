# Supervisor Log — Penfold overnight run

**Started:** 2026-07-15  
**Baseline:** origin/main at v0.2.12 (user stable: v0.2.6)  
**Ground rules:** local/offline, SQLite, MIT — zero cloud/accounts/payments

## Status table

| Version | Feature | Status | Tests | Commit |
|---------|---------|--------|-------|--------|
| 0.2.13 | Export crash fix (OOM, progress, lazy PDF, error snackbar) | **DONE** | 52/52 pass | `6f2bdad` |
| 0.2.14 | Full-database backup + restore | PENDING | — | — |
| 0.2.15 | Page bookmarks + quick jump | PENDING | — | — |
| 0.2.16 | Tags on notebooks | PENDING | — | — |
| 0.2.17 | Vector PDF export (roadmap 0.2.12) | PENDING | — | — |

## Already on main (pre-run)

| Version | Feature | Status |
|---------|---------|--------|
| 0.2.7 | Toolbar polish | DONE |
| 0.2.8 | On-device OCR search | DONE |
| 0.2.9 | Partial eraser | DONE |
| 0.2.10 | Ink coalescing / perf | DONE |
| 0.2.11 | Lazy PDF import | DONE |
| 0.2.12 | Pinch zoom fix | DONE |

## Phase 0 — Export fix (v0.2.13)

**Root cause:** `exportNotebook` rendered all pages at 2× resolution into memory before building PDF (~100 MB/page → OOM on multi-page notebooks).

**Fix:**
- `buildNotebookPdfBytes` — incremental page-by-page PDF build with dispose + event-loop yield between pages
- Lazy PDF backgrounds via `PdfPageCache` (not only legacy `pdfImagePath`)
- Progress dialog in `notebook_screen.dart`
- Share errors caught and shown as snackbar

**Deliverables:**
- APK: `APKs/Penfold-v0.2.13-arm64.apk` (local, gitignored)
- Pushed to `main`

## Phase 1 — Next up

Dependency order from roadmap (adjusted after export fix):
1. **0.2.14** backup + restore (`backup_service.dart`)
2. **0.2.15** bookmarks (schema field exists; UI missing)
3. **0.2.16** tags
4. **0.2.17** vector PDF export (deferred from original 0.2.12 slot)

## Notes

- Do **not** re-apply broken 0.2.7 toolbar rewrite or untested page_viewport zoom changes.
- Page layout must stay centered; ink on paper.
