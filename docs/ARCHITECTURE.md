# Architecture

Penfold follows a flat, readable layout — no code generation, no heavy state-management frameworks.

## Folder structure

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

## Key design choices

| Pattern | Why |
|---------|-----|
| **Canonical coordinates** | Strokes stored in 0.1 mm page space, mapped to display size — rotation and zoom do not drift ink |
| **Gated viewport** | `PageViewport` routes each pointer to drawing or pan/zoom based on tool mode and touch location |
| **Action-based undo** | Each edit is a reversible action object, not a full canvas snapshot |
| **Stylus-gated scroll** | `PenfoldScrollBehavior` prevents stylus from dragging the page list |

**Dependencies:** `sqflite`, `path_provider`, `file_picker`, `pdfx`, `uuid`

## SQLite storage

Single database file at `<app documents>/penfold.db`, schema version **3**:

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

Foreign keys are enforced. Schema migrations run automatically on upgrade.

## On-device file layout

| Location | Contents |
|----------|----------|
| `<app documents>/penfold.db` | Notebooks, pages, strokes, images metadata, fills, text, folders, FTS index |
| `<app documents>/pdf_pages/` | Rendered PDF page backgrounds (PNG) |
| `<app documents>/images/` | User-inserted images on pages |

Back up the documents folder to move notebooks between devices.

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
