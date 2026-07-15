# Changelog

All notable changes to Penfold are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [0.2.18] — 2026

### Added

- **Vector PDF export** — pen and highlighter strokes emit as vector paths via the `pdf` package; highlighter uses multiply blend + opacity layer; fills, images, PDF backgrounds, and text blocks remain raster; page-by-page `buildNotebookPdfBytes` memory-safe flow preserved

## [0.2.17] — 2026

### Added

- **Tags on notebooks** — `tags` and `notebook_tags` tables (schema v8); tag chips in library filter row; edit tags from notebook long-press menu; DB helpers: `createTag`, `deleteTag`, `tagsOfNotebook`, `setNotebookTags`, `notebooksWithTag`

## [0.2.16] — 2026

### Added

- **Page bookmarks + quick jump** — bookmark toggle in page settings (existing); prev/next bookmark buttons in editor toolbar; bookmark icon overlay on page overview thumbnails

## [0.2.15] — 2026

### Fixed

- **Text rotation** — selection-tool rotate handle now rotates typed text glyphs, not just the bounding box; rotation persists in SQLite (`text_blocks.rotation`, schema v7) and survives undo/redo

## [0.2.14] — 2026

### Added

- **Full-database backup** — export zip of `penfold.db`, `pdf_sources/`, `images/`, and legacy `pdf_pages/` via share sheet
- **`backup_service.dart`** — local zip create/extract with pre-restore DB safety copy in `backups/`
- **Backup & Restore settings** — library app bar → settings icon; confirm dialog before restore; restart prompt after restore

## [0.2.13] — 2026

### Fixed

- **Export crash** — full-page and full-notebook export no longer OOM-crash on large notebooks; PDF built page-by-page with memory cleanup between pages
- **Export progress** — blocking progress dialog during export with per-page status for multi-page notebooks
- **Lazy PDF export** — notebook export renders lazy-imported PDF backgrounds via `PdfPageCache` instead of missing backgrounds
- **Export errors** — share failures surface as snackbar messages instead of silent crashes

## [0.2.12] — 2026

### Fixed

- **Pinch zoom** — finger pinch-to-zoom now works reliably in stylus-only and finger-drawing modes, on paper and margin; stylus + two-finger pinch can zoom simultaneously
- **`PageViewport`** — scale gesture always active; no longer blocked when stylus is down if 2+ touch pointers; late pinch start on paper in finger mode
- **`DrawGestureShield`** — rejects multi-touch so ancestor scale recognizer wins; brief defer before claiming single-finger scroll block
- **`notebook_screen`** — disables vertical scroll while page pinch/pan gesture is active

## [0.2.11] — 2026

### Added

- **Lazy PDF import** — stores source PDF once (`pdf_sources/`) with per-page `pdf_source_path` + `pdf_page_index` (schema v5); pages render on demand
- **`pdf_page_cache.dart`** — LRU in-memory cache (4 pages) with loading placeholder in page editor

## [0.2.8] — 2026

### Added

- **On-device handwriting OCR search** — ML Kit text recognition (no network); strokes queued on commit into `ink_index` table (schema v4); indexed ink merged into FTS notebook search
- **`ink_ocr_service.dart`** — background OCR queue with stroke-to-PNG rendering
- **Page overview OCR badges** — pending / indexed / partial indicators per thumbnail

## [0.2.10] — 2026

### Added

- **Ink coalescing** — adaptive min-distance sampling on pointer move reduces point count at high speed without visible gaps
- **`ink_coalesce.dart`** — speed-aware gap logic + `test/ink_perf_test.dart` benchmark harness
- **`docs/RELEASE_CHECKLIST.md`** — Tab S6 Lite + flagship ink latency targets

### Changed

- **RepaintBoundary** — isolates page background vs ink layer and per-page editor for smoother scroll

## [0.2.9] — 2026

### Added

- **Partial eraser** — pixel/stroke-splitting eraser clips ink at the eraser circle instead of deleting whole strokes; toggle Pixel vs Stroke mode in eraser options sheet
- **`stroke_eraser.dart`** — geometry service for polyline clipping with circle intersections; `_ErasePartial` undo action

## [0.2.7] — 2026

### Changed

- **Toolbar** — GoodNotes-style layout: back (left), centered tool row with rounded selected states, undo/redo + page actions (right); brush picker in tinted pill when pen active; subtle group dividers
- **Theme** — richer brand blue (#2455C3) on chips, FAB, toolbar accents, and selection handles
- **Library** — more vibrant notebook cover gradients and filter chips

## [0.2.6] — 2026

### Fixed

- **Toolbar** — gear icon (rightmost) opens page settings sheet directly; removed intermediate popup menu and top-right page indicator (`3/12`)

## [0.2.5] — 2026

### Added

- **Export** — page settings sheet: export current page as PNG or PDF; export full notebook as multi-page PDF
- **Sharing** — exports open the Android share sheet (save, send, etc.) via `share_plus`

## [0.2.4] — 2026

### Added

- **Toolbar** — insert image moved to center tool row; horizontal brush picker (pen, fountain, pencil, marker, calligraphy)
- **Fill** — tap inside a closed pen/shape loop to flood-fill; drag still draws a fill boundary

### Fixed

- **Selection** — scale/rotate handles (finger input in stylus-only mode, larger hit targets, image bounds)
- **Text** — blocks auto-size to content with improved canvas typography

## [0.2.3] — 2026

### Added

- **Page overview** — proper mini-render thumbnails (strokes, fills, text, PDF); denser responsive grid (4–8 columns)
- **Toolbar** — GoodNotes-style layout: back (left), tools + undo/redo (center), settings/add/stylus/overview + `3/12` indicator (right)
- **Selection tool** — marquee tap/drag select with move, scale, and rotate handles (separate from lasso loop)
- **Text tool** — Done button + keyboard confirm; persists `TextBlock` to DB; tap existing text to re-edit

### Fixed

- **Finger drawing** — finger ink on scrolled-to pages (`DrawGestureShield` blocks scroll from stealing paper touches)

## [0.2.2] — 2026

### Added

- **Library** — notebook title on cover; new-notebook app-bar button; compact filter + folder chip row
- **Icon** — redesigned app icon (notebook with binding, ruled lines, pen silhouette)
- **Docs** — release APK deliverables convention: ship builds as `APKs/Penfold-v{version}-arm64.apk`

### Fixed

- **Search** — FTS4 crash (`rank` is FTS5-only); backend-specific queries with LIKE fallback
- **Zoom** — pinch-to-zoom compounding scale each frame
- **Stylus** — finger pinch/pan works in stylus-only mode while pen hovers; stylus cannot scroll pages or pan/zoom

## [0.2.1] — 2026

### Added

- Nested folders (`parent_id`), breadcrumb drill-down, subfolder creation
- Library UI polish: search bar, All/Uncategorized filters, folder chips
- Minimal line-art app icon on brand blue (#2455C3)

### Fixed

- Infinite library spinner on Android (FTS5 → FTS4/LIKE fallback; resilient DB migration)

## [0.2.0] — 2026

### Added

- Canonical page coordinates (rotation-stable ink)
- Gated pan/zoom with stylus and margin rules
- Vertical scroll + page overview grid
- A4 / A5 / Letter page sizes + college ruled template
- Fountain pen, pencil, fill, text tools; lasso copy/paste
- Library folders + FTS search
- Custom notebook + pen app icon

## [0.1.0] — 2026

### Added

- Initial release: pen, highlighter, eraser, lasso, shapes, PDF import

[0.2.18]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.18
[0.2.17]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.17
[0.2.16]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.16
[0.2.15]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.15
[0.2.14]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.14
[0.2.13]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.13
[0.2.7]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.7
[0.2.6]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.6
[0.2.5]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.5
[0.2.4]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.4
[0.2.3]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.3
[0.2.2]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.2
[0.2.1]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.1
[0.2.0]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.0
[0.1.0]: https://github.com/BlommeJan/penfold/releases/tag/v0.1.0
