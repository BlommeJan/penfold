# Changelog

All notable changes to Penfold are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/).

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

[0.2.7]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.7
[0.2.6]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.6
[0.2.5]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.5
[0.2.4]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.4
[0.2.3]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.3
[0.2.2]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.2
[0.2.1]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.1
[0.2.0]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.0
[0.1.0]: https://github.com/BlommeJan/penfold/releases/tag/v0.1.0
