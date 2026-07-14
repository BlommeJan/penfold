<p align="center">
  <img src="assets/icon/app_icon.png" alt="Penfold" width="96" height="96" />
</p>

<h1 align="center">Penfold</h1>

<p align="center">
  <strong>A local-first handwriting notebook for Android.</strong><br/>
  No accounts. No cloud. No telemetry.
</p>

<p align="center">
  <a href="https://github.com/your-org/penfold/releases"><img src="https://img.shields.io/badge/version-0.2.4-blue.svg" alt="Version 0.2.4" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter 3.x" /></a>
  <a href="https://www.android.com"><img src="https://img.shields.io/badge/platform-Android-green.svg" alt="Android" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="MIT License" /></a>
</p>

---

## Table of contents

- [About](#about)
- [Features](#features)
  - [Drawing](#drawing)
  - [Pages & templates](#pages--templates)
  - [Library & organization](#library--organization)
  - [Storage](#storage)
- [Screenshots](#screenshots)
- [Installation & setup](#installation--setup)
- [Platform notes](#platform-notes)
- [Architecture](#architecture)
- [SQLite storage](#sqlite-storage)
- [Testing](#testing)
- [Changelog](#changelog)
- [Roadmap](#roadmap)
- [Contributing & license](#contributing--license)

---

## About

Penfold is a Flutter app that brings a **GoodNotes-style handwriting workflow** to Android tablets and phones — with one important difference: **your notebooks never leave your device.**

There is no sign-in, no sync server, and no analytics. Every stroke, image, folder, and search index lives in a single SQLite database on local storage. Open the app, pick up your stylus, and write.

| | |
|---|---|
| **Private by design** | All data in one inspectable `penfold.db` file on device |
| **Stylus-first** | Palm rejection, pressure sensitivity, S Pen hover support |
| **Organized library** | Nested folders, full-text search, colored notebook covers |
| **Rich ink tools** | Pen, pencil, highlighter, shapes, fill, text, lasso |
| **PDF import** | Render pages once, then work fully offline |

Penfold is built for people who want a capable ink notebook without tying their notes to a cloud account.

---

## Features

### Drawing

Pressure-sensitive ink with multiple brush styles and a full editing toolkit.

| Tool | Details |
|------|---------|
| **Pen** | Fountain, pencil, marker, and calligraphy brush styles with pressure-sensitive width |
| **Highlighter** | Semi-transparent overlay strokes |
| **Eraser** | Whole-stroke removal with adjustable radius; inverted stylus triggers eraser automatically |
| **Shapes** | Sketch roughly — get clean lines, rectangles, triangles, circles, ellipses, and polygons |
| **Fill** | Draw a closed loop or tap inside an existing shape to fill (vector fill, undoable) |
| **Text** | Tap to place typed text blocks on the page; indexed for search |
| **Lasso** | Select strokes, images, and text; move, delete, copy/paste (10 mm offset) |
| **Undo / redo** | Action-based history, 100 steps deep |

**Input modes**

- **Stylus-only** (default) — finger pans and zooms; stylus draws. Palm rejection enabled.
- **Finger drawing** — finger on paper draws; finger on the margin pans/zooms.
- Stylus never scrolls the page list or moves the canvas while drawing.

Ink is stored in **canonical page coordinates** (0.1 mm space), so strokes stay aligned when you rotate, zoom, or resize the viewport.

### Pages & templates

Multi-page notebooks with flexible paper and navigation.

| Capability | Details |
|------------|---------|
| **Vertical scroll** | Continuous view through all pages with a floating page indicator |
| **Page overview** | Thumbnail grid for quick jump navigation |
| **Paper templates** | Blank, lined, grid, dotted, college ruled (25 mm left margin) |
| **Page sizes** | A4, A5, Letter — chosen at notebook creation |
| **Per-page template** | Switch template from the editor toolbar |
| **Images on pages** | Insert, drag, resize, delete; ink draws on top |
| **PDF import** | Each page renders once at 2× to a local PNG, then stays offline |
| **Pinch-to-zoom** | Up to 10× with gated pan/zoom per page |

### Library & organization

A home screen for all your notebooks.

- **Notebook grid** with colored covers and **title printed on the cover**
- **Nested folders** with breadcrumb navigation and subfolder creation
- **Full-text search** across notebook titles and typed text blocks
- **All / Uncategorized** filters plus folder chips for quick filtering
- Create, rename, delete, and move notebooks (long-press for context menu)
- **PDF import** from the library — pick a file, get a new notebook

Search uses SQLite full-text search with automatic fallback: **FTS5** → **FTS4** → **LIKE** — so search works on every Android device.

### Storage

Everything stays on your device. No network calls, no background sync.

| Location | Contents |
|----------|----------|
| `<app documents>/penfold.db` | Notebooks, pages, strokes, images metadata, fills, text, folders, FTS index |
| `<app documents>/pdf_pages/` | Rendered PDF page backgrounds (PNG) |
| `<app documents>/images/` | User-inserted images on pages |

Schema version **3** with automatic migrations on upgrade. Foreign keys enforced. Your data is yours — back up the documents folder to move notebooks between devices.

---

## Screenshots

> Screenshots coming soon. Until then: imagine a clean library grid of colored notebook covers, a vertically scrolling editor with ruled paper and a floating page pill, and a toolbar of ink tools along the top.

| Library | Editor | Page overview |
|:---:|:---:|:---:|
| *Coming soon* | *Coming soon* | *Coming soon* |

---

## Installation & setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x (Dart ≥ 3.3)
- Android SDK for device builds
- An Android device or emulator

### Clone and run

```bash
git clone <your-repo-url> penfold
cd penfold
flutter pub get
dart run flutter_launcher_icons   # optional: regenerate launcher icons
flutter run
```

No API keys, `.env` files, or sign-in steps are required.

### Build a release APK

```bash
# arm64 only (recommended for modern phones/tablets)
flutter build apk --release --target-platform android-arm64

# universal APK (all ABIs)
flutter build apk --release
```

Flutter writes the artifact to `build/app/outputs/flutter-apk/app-release.apk`. After each release build, copy and rename it into **`APKs/`** at the project root (version from `pubspec.yaml`):

```powershell
# Windows (PowerShell)
New-Item -ItemType Directory -Path APKs -Force
Copy-Item build/app/outputs/flutter-apk/app-release.apk APKs/Penfold-v0.2.4-arm64.apk
```

```bash
# Linux / macOS
mkdir -p APKs
cp build/app/outputs/flutter-apk/app-release.apk "APKs/Penfold-v$(grep '^version:' pubspec.yaml | awk '{print $2}')-arm64.apk"
```

**Deliverables:** release APKs live in `APKs/` — e.g. `APKs/Penfold-v0.2.4-arm64.apk`. Do not leave `.apk` files in the project root.

For the lowest drawing latency on a physical device, prefer a **`--release`** build over debug.

---

## Platform notes

### Android & S Pen

Penfold uses Flutter pointer events for stylus input. On Samsung devices and other Android tablets with active styluses:

| Input | Behavior |
|-------|----------|
| **Pressure** | Passed through for variable line width |
| **Hover** | Detected for palm-rejection timing |
| **Inverted stylus** | Eraser end triggers the eraser tool automatically |
| **Finger + pen** | Finger pinch/pan works in stylus-only mode while the pen hovers |

### Search backend

Library search picks the best SQLite backend at startup:

1. **FTS5** (preferred) — ranked results via the `rank` auxiliary column
2. **FTS4** (fallback on older Android SQLite) — same `snippet()` API, no `rank`
3. **LIKE** (last resort) — simple substring match on titles and text blocks

v0.2.2 fixed an FTS4 crash caused by using FTS5-only `rank` queries on devices without FTS5.

---

## Architecture

Penfold follows a flat, readable layout — no code generation, no heavy state-management frameworks.

```
lib/
├── main.dart
├── models/models.dart              # Notebook, PageSize, Stroke, TextBlock, Fill…
├── db/app_database.dart            # SQLite v3, FTS, nested folders, migrations
├── canvas/
│   ├── page_coords.dart            # Canonical ↔ display coordinate helpers
│   ├── page_viewport.dart          # Gated pan/zoom (stylus / margin rules)
│   ├── penfold_scroll_behavior.dart
│   ├── drawing_canvas.dart         # Pointer input, tools, undo/redo, clipboard
│   ├── painters.dart               # Templates, ink, thumbnails
│   └── shape_recognizer.dart
├── screens/
│   ├── library_screen.dart         # Folders, search, create dialog
│   ├── notebook_screen.dart        # Vertical scroll multi-page editor
│   └── page_overview_screen.dart   # Thumbnail grid
├── widgets/
│   ├── page_editor.dart            # One page card (viewport + canvas)
│   └── toolbar.dart
└── services/pdf_import.dart
```

**Key design choices**

| Pattern | Why |
|---------|-----|
| **Canonical coordinates** | Strokes stored in 0.1 mm page space, mapped to display size — rotation and zoom do not drift ink |
| **Gated viewport** | `PageViewport` routes each pointer to drawing or pan/zoom based on tool mode and touch location |
| **Action-based undo** | Each edit is a reversible action object, not a full canvas snapshot |
| **Stylus-gated scroll** | `PenfoldScrollBehavior` prevents stylus from dragging the page list |

**Dependencies:** `sqflite`, `path_provider`, `file_picker`, `pdfx`, `uuid`

---

## SQLite storage

Single database file, schema version **3**:

| Table | Purpose |
|-------|---------|
| `notebooks` | Title, cover color, template, page size, folder |
| `pages` | Page index, template, optional PDF background image path |
| `strokes` | Ink geometry (canonical points, tool, brush, color) |
| `page_images` | Inserted images with position and size |
| `fills` | Vector fill regions |
| `text_blocks` | Typed text (searchable) |
| `folders` | Nested folder tree (`parent_id`) |
| `search_index` | FTS virtual table (FTS5 or FTS4) |

Migrations from v1 → v2 added folders, fills, text blocks, page sizes, brush styles, and FTS. v2 → v3 added nested folders via `parent_id`.

---

## Testing

```bash
flutter test
```

| Test file | Coverage |
|-----------|----------|
| `shape_recognizer_test.dart` | Lines, rectangles, circles, triangles |
| `models_test.dart` | Model serialization and roundtrips |
| `database_test.dart` | SQLite CRUD and basic FTS |
| `database_v2_test.dart` | v2/v3 migrations, nested folders, search |
| `page_coords_test.dart` | Coordinate transforms and stylus gating rules |
| `widget_test.dart` | Library boot, notebook creation smoke tests |

Tests use `sqflite_common_ffi` with a temporary database directory — no emulator required.

---

## Changelog

### v0.2.4

- **Toolbar** — insert image moved to center tool row; horizontal brush picker (pen, fountain, pencil, marker, calligraphy)
- **Fill** — tap inside a closed pen/shape loop to flood-fill; drag still draws a fill boundary
- **Selection** — fix scale/rotate handles (finger input in stylus-only mode, larger hit targets, image bounds)
- **Text** — blocks auto-size to content with improved canvas typography

### v0.2.3

- **Finger drawing** — fix finger ink on scrolled-to pages (`DrawGestureShield` blocks scroll from stealing paper touches)
- **Page overview** — proper mini-render thumbnails (strokes, fills, text, PDF); denser responsive grid (4–8 columns)
- **Toolbar** — GoodNotes-style layout: back (left), tools + undo/redo (center), settings/add/stylus/overview + `3/12` indicator (right)
- **Selection tool** — marquee tap/drag select with move, scale, and rotate handles (separate from lasso loop)
- **Text tool** — Done button + keyboard confirm; persists `TextBlock` to DB; tap existing text to re-edit

### v0.2.2

- **Search** — fix FTS4 crash (`rank` is FTS5-only); backend-specific queries with LIKE fallback
- **Zoom** — fix pinch-to-zoom compounding scale each frame
- **Stylus** — finger pinch/pan works in stylus-only mode while pen hovers; stylus cannot scroll pages or pan/zoom
- **Library** — notebook title on cover; new-notebook app-bar button; compact filter + folder chip row
- **Icon** — redesigned app icon (notebook with binding, ruled lines, pen silhouette)
- **Docs** — release APK deliverables convention: ship builds as `APKs/Penfold-v{version}-arm64.apk`

### v0.2.1

- Fix infinite library spinner on Android (FTS5 → FTS4/LIKE fallback; resilient DB migration)
- Nested folders (`parent_id`), breadcrumb drill-down, subfolder creation
- Library UI polish: search bar, All/Uncategorized filters, folder chips
- Minimal line-art app icon on brand blue (#2455C3)

### v0.2.0

- Canonical page coordinates (rotation-stable ink)
- Gated pan/zoom with stylus and margin rules
- Vertical scroll + page overview grid
- A4 / A5 / Letter page sizes + college ruled template
- Fountain pen, pencil, fill, text tools; lasso copy/paste
- Library folders + FTS search
- Custom notebook + pen app icon

### v0.1.0

- Initial release: pen, highlighter, eraser, lasso, shapes, PDF import

---

## Roadmap

Penfold is under active development. These items are **not** in v0.2.4:

| Planned | Status |
|---------|--------|
| Handwriting OCR search | v0.2 searches titles + typed text only; ML Kit integration TBD |
| Pixel / stroke-splitting eraser | Current eraser removes whole strokes |
| PDF export | Import only for now |
| Cloud sync | Intentionally out of scope for the local-first design |
| Lasso rotate handles | Selection tool has rotate; lasso is move-only |
| iOS build | Android-first; Flutter code is largely cross-platform |
| Screenshots & Play Store listing | Documentation polish |

---

## Contributing & license

**Contributing** — Issues and pull requests are welcome. Please open an issue before large changes so we can align on direction.

**License** — [MIT](LICENSE). Copyright (c) 2026 itsbryce.

---

<p align="center">
  <strong>Penfold v0.2.4</strong> — write freely, keep it local.
</p>
