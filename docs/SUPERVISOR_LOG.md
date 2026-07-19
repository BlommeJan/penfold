# Supervisor Log — Penfold overnight run

**Started:** 2026-07-15  
**Resumed:** overnight autonomous run  
**Ground rules:** local/offline, SQLite, MIT — zero cloud/accounts/payments

## Supervisor notes

- **v0.3.2 messaging (2026-07-19)** — README, settings, and library copy emphasize offline local-first privacy (no account, no cloud sync, no telemetry).
- **v0.3.1 user-test fixes (2026-07-19)** — Library tag chips + tag search, fill closed shapes, tape tap-remove with opacity, hex/RGB/HSV color picker. Integration agent: 304 tests, `Penfold-v0.3.1.apk`, device install on R52X909VNGW.
- **v0.3.0 milestone (2026-07-19)** — User milestone tag consolidating the 0.2.x wave: 13-language i18n, dark mode, page paper themes, settings restructure (language/appearance/preferences), stroke smoothing slider, contextual locale review, Samsung S Pen polish, handwriting OCR, and document zoom UX. Patch releases 0.2.78–0.2.83 remain in CHANGELOG detail; integration agent tags `0.3.0` in pubspec.
- **v0.2.14 backup** shipped on main at `d31e633` (2026-07-15). A duplicate sub-agent for backup was **abandoned** — no partial backup changes were left uncommitted; `backup_service.dart` on main is canonical.
- **Current position:** v0.2.41 landscape pinch-zoom patch shipped after v0.2.40 roadmap completion.
- **Run completed:** 2026-07-16 — resumed from v0.2.29 (`1361e6b`, 130 tests); shipped v0.2.30–0.2.40 (11 features); final main at `71ea66c`, **200/200 tests**, release APK built.

### v0.2.28 implementation spec (user requirements)

**S Pen barrel/button:**
- Hold S Pen button → **eraser mode while held** (release → restore prior tool)
- Settings: configurable barrel action; **default suggestion: eraser**
- Android platform channel and/or pointer events for S Pen button when available
- Document behavior in settings screen

**Eraser toolbar icon:**
- Replace current eraser icon in `lib/widgets/toolbar.dart` — must read clearly as eraser (not `auto_fix_off`)
- Prefer GoodNotes-style rubber/eraser shape; options: `Icons.cleaning_services_rounded`, custom SVG, or best Material match
- Match v0.2.7 GoodNotes-style toolbar aesthetics

## v0.2.69 device bug bash backlog (2026-07-17, user tablet test)

**Context:** v0.2.68 on Samsung SM-X920. User going to sleep — fix in next session. Do **not** treat as shipped until verified on device.

**Status:** **SHIPPED v0.2.69** (2026-07-17) — zoom clip/seam, OCR channel bridge, stylus-only finger scroll for all tools, eraser icon polish. Install `APKs/Penfold-v0.2.69.apk` and re-verify on SM-X920.

### P0 — Document viewport / zoom — **DONE v0.2.69**

| # | Symptom | Notes |
|---|---------|-------|
| 1 | **Zoom in → content disappears** | Fixed: removed scroll-fold-into-transform (lazy slivers blanked); expand paint when zoomed. |
| 2 | **White seam / line while zoomed + two-finger pan** | Fixed: `Clip.none` + full `cacheExtent` on scroll body while zoomed; outer `ClipRect` after transform. |
| 3 | **Partial reset on glitch** | Same root cause as (1)/(2); addressed by paint expansion + no fold. |

**Acceptance:** Pinch on paper at any zoom; no white seams between pages; ink always visible; two-finger pan while zoomed does not reveal background artifacts.

---

### P0 — OCR / Convert to text — **DONE v0.2.69**

| Symptom | Error |
|---------|-------|
| Select ink → Convert to text | `MissingPluginException`: No implementation found for method `vision#manageInkModels` on channel `google_mlkit_digital_ink_recognizer` |

**Root cause:** Upstream `google_mlkit_digital_ink_recognition` 0.15.0 registers Android channel `…_recognition` but Dart calls `…_recognizer`. Bridged in `MainActivity`; ProGuard keep rules added.

**Acceptance:** Convert to text works on physical tablet (model download + recognition).

---

### P1 — Finger scroll inconsistent across tools — **DONE v0.2.69**

**Works (finger scroll on paper + margin):** Pen, Highlighter, Eraser, Lasso — user can scroll with finger on paper and beside it.

**Was broken (cannot finger-scroll; bugs out):** Selection, Shape, Fill, Text

**Fix:** DocumentViewport no longer claims single-finger paper gestures at 1× in stylus-only (scroll owns paper); `_mayDraw` / `shouldAllowFingerToolManipulation` blocks finger tool steal when `stylusOnly`.

**Acceptance:** In stylus-only mode, finger scroll/pan on paper and margin works for **all** tools (same as pen/highlighter/eraser/lasso).

---

### P2 — Eraser icon — **DONE v0.2.69**

GoodNotes-style pink rubber block + grey ferrule in `toolbar.dart` `_EraserIconPainter`.

---

### Next session order (suggested)

1. ~~Viewport seam / zoom clip (P0)~~ **done**
2. ~~OCR plugin on release build (P0)~~ **done**
3. ~~Tool-specific finger scroll in stylus-only (P1)~~ **done**
4. ~~Eraser icon polish (P2)~~ **done**

Device re-verify on SM-X920 after install.

## v0.2.76 backlog (2026-07-17, user going to work)

**Context:** User going to work — no code fix this session. Investigate and fix in next session.

### P0 — Text tool + keyboard viewport zoom — **DONE v0.2.76**

| Symptom | Notes |
|---------|-------|
| Keyboard opens while using Text tool | Document viewport zoomed out fully; hard to see what you are typing |
| Keyboard dismisses | Zoom sometimes restored, sometimes stayed zoomed out (inconsistent) |

**Root cause:** `Scaffold.resizeToAvoidBottomInset` shrank the body `LayoutBuilder` when the keyboard opened. That changed `DocumentViewport` `viewportSize` / `contentBounds`, triggering `resetTransform()` at ~1× (or reclamping when zoomed). `DocumentViewport` also clamped against the shrunk layout height instead of the stable document viewport.

**Fix (v0.2.76):** `keyboardStableViewportSize` adds `MediaQuery.viewInsets.bottom` back to layout constraints so page slot height and document bounds stay constant while typing. Scroll/page-index helpers use the same cached stable viewport. `DocumentViewport` clamps against `widget.viewportSize` (parent-provided stable size).

**Acceptance:** Pinch to any zoom, tap Text, place/edit text with keyboard open — document scale and pan unchanged; dismiss keyboard — transform still unchanged.

## v0.2.82 — 13 locale translations (2026-07-18)

- Added ARB catalogs for de, fr, nl, ko, pl, es, it, uk, sv, nb, fi, da, pt (308 keys each)
- Settings language picker lists all 14 supported locales with localized language names
- `flutter gen-l10n` generates `AppLocalizations.supportedLocales` for MaterialApp

## v0.2.81 — stroke smoothing for small writing (2026-07-18)

- Ink coalescing uses slower-writing floor (0.3 mm) and flushes final pointer position on lift
- Distance-aware Chaikin smoothing with strength blend; Settings slider 0–100% (recommended 35%)
- `StrokeSmoothingService.strength` persisted via SharedPreferences

## v0.2.80 — dark mode UI polish (2026-07-18)

- Document viewport gutter uses `surfaceContainerLow` instead of white bleed around pages
- Library screen cards, search field, and drawer use theme surface/outline colors
- Notebook toolbar uses `colorScheme.surface`; settings dropdowns/menus themed in `PenfoldTheme`
- `ThemedChoiceChip` fixes choice chips going dead after theme switch; notebook defaults section migrated
- Page overview scaffold and tile overlays follow app theme

## v0.2.79 — settings appearance (2026-07-18)

- Settings restructure: language picker, dark mode (system/light/dark), notebook defaults (paper size, type, page theme); `PenfoldTheme` light/dark wired in `MaterialApp`.

## v0.2.78 — i18n (2026-07-18)

- Added Flutter gen-l10n: `app_en.arb` master catalog, `MaterialApp` delegates, all UI strings via `AppLocalizations`.

## v0.2.77 backlog (2026-07-18)

### P0 — Text tool checkmark commit — **DONE v0.2.77**

| Symptom | Notes |
|---------|-------|
| Type text, tap checkmark on text box | Opens new empty text block; typed content lost |
| Type text, keyboard Done/Enter | Works correctly |

**Root cause:** Canvas `Listener.onPointerDown` fired on checkmark tap before the button's `onPressed`, calling `_startTextEdit` → `_dismissTextEditor(commit: false)` which discarded the in-progress edit.

**Fix (v0.2.77):** Ignore text-tool pointer-down while a text editor is open; move text overlay above the canvas listener so overlay taps are not routed as new placements.

**Acceptance:** Type text, tap checkmark — content committed once; no blank replacement editor.
## Opportunistic backlog (not blocking roadmap)

### Landscape pinch-zoom patch — **SHIPPED v0.2.41**

**User need:** Zoom MUST exist and work. Primary use case: tablet in **landscape** while notebook pages are **portrait A4** — user needs pinch zoom to see detail and navigate comfortably.

**Requirements when implemented:**
- Two-finger pinch zoom in AND out (~0.6×–10×)
- Works in **stylus-only mode** (finger pinches, stylus draws)
- Works in **finger drawing mode**
- Page stays **centered**; ink sticks to paper on rotation/orientation change
- Portrait pages in landscape viewport: page fits by default; user can zoom in for detail
- Do **NOT** repeat v0.2.12 mistakes (broken alignment, left-shifted pages, broken scroll)

**Implementation approach (minimal):**
- Prefer fixes in `page_viewport.dart` + `draw_gesture_shield.dart` only
- Manual test: landscape device, portrait A4 page, pinch zoom, rotate device, ink still on paper
- Ship as dedicated patch: `fix: landscape pinch zoom (v0.2.X)` + flutter test + APK

**Priority:** Shipped in v0.2.41 — removed `DrawGestureShield` arena block, paper-touch scroll lock, `Transform`-based viewport.

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
| 0.2.18 | Vector PDF export | 0.2.12 | **DONE** | 69/69 | `4455813` |
| 0.2.19 | Toolbar tool order customization | 0.2.16 | **DONE** | 73/73 | `189c142` |
| 0.2.20 | Tape / hide-reveal | 0.2.17 | **DONE** | 77/77 | `5691658` |
| 0.2.21 | Per-page template/size | 0.2.18 | **DONE** | 81/81 | `24404ea` |
| 0.2.22 | Mixed-orientation pages | 0.2.19 | **DONE** | 88/88 | `41ec460` |
| 0.2.23 | Audio + stroke timestamps | 0.2.20 | DEFERRED | — | — |
| 0.2.24 | OCR custom dictionary | 0.2.21 | **DONE** | 96/96 | `5ef5c2f` |
| 0.2.25 | Notebook library thumbnails | 0.2.23 | **DONE** | 100/100 | `a59b57a` |
| 0.2.26 | Lasso rotate handles | 0.2.24 | **DONE** | 107/107 | `5d49606` |
| 0.2.27 | Stroke smoothing toggle | 0.2.25 | **DONE** | 117/117 | `cdabe8a` |
| 0.2.28 | S Pen + toolbar eraser polish | 0.2.26 | **DONE** | 126/126 | `a48a190` |
| 0.2.29 | Session persistence | 0.2.27 | **DONE** | 130/130 | `f5b4757` |
| 0.2.30 | Page overview reorder + batch delete | 0.2.28 | **DONE** | 134/134 | `c2ec21f` |
| 0.2.31 | PDF text search at import | 0.2.29 | **DONE** | 139/139 | `b3aa635` |
| 0.2.32 | PDF hyperlinks read-only | 0.2.30 | **DONE** | 145/145 | `e2e6bf5` |
| 0.2.33 | Page-turn scroll mode | 0.2.31 | **DONE** | 150/150 | `b03dc50` |
| 0.2.34 | Page-level audio MVP | 0.2.32 | **DONE** | 157/157 | `befc202` |
| 0.2.35 | Gesture ink editing | 0.2.33 | **DONE** | 168/168 | `326087d` |
| 0.2.36 | Auto table of contents | 0.2.34 | **DONE** | 177/177 | `677f065` |
| 0.2.37 | HWR convert selection | 0.2.35 | **DONE** | 186/186 | `c582829` |
| 0.2.38 | Page complexity warning | 0.2.36 | **DONE** | 192/192 | `a1cd203` |
| 0.2.39 | Your data settings screen | 0.2.37 | **DONE** | 197/197 | `88e8b1e` |
| 0.2.40 | Undo persist on page switch | 0.2.38 | **DONE** | 200/200 | `eb50760` |
| 0.2.41 | Landscape pinch zoom | opportunistic | **DONE** | 201/201 | `9dbf0976` |

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


## GitHub milestone push policy

Push **local main to origin** (git push, never force) only at **milestones** so work is backed up and rollback-friendly. Do **not** push after every sub-agent commit.

**Push when:**
- P0 bug-bash batch complete (e.g. eraser + recovery)
- P1 layout/viewport batch complete
- Full bug-bash or supervisor run wrapped
- Immediately **before** tagging or shipping an APK release

**Do not push when:**
- Mid-feature or between sub-agents on the same milestone
- Only docs/log edits unless closing a milestone

After a push, note the range in supervisor notes (e.g. `6b5ce127..a20cfe3b`).
## Stability rules

- Do **not** re-break page layout/zoom like 0.2.7–0.2.12 regressions
- Page layout centered; ink on paper
- Test page centering, zoom, scroll after viewport/toolbar changes

## APK deliverables

| Version | Path |
|---------|------|
| 0.2.13 | `APKs/Penfold-v0.2.13-arm64.apk` |
| 0.2.40 (final roadmap) | `APKs/Penfold-v0.2.40.apk` (arm64, ~65 MB, local only — gitignored) |
| 0.2.41 | `APKs/Penfold-v0.2.41.apk` (arm64, local only — gitignored) |
| 0.2.60 (bug-bash) | `APKs/Penfold-v0.2.60.apk` (not built — SDK mismatch) |
| 0.2.61 (bug-bash) | `APKs/Penfold-v0.2.61.apk` (~462 MB universal, local only — gitignored) |
| 0.2.69 (device bug bash) | `APKs/Penfold-v0.2.69.apk` (local only — gitignored) |

## Bug-bash overnight run (2026-07-16)

| Metric | Value |
|--------|-------|
| Agents | 19/19 complete (eraser → session restore) |
| Version | v0.2.42 → v0.2.61 |
| Tests | **248/248** green (`flutter test`) |
| Analyze | 81 issues (warnings/info only, no errors) |
| Commits (local) | `ce7beed9`..`57e2f554` + follow-up fixes |
| Push | milestone: full bug-bash complete |

### v0.2.60 fixes (final verification)

- Widget tests: `settleUntil` helper for sqflite async; editor toolbar finders
- `library_screen`: `await _open(n)` after notebook create
- `app_home`: skip backup/purge during widget tests (`overrideDirPath`)

## Run summary (v0.2.30 → 0.2.40)

| Metric | Value |
|--------|-------|
| Features shipped | 11 (one commit each, all pushed) |
| Tests | 130 → 200 |
| Feature commit | `eb50760` (v0.2.40) |
| Zoom patch | **Shipped v0.2.41** — gesture arena + Transform viewport fix |
| Deferred roadmap | 0.2.23 audio+stroke timestamps; 0.2.39 markdown export; 0.2.40 math LaTeX |
