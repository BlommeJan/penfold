# Changelog

All notable changes to Penfold are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [0.2.69] — 2026

### Fixed

- **Document zoom clip/seam** — stop folding scroll into transform (which blanked lazy slivers); when zoomed, `CustomScrollView` uses `Clip.none` + full-document `cacheExtent` so pinch/pan never hides ink or shows white seams
- **OCR Convert to text** — bridge upstream ML Kit 0.15.0 channel mismatch (`recognizer` vs `recognition`) in `MainActivity`; ProGuard keep rules for ML Kit
- **Stylus-only finger scroll** — document viewport no longer steals single-finger paper scroll at 1×; selection/text/lasso/tape respect `stylusOnly` so finger scroll works for all tools
- **Eraser icon** — clearer GoodNotes-style pink rubber block + grey ferrule at toolbar size

## [0.2.68] — 2026

### Fixed

- **Pinch on paper** — disabled per-page `GestureDetector` when document zoom is active so pinch reaches the document viewport on the page, not only on grey margins
- **Zoom out** — centers the **visible page** when zooming out (not the entire multi-page stack) and prevents zooming past fit-to-page so content never vanishes
- **Eraser icon** — pink angled eraser block with metal sleeve, reads clearly at toolbar size

## [0.2.67] — 2026

### Fixed

- **Document zoom/pan** — transform uses top-left alignment so clamp math matches rendering; scroll offset folds into transform during pinch so zoom works when scrolled; clamp no longer zeroes translation near 1×; body uses actual layout size instead of full screen height

## [0.2.66] — 2026

### Fixed

- **Document zoom/pan** — transform stays scale+translate only (no rotation drift); zoom-out centers the page in the viewport; pinch-to-zoom works on paper in finger-drawing mode; pan clamping no longer shoves content to the left edge
- **Page settings UI** — removed redundant summary from the settings sheet; gear icon opens an anchored popup menu with subcategories (template, size, orientation, TOC, bookmark, audio, split, export)
- **Eraser toolbar icon** — replaced with a recognizable eraser shape

## [0.2.65] — 2026

### Fixed

- **Document zoom UX** — pinch zoom-out down to 0.25×; two-finger pan while pinching; translation clamping so zoomed content stays reachable; double-tap resets to 1×; near-1× snap restores page scroll; transform resets on notebook open

## [0.2.64] — 2026

### Changed

- **Cold start** — always opens the library; session persistence remains for in-notebook restore but no longer auto-navigates to the last notebook on launch
- **Document zoom** — pinch/pan applies to the whole notebook viewport (all pages together) instead of per-page zoom, so other pages stay visible and reachable while zoomed

### Fixed

- **Notebook back** — toolbar and system back pop to the library instead of exiting the app when the notebook was the root route
- **Finger drawing while zoomed** — pointer routing maps viewport coordinates through the document transform so touch ink works in finger-drawing mode when zoom navigation is on
- **Finger drawing while zoomed** — pan/zoom routing maps viewport focal points into paper space so finger ink works at any zoom; two-finger pinch still zooms

## [0.2.63] — 2026

### Fixed

- **Pinch zoom** — scale from gesture-start matrix; lock scroll when second finger lands so pinch wins over page scroll
- **Page layout** — page viewport sized to canonical display dimensions (no stretch inside full-height slot)
- **Rotation** — reset zoom on device rotate and page orientation/size change

## [0.2.62] — 2026

### Added

- **Settings → About** — app name and version at the bottom of Settings (via `package_info_plus`)
- **Library title** — muted version label beside "Penfold" in the app bar

## [0.2.61] — 2026

### Fixed

- **Android SDK** — `compileSdk 36` and `minSdk 23` for ML Kit Digital Ink; release APK builds again

## [0.2.60] — 2026

### Fixed

- **Widget tests** — notebook creation and session-restore tests use reliable editor finders (`Pen` tool, page info chip) and clear session between runs; **248/248** tests green
- **Notebook create** — library now awaits navigation into the new notebook after create
- **Test startup** — `AppHome` skips auto-backup and trash purge when `AppDatabase.overrideDirPath` is set (widget tests)

## [0.2.59] — 2026

### Added

- **Library drawer** — hamburger menu for overview, folders, Trash, and Settings with live trash counts

## [0.2.58] — 2026

### Added

- **Trash screen** — restore or permanently delete trashed notebooks and folders with days-remaining labels
- **Trash retention** — folders gain `deleted_at` and purge runs on app start (30-day retention)
- **Trash tests** — purge and restore coverage in `trash_retention_test.dart`

### Changed

- **Folder deletion** — library folder delete now moves the folder + notebooks into Trash

## [0.2.57] — 2026

### Added

- **HWR segment merge** — merge adjacent handwriting OCR segments on the same line to reduce fragmented headings; TOC uses merged ink runs
- **HWR merge tests** — coverage for segment merging and spacing behavior

## [0.2.56] — 2026

### Fixed

- **Finger drawing** — ship `FingerDrawingService` (SharedPreferences), Settings → Drawing toggle, and routing-matrix tests; completes v0.2.52 pointer/scroll-lock lifecycle fixes

## [0.2.55] — 2026

### Added

- **Page info chip** — top-right chip on the document canvas shows template, size, and orientation; tap (or toolbar gear) opens a scrollable page settings sheet
- **Page settings popup** — new `page_settings_popup.dart`; export PNG/PDF, notebook PDF, bookmarks, audio, split page, and TOC never clip off-screen
- **Library export workbook** — long-press a notebook → **Export workbook** shares all pages as vector PDF via the system sheet
- **Export guard** — blocks export when any page exceeds 2000 strokes (clear snackbar; split heavy pages first)

### Changed

- **Export progress** — shared `withExportProgressDialog` helper in `page_export.dart` for document and library exports

## [0.2.54] — 2026

### Fixed

- **Session restore** — flush notebook + page index to SQLite on app pause/background (crash recovery); cold start via `AppHome` verified with widget tests

### Added

- **Session tests** — `SessionService` roundtrip, simulated restart persistence, cold-start restore, and stale-session cleanup coverage
- **Page settings popup** — top-right page info chip opens a scrollable sheet for template/size/orientation, bookmarks, audio, and export actions
- **Export entry points** — page settings includes PNG/PDF export; library long-press adds “Export workbook” with progress dialog
- **Split page action** — page settings and complexity warnings offer a one-tap split flow for heavy pages

### Changed

- **Page complexity warning** — warn at ~500 strokes (export block remains at 2000)

## [0.2.53] — 2026

### Changed

- **Toolbar brushes** — brush styles (pen, fountain, pencil, marker, calligraphy) live only in the pen options popup; removed inline `_BrushStyleRow` from the top toolbar
- **Pen/highlighter colors** — expanded preset palettes plus HSV custom color picker; user-picked swatches persist for the session

### Fixed

- **Pen options popup** — brush chips use `ColorScheme` for readable selected/unselected contrast in light and dark theme
- **Legacy marker tool** — dropped standalone `marker` toolbar id from saved tool order (marker remains a pen brush style)

## [0.2.52] — 2026

### Fixed

- **Finger drawing** — pointer and scroll-lock state resets on page switch; stylus proximity no longer leaves scroll stuck on older pages
- **Finger drawing setting** — Settings → Drawing → "Finger drawing" persists via SharedPreferences and applies to all pages immediately (toolbar toggle syncs too)

### Added

- **Pointer routing tests** — routing matrix for stylus-only on/off × paper/margin touch (scroll lock, draw, pan/zoom)

## [0.2.51] — 2026

### Changed

- **Handwriting OCR** — replaced printed-text ML Kit (`google_mlkit_text_recognition`) with on-device Digital Ink Recognition (`google_mlkit_digital_ink_recognition`); English (`en-US`) handwriting model downloads once on first use (local inference, no accounts)
- **Convert to text** — lasso selection and background ink search indexing feed stroke points directly to the digital ink recognizer; progress dialog shown while the model downloads

## [0.2.50] — 2026

### Fixed

- **Library notebook titles** — titles sit below the cover thumbnail (v0.2.6 style) with `onSurface` text; thumbnails no longer carry a title overlay
- **New notebook dialog** — size and paper `ChoiceChip`s use `ColorScheme` for selected/unselected states (readable in light and dark theme)

## [0.2.49] — 2026

### Added

- **Auto-backup** — daily zip of `penfold.db` and asset folders under `backups/` (keeps last 3); Settings → **Recover from backup** when a recent auto-backup exists
- **Soft-delete notebooks** — library delete moves notebooks to Trash (`deleted_at` column, schema v15); ink stays on device until hard purge (Trash UI in a later release)
- **Delete safety** — pre-delete dialog with **Export first** shortcut (full backup zip via share sheet)
- **Data recovery docs** — `docs/DEVICE_TESTING.md` adb pull instructions for `penfold.db` and auto-backup paths

## [0.2.48] — 2026

### Fixed

- **Page alignment** — scroll and page-turn modes use the same full-viewport page slots; each page is a discrete centered card at canonical aspect ratio (not stretched continuous canvas)
- **Viewport reset** — pinch/pan zoom resets to 1.0 when page orientation, size, or device rotation changes layout
- **Scroll modes** — page-turn (`PageView`) and continuous scroll (`CustomScrollView`) wired consistently from Settings; scroll locks during paper touch and pinch without blocking draw

### Added

- **Zoom navigation toggle** — Settings → Notebook → "Zoom navigation" gates pinch/pan zoom on pages (default on)

## [0.2.47] — 2026

### Fixed

- **PDF squish** — `PagePainter` uses `BoxFit.contain` with centered letterboxing (matches thumbnail logic) instead of stretching PDF backgrounds
- **Landscape PDF pages** — `PageEditor` and `DrawingCanvas` respect stored `PageOrientation`; legacy imports infer landscape when aspect > 1
- **PDF import layout** — `PdfImportService` stores per-page `page_size`, `orientation`, and `aspect` from PDF MediaBox dimensions

## [0.2.46] — 2026

### Changed

- **Toolbar brushes** — brush styles (pen, fountain, pencil, marker, calligraphy) live only in the pen options popup; removed inline brush row from the top toolbar
- **Pen/highlighter colors** — expanded preset palettes plus custom color picker (HSV dialog); user-picked colors persist for the session

### Fixed

- **Pen options popup** — brush chips and labels use `ColorScheme` so selected/unselected states stay readable in light and dark theme

## [0.2.43] — 2026

### Fixed

- **S Pen barrel button** — `MainActivity.kt` handles primary and secondary stylus buttons; button-up is sent on hover move, hover exit, and cancel (not only hover exit)
- **S Pen event wiring** — `spen_button_service.dart` recognizes secondary barrel button (0x40) in pointer fallback; hold-to-eraser/lasso/pen follows Settings preference

## [0.2.42] — 2026

### Fixed

- **Eraser crash + ghost strokes** — serialize partial erase per pointer session (one in-flight op, coalesced moves); defer DB writes and undo until erase ends
- **Stroke splitting explosion** — highlighter/tape/marker erase whole strokes; cap pen partial splits to two fragments; drop micro-fragments below point/length threshold
- **Regression tests** — `test/stroke_eraser_test.dart` covers whole-stroke tools, fragment caps, and repeated partial erase

## [0.2.41] — 2026

### Fixed

- **Pinch zoom** — two-finger pinch in/out (0.6×–10×) works reliably in stylus-only and finger-drawing modes, on paper and margin; stylus can draw while fingers pinch
- **`DrawGestureShield` removed from draw path** — the 16 ms arena accept blocked `PageViewport` scale before the second finger landed; scroll is locked via paper-touch callback instead
- **`PageViewport`** — applies zoom via `Transform` + `TransformationController` (no `InteractiveViewer` layout drift); late pinch start on paper still supported
- **`pointer_routing`** — `shouldLockScrollForPaperTouch` for finger-on-paper scroll lock without blocking pinch

## [0.2.40] — 2026

### Added

- **Undo persist on page switch** — per-page undo/redo stacks kept in memory in `drawing_canvas.dart`; switching pages and returning restores undo history for that page; toolbar undo/redo state syncs on page change

## [0.2.38] — 2026

### Added

- **Page complexity warning + split page** — warn via snackbar when a page reaches 2000 strokes (on open or after adding ink); page settings "Split page" duplicates template and moves the upper half of strokes to a new page inserted after the current one

## [0.2.39] — 2026

### Added

- **Your data settings screen** — Settings shows `penfold.db` path and on-disk size, plus folder sizes for `images`, `pdf_sources`, `audio`, and `thumbnails`; help text links to `docs/ARCHITECTURE.md`; backup/restore actions remain in the same screen

## [0.2.37] — 2026

### Added

- **Handwriting-to-text conversion** — lasso or selection tool: "Convert to text" toolbar action on ink selection; OCR via on-device `ink_ocr_service`; inserts a `TextBlock` at selection bounds while keeping original ink

## [0.2.36] — 2026

### Added

- **Auto table of contents** — detect heading-like typed `TextBlock` text (short lines, large font, ALL CAPS) and OCR `ink_index` entries; notebook Contents sheet in toolbar and page settings; tap an entry to jump to that page

## [0.2.35] — 2026

### Added

- **Gesture ink editing** — scratch zigzag over OCR-indexed strokes to delete them; simple recognizer in `drawing_canvas.dart`; only acts on `ink_index` entries with `status=indexed`; Settings toggle to enable/disable (default on)

## [0.2.34] — 2026

### Added

- **Page-level audio attachment (MVP)** — attach a local audio file per page via file picker in page settings; play/pause preview with `just_audio`; files stored under `audio/` in app documents; schema v14: `pages.audio_path`

## [0.2.33] — 2026

### Added

- **Page-turn scroll mode** — Settings toggle persisted via `SharedPreferences`; `notebook_screen` swaps `CustomScrollView` for vertical `PageView` when enabled; continuous scroll remains default

## [0.2.32] — 2026

### Added

- **PDF hyperlinks (read-only)** — parse URI link annotations from imported PDF pages on demand; overlay tap targets in `page_editor` (finger/mouse only, stylus passes through); open URLs via `url_launcher`

## [0.2.31] — 2026

### Added

- **PDF embedded text search at import** — extract text per page from PDF content streams via the `pdf` package; store in `pdf_page_text` (schema v13); index into FTS immediately on import (before OCR)

## [0.2.30] — 2026

### Added

- **Page overview reorder + batch delete** — drag-handle reorder in thumbnail grid; multi-select via long-press or checklist mode; confirmed batch delete; `pages.idx` updated in SQLite transactions

## [0.2.29] — 2026

### Added

- **Session persistence** — SQLite `session` table (schema v12); cold start resumes last notebook, page index, scroll offset, and active tool via `AppHome`

## [0.2.28] — 2026

### Added

- **S Pen barrel button** — hold side button for temporary eraser (default), lasso, or pen; release restores prior tool; Android `EventChannel` + pointer-button fallback; configurable in Settings
- **Eraser toolbar icon** — `Icons.cleaning_services_rounded` for clearer eraser affordance

## [0.2.27] — 2026

### Added

- **Stroke smoothing toggle** — `ToolState.strokeSmoothing` (default on); Chaikin corner-cutting on ink point stream before stroke commit; Settings toggle persisted via `SharedPreferences`

## [0.2.26] — 2026

### Added

- **Lasso rotate handles** — lasso selection shows scale/rotate transform handles like the selection tool; finger input on handles works in stylus-only mode; move/rotate/scale commit via undo/redo transform snapshots

## [0.2.25] — 2026

### Added

- **Notebook library thumbnails** — first-page mini-render on library covers via reused `PageThumbnailPainter`; PNG cached in `thumbnails/{notebook_id}.png` on notebook open or lazy library load; included in full-database backup zip

## [0.2.24] — 2026

### Added

- **OCR custom dictionary** — schema v11: `ocr_terms(term)`; Settings UI to add/remove domain terms; fuzzy post-processing in `ink_ocr_service` (ML Kit has no Latin hints); glossary merged into notebook FTS body for search boost

## [0.2.22] — 2026

### Added

- **Mixed-orientation pages in one notebook** — per-page Portrait/Landscape toggle in page settings (not for PDF-imported pages); schema v10: `pages.orientation`; `PageCoords` swaps width/height for landscape rendering; aspect updated on orientation change

## [0.2.21] — 2026

### Added

- **Per-page template and page size change** — page settings sheet exposes A4/A5/Letter size picker alongside template; `updatePageSize` and `pageHasInk` DB helpers; confirm dialog when changing size on a page with ink; re-layout via existing `PageCoords` (canonical ink coords unchanged)

## [0.2.20] — 2026

### Added

- **Tape / hide-reveal study tool** — `ToolType.tape` with semi-transparent overlay strokes; tap tape to toggle reveal/hide; tape in center toolbar (after highlighter); schema v9: `strokes.hidden`; vector PDF export includes tape layer

## [0.2.19] — 2026

### Added

- **Toolbar tool order customization** — drag-reorder center drawing tools in Settings; order saved via `SharedPreferences`; editor toolbar renders from saved order; undo/redo remain fixed on the right

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

[0.2.56]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.56
[0.2.55]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.55
[0.2.54]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.54
[0.2.53]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.53
[0.2.52]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.52
[0.2.51]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.51
[0.2.50]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.50
[0.2.49]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.49
[0.2.48]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.48
[0.2.47]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.47
[0.2.46]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.46
[0.2.45]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.45
[0.2.44]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.44
[0.2.43]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.43
[0.2.42]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.42
[0.2.41]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.41
[0.2.40]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.40
[0.2.38]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.38
[0.2.39]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.39
[0.2.37]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.37
[0.2.36]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.36
[0.2.35]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.35
[0.2.34]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.34
[0.2.33]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.33
[0.2.32]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.32
[0.2.31]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.31
[0.2.30]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.30
[0.2.29]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.29
[0.2.28]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.28
[0.2.27]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.27
[0.2.26]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.26
[0.2.25]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.25
[0.2.24]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.24
[0.2.22]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.22
[0.2.21]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.21
[0.2.20]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.20
[0.2.19]: https://github.com/BlommeJan/penfold/releases/tag/v0.2.19
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
