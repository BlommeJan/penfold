<p align="center">
  <img src="assets/icon/app_icon.png" alt="Penfold" width="96" height="96" />
</p>

<h1 align="center">Penfold</h1>

<p align="center">
  <strong>A local-first handwriting notebook for Android.</strong><br/>
  No accounts. No cloud. No telemetry.
</p>

<p align="center">
  <a href="https://github.com/BlommeJan/penfold/releases"><img src="https://img.shields.io/github/v/release/BlommeJan/penfold?label=version" alt="Version" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter 3.x" /></a>
  <a href="https://www.android.com"><img src="https://img.shields.io/badge/platform-Android-green.svg" alt="Android" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="MIT License" /></a>
</p>

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

**v0.2.7** — GoodNotes-style toolbar (back left, tools center, actions right), richer brand theme (#2455C3), vibrant library covers, and colored selection handles.

---

## Features

**Drawing** — Pressure-sensitive pen (fountain, pencil, marker, calligraphy), highlighter, whole-stroke eraser, optional stroke smoothing (Chaikin, default on), shape recognition, flood fill, typed text blocks, lasso select with copy/paste and rotate/scale handles, and 100-step undo/redo. Ink is stored in canonical page coordinates so strokes stay aligned when you rotate or zoom.

**Pages** — Vertical scroll through multi-page notebooks, page overview grid, blank/lined/grid/dotted/college-ruled templates, A4/A5/Letter sizes, image insert, PDF import (rendered once to local PNG), and export current page or full notebook as PNG or vector PDF (ink strokes stay crisp at any zoom).

**Library** — Colored notebook covers with first-page thumbnails (cached locally), nested folders, notebook tags with filter chips, full-text search (FTS5 → FTS4 → LIKE fallback), PDF import from the home screen, full-database backup/restore (zip export via share sheet), and customizable toolbar tool order in Settings.

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

> Screenshots coming soon. Until then: imagine a clean library grid of colored notebook covers, a vertically scrolling editor with ruled paper and a floating page pill, and a toolbar of ink tools along the top.

| Library | Editor | Page overview |
|:---:|:---:|:---:|
| *Coming soon* | *Coming soon* | *Coming soon* |

---

## Documentation

| Document | Description |
|----------|-------------|
| [CHANGELOG.md](CHANGELOG.md) | Version history (v0.1.0 – v0.2.27) |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Code layout, design patterns, SQLite schema |
| [docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md) | Feature feasibility, versions 0.2.7–0.2.40, dependency order |
| [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | Development setup, tests, PR guidelines |
| [docs/BUILD.md](docs/BUILD.md) | Release APK build instructions |
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
  <strong>Penfold v0.2.27</strong> — write freely, keep it local.
</p>
