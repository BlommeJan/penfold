# Contributing

Thank you for your interest in Penfold! Issues and pull requests are welcome.

## Before you start

- **Small fixes** (typos, test gaps, clear bugs) — open a PR directly.
- **Larger changes** (new tools, schema changes, UI overhauls) — open an issue first so we can align on direction.

Penfold is **local-first by design**. Features that require accounts, cloud sync, or telemetry are out of scope unless explicitly discussed.

## Development setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x (Dart ≥ 3.3)
- Android SDK for device builds
- An Android device or emulator

### Clone and run

```bash
git clone https://github.com/BlommeJan/penfold.git
cd penfold
flutter pub get
flutter run
```

No API keys, `.env` files, or sign-in steps are required.

For release builds and APK packaging, see [BUILD.md](BUILD.md).

## Running tests

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

## Pull request expectations

1. **Scope** — One logical change per PR when possible.
2. **Tests** — Add or update tests for behavior changes.
3. **Docs** — Update README or `docs/` if user-facing behavior changes.
4. **Changelog** — Add an entry under `[Unreleased]` or the next version in [CHANGELOG.md](../CHANGELOG.md) for notable changes.
5. **Style** — Match existing code: flat structure, no code generation, minimal dependencies.

## Code style

- Keep imports at the top of each file (no inline imports).
- Use exhaustive `switch` handling for discriminated unions and enums (include a `never` check in the default case).
- Prefer extending existing patterns over introducing new frameworks.
- Comments only where business logic or coordinate math is non-obvious.

## Code of conduct

This project follows the [Contributor Covenant](../CODE_OF_CONDUCT.md). Please be respectful and constructive in all interactions.
