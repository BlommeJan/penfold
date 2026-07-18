<p align="center">
  <img src="assets/icon/app_icon.png" alt="Penfold" width="96" height="96" />
</p>

<h1 align="center">Penfold</h1>

<p align="center">
  <strong>A local-first handwriting notebook for Android.</strong><br/>
  <em>(Tested on Galaxy; should work on other Android devices)</em><br/>
  No accounts. No cloud. No telemetry.
</p>

<p align="center">
  <a href="https://github.com/BlommeJan/penfold"><img src="https://img.shields.io/static/v1?label=version&message=0.2.83&color=blue" alt="Version 0.2.83" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter 3.x" /></a>
  <a href="https://www.android.com"><img src="https://img.shields.io/badge/platform-Android-green.svg" alt="Android" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="MIT License" /></a>
</p>

<p align="center"><sub><span style="color:red">This project was developed with assistance from AI tools.</span></sub></p>

---

Penfold is a Flutter app that brings a **GoodNotes-style handwriting workflow** to Android tablets and phones — with one important difference: **your notebooks never leave your device.**

There is no sign-in, no sync server, and no analytics. Every stroke, image, folder, and search index lives in a single SQLite database on local storage. Open the app, pick up your stylus, and write.

| | |
|---|---|
| **Private by design** | All data in one inspectable `penfold.db` file on device |
| **Stylus-first** | Palm rejection, pressure sensitivity, S Pen hover support |
| **Organized library** | Nested folders, tags, full-text search, colored notebook covers |
| **Rich ink tools** | Pen, pencil, highlighter, tape (hide-reveal), shapes, fill, text, lasso |
| **PDF import** | Render pages once, then work fully offline |

See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## Features

**Drawing** — Pressure-sensitive pen (fountain, pencil, marker, calligraphy), highlighter, whole-stroke and pixel eraser (with brush-size outline and erase-all-on-page), optional stroke smoothing (Chaikin, default on), S Pen barrel-button hold-to-erase, shape recognition, flood fill, typed text blocks, lasso select with copy/paste and rotate/scale handles, and 100-step undo/redo with per-page history preserved when switching pages. Ink is stored in canonical page coordinates so strokes stay aligned when you rotate or zoom; changing page orientation scales and centers content to fit.

**Pages** — Vertical scroll through multi-page notebooks (optional page-turn mode snaps one page at a time), page overview grid with drag-reorder and multi-select batch delete, blank/lined/grid/dotted/college-ruled templates, A4/A5/Letter sizes, per-page paper color themes (light, dark, sepia, pastels), gear menu for page settings (template, size, orientation, page color, export, and more), image insert, per-page audio attachment (local files, play/pause in page settings), page complexity warning at 500 strokes with split-page tool in page settings, PDF import (lazy render with read-only hyperlinks), and export current page or full notebook as PNG or vector PDF (ink strokes stay crisp at any zoom).

**Library** — Colored notebook covers with first-page thumbnails (cached locally), nested folders, notebook tags with filter chips, full-text search (FTS5 → FTS4 → LIKE fallback; PDF embedded text indexed at import), PDF import from the home screen, long-press **Export workbook** (vector PDF), Trash view with 30-day retention (restore or delete), hamburger drawer for folders/settings/trash, muted version label in the app bar, full-database backup/restore (zip export via share sheet), Settings "Your data" screen (DB path, asset folder sizes, link to `docs/ARCHITECTURE.md`), Settings **About** section (app name and version), customizable toolbar tool order in Settings, and session persistence (remembers page, scroll, and tool while editing; cold start always opens the library).

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for folder layout, design patterns, and SQLite schema details.

---

## Quick start

**Prerequisites:** [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x (Dart ≥ 3.3), Android SDK, and a device or emulator.

```bash
git clone https://github.com/BlommeJan/penfold.git
cd penfold
flutter pub get
flutter run
```

No API keys, `.env` files, or sign-in steps are required.

To build a release APK, see [docs/BUILD.md](docs/BUILD.md).

---

## Screenshots

Drop PNG or JPG captures in [`docs/screenshots/`](docs/screenshots/) — see [docs/screenshots/README.md](docs/screenshots/README.md) for naming and capture tips. Paths below are wired for a v0.2.83 feature set (library, drawing, page themes, dark mode, i18n, handwriting OCR, S Pen tools, and more).

| | |
|:---:|:---:|
| **Library** — folders, tags, colored covers | **Notebook editor** — ink tools, templates, page pill |
| ![Library home](docs/screenshots/01-library.png) | ![Notebook editor](docs/screenshots/02-notebook-editor.png) |
| **Page overview** — grid, reorder, OCR badge | **Page themes** — light, dark, sepia, pastels |
| ![Page overview](docs/screenshots/03-page-overview.png) | ![Page themes](docs/screenshots/04-page-themes.png) |
| **Settings** — toolbar order, backup, OCR dictionary | **Dark mode** — system/light/dark theme |
| ![Settings](docs/screenshots/05-settings.png) | ![Dark mode](docs/screenshots/06-dark-mode.png) |
| **Languages** — locale picker (EN, FR, NL, …) | **OCR search** — handwriting indexed and searchable |
| ![Languages](docs/screenshots/07-languages.png) | ![OCR search](docs/screenshots/08-ocr-search.png) |

**S Pen & tools** — toolbar, lasso, shapes, barrel-button erase:

![S Pen and toolbar](docs/screenshots/09-spen-toolbar.png)

---

## Documentation

| Document | Description |
|----------|-------------|
| [CHANGELOG.md](CHANGELOG.md) | Version history (v0.1.0 – v0.2.83) |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Code layout, design patterns, SQLite schema |
| [docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md) | Feature feasibility, versions 0.2.7–0.2.40, dependency order |
| [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | Development setup, tests, PR guidelines |
| [docs/BUILD.md](docs/BUILD.md) | Release APK build instructions |
| [docs/DEVICE_TESTING.md](docs/DEVICE_TESTING.md) | On-device feature checklist for QA |
| [docs/screenshots/README.md](docs/screenshots/README.md) | README screenshot filenames and capture guide |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Community standards |
| [LICENSE](LICENSE) | MIT license |

---

## Roadmap

Penfold is under active development. These items are **not** in v0.2.7:

- Handwriting OCR search (v0.2 searches titles + typed text only)
- Pixel / stroke-splitting eraser (current eraser removes whole strokes)
- Cloud sync (intentionally out of scope)
- iOS build (Android-first; Flutter code is largely cross-platform)
- Screenshots & Play Store listing

Track progress in [CHANGELOG.md](CHANGELOG.md) and [GitHub Issues](https://github.com/BlommeJan/penfold/issues).

---

## Contributing

Issues and pull requests are welcome. Please read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) before submitting changes.

---

<p align="center">
  <strong>Penfold v0.2.83</strong> — write freely, keep it local.
</p>
