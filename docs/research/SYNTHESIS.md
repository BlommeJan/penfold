# Competitive Research Synthesis — Penfold

> Aggregated from [GoodNotes](GOODNOTES.md), [Notability](NOTABILITY.md), [Samsung Notes](SAMSUNG_NOTES.md), [OneNote](ONENOTE.md), [Noteshelf](NOTESHELF.md), [Nebo](NEBO.md), and [Squid](SQUID.md).  
> **Penfold baseline:** v0.2.6 — local-first Flutter notebook, Android/S Pen, SQLite, no cloud, no accounts, MIT.

---

## Ground rules (non-negotiable)

These constraints apply to every item below:

| Rule | Implication |
|------|-------------|
| Local-first, no cloud required | No sync server, no account, no vendor backup as source of truth |
| SQLite on-device, no telemetry | Single inspectable `penfold.db`; user owns the file |
| No subscription bait-and-switch / usage caps | Full editor always usable; no notebook limits or edit meters |
| Android / S Pen focus | Native performance, palm rejection, pressure, hover where hardware supports |
| Open source MIT, inspectable data | Schema documented; export paths are standard formats |
| No proprietary lock-in for export | PNG, PDF, and DB backup — never `.goodnotes` / `.one`-style traps |

---

## 1. Positives to implement in Penfold

### Ink & input

| What (who does it well) | How Penfold implements it |
|-------------------------|---------------------------|
| **Low-latency S Pen feel** — Samsung Notes (when stable), Squid, GoodNotes iOS | Treat ink latency and stroke fidelity as **release blockers**. Use Android low-latency stylus APIs, stroke prediction, and canonical page coordinates (already shipped). Benchmark fast-writing and long sessions before every release; never ship an update that regresses stroke capture (Samsung Notes drops ~90% of fast strokes after bad updates). |
| **Natural pressure-sensitive ink** — GoodNotes, Notability, Noteshelf, Squid | Keep and expand the brush picker (fountain, pencil, marker, calligraphy). Tune per-brush pressure curves on real Galaxy Tab hardware. Expose optional stroke-smoothing toggle (Samsung Notes users request this; default on, user can disable). |
| **Partial / pixel eraser** — Notability, GoodNotes (requested) | Ship stroke-splitting eraser on roadmap: split vector strokes at erase intersection, preserve un-erased segments. Whole-stroke eraser remains as a mode, not the only option. |
| **Shape recognition + lasso editing** — Squid, GoodNotes, Penfold (partial) | Keep shape snap on pen-up. Polish lasso: move, copy/paste (done), add rotate handles (roadmap). Selection tool with scale/rotate handles (v0.2.3) stays separate from freeform lasso loop. |
| **Gesture ink editing** — Nebo (scratch to erase, underline to emphasize) | When local OCR ships, add optional gesture layer *on top of* freeform ink — never delete unrecognized strokes on pen lift (Nebo's failure mode). Gestures operate on indexed ink, not as a separate block model. |
| **Palm rejection + stylus-only mode** — Samsung Notes, Squid, Penfold | Maintain finger-pinch/pan while pen hovers; block finger ink on paper (`DrawGestureShield`). Document S Pen button behavior (write / erase / lasso) in settings. |

### Organization

| What (who does it well) | How Penfold implements it |
|-------------------------|---------------------------|
| **Nested folders + colored covers** — GoodNotes, Noteshelf, Penfold | Already shipped (`parent_id`, breadcrumb, cover colors). Next: notebook thumbnails from first-page mini-render (page overview tech exists). |
| **Tags / multi-axis organization** — Noteshelf, OneNote (tags); GoodNotes lacks tags | Add optional tags on notebooks (SQLite `tags` table + junction). Filter library by tag alongside folder chips. Tags are local strings, not cloud metadata. |
| **Page bookmarks + quick jump** — GoodNotes, Noteshelf | Add per-page bookmark flag in schema. Page overview grid shows bookmark icon; editor toolbar shows prev/next bookmark. No cloud sync needed. |
| **Shallow, obvious library navigation** — Notability (subjects/dividers), Penfold | Keep "open library → tap notebook → write" to ≤2 taps. Default new notebook to last-used template/size. Avoid burying the editor behind setup wizards. |
| **Auto table of contents** — Noteshelf | Generate TOC from typed text headings and (when OCR ships) recognized ink headings. Export TOC as PDF outline or in-page index. |

### Search

| What (who does it well) | How Penfold implements it |
|-------------------------|---------------------------|
| **Full-text library search** — GoodNotes, Noteshelf; Penfold has FTS (titles + typed text) | Keep FTS5 → FTS4 → LIKE fallback chain (v0.2.1 fix). Never regress to title-only search (Samsung Notes 2024–2025 regression). Market this vs Squid, which has **no search at all**. |
| **Handwriting OCR search** — GoodNotes (killer feature), Nebo (best accuracy), OneNote (unreliable on mobile) | Ship **on-device** ink indexing at write time or background on device. Index into existing FTS tables. Show per-page "indexed / pending" badge. Use a proven on-device engine (e.g. ML Kit, Tesseract, or licensed MyScript SDK) — never cloud OCR. Same behavior on every Android device; no "Windows indexes, tablet doesn't" split. |
| **PDF text search** — GoodNotes | On PDF import, extract embedded text to FTS at import time (local). Handwritten annotations on PDF pages indexed when OCR ships. |
| **Custom dictionary for OCR** — Nebo | Store user-defined terms in SQLite; feed to OCR engine for domain jargon (medical, legal, course codes). |

### Export & backup

| What (who does it well) | How Penfold implements it |
|-------------------------|---------------------------|
| **Reliable PNG/PDF export** — Penfold (v0.2.5), GoodNotes (when it works) | Keep export on-device with progress UI and timeout guards. Test large notebooks (100+ pages) in CI. Never block UI thread during export. |
| **High-quality PDF export** — Squid, Flexcil; Samsung Notes fails (blurry raster, opaque highlights) | Export vector ink where possible; rasterize at ≥300 DPI for complex fills. Preserve highlighter alpha in PDF (Samsung's opaque-block bug is a regression test case). |
| **Full-database backup** — implied by Penfold positioning; missing today | Add "Backup database" in settings: copy `penfold.db` + asset folder to user-chosen location via share sheet. Document restore: replace file while app closed. **Non-destructive** — never overwrite current data on restore without explicit confirm (contrast Squid restore-wipes-all). |
| **Editable export formats** — Nebo (Word, LaTeX), Noteshelf | Phase 2: optional export of OCR'd ink as plain text / Markdown per page. Not required for v1 OCR; PNG/PDF remain primary. |
| **Standard formats only** — Penfold principle | No proprietary `.penfold` archive as the only exit. SQLite is inspectable; PDF/PNG are universal. |

### PDF

| What (who does it well) | How Penfold implements it |
|-------------------------|---------------------------|
| **Import PDF, annotate offline** — Squid, GoodNotes, Penfold | Keep render-once-to-local-PNG pipeline. PDF import stays **free** (Squid paywalls this — do not copy). |
| **Large-PDF performance** — Xodo, OneNote (when tuned); Squid/GoodNotes fail (blank pages, flicker) | Lazy-load page bitmaps; cache decoded pages in SQLite/filesystem. Pre-render adjacent pages in background isolate. Cap in-memory page cache; never blank a visible page during scroll. |
| **PDF hyperlinks (read-only)** — GoodNotes | Preserve clickable links in imported PDF layer where renderer supports it. |
| **Orientation-agnostic pages** — Samsung Notes fails (locks orientation) | Per-page orientation in metadata; mixed portrait/landscape in one notebook without forcing split notes. |

### UX polish

| What (who does it well) | How Penfold implements it |
|-------------------------|---------------------------|
| **"Open and write" speed** — Notability | Cold start → last notebook or library in <1 s on mid-range Tab. Resume editor state (page, zoom, tool) from SQLite session row. |
| **GoodNotes-style toolbar** — GoodNotes, Penfold (v0.2.3) | Keep back-left / tools-center / settings-right layout. **Do not** move undo next to back button (GN6 regression). Allow tool reorder in settings (GoodNotes added this post-backlash). |
| **Page overview with real thumbnails** — GoodNotes, Penfold (v0.2.3) | Already shipped mini-render grid. Add drag-to-reorder pages and multi-select delete. |
| **100-step undo/redo** — Penfold | Maintain deep undo stack. Persist undo boundary on page switch so accidental navigation doesn't lose redo. |
| **Vertical scroll + page boundaries** — GoodNotes, Penfold | Keep vertical scroll as default. Optional page-turn mode in settings for users who prefer Squid-style paging. |
| **Templates + page sizes** — Squid, GoodNotes, Penfold | Maintain blank/lined/grid/dotted/college + A4/A5/Letter. Allow per-page template change without new notebook (Noteshelf gap). |
| **Tape / hide-reveal study tool** — GoodNotes | Add semi-transparent tape stroke type that toggles hidden/revealed on tap. Stored as ink layer in SQLite, exported in PDF. No cloud flashcards required. |

### Audio & lecture capture

| What (who does it well) | How Penfold implements it |
|-------------------------|---------------------------|
| **Audio synced to ink** — Notability (best), GoodNotes iOS, Samsung Notes | Record audio locally (no upload). Store `audio_path` + per-stroke `timestamp_ms` in SQLite. Tap ink → seek audio. Optional v0.4+ feature; local files only. |
| **Voice recording without sync** — Samsung Notes | Minimum viable: page-level audio attachment before stroke-sync ships. |

### Study & conversion (later phase)

| What (who does it well) | How Penfold implements it |
|-------------------------|---------------------------|
| **Handwriting-to-text conversion** — Nebo (best), Notability/Noteshelf (paid) | Optional "convert selection to text block" using on-device OCR. Insert as `TextBlock`; keep original ink unless user deletes. No real-time reflow that deletes strokes (Nebo anti-pattern). |
| **Math recognition** — Nebo | Phase 3: LaTeX export for recognized equations. Low priority vs notebook UX. |
| **AI summarization / quizzes** — GoodNotes, Notability, Nebo, Noteshelf | **Out of scope** for Penfold core. If ever added: on-device only, opt-in, no credit meters. Competitors' AI upsells are widely resented. |

---

## 2. Negatives to avoid in Penfold

| What went wrong (which apps) | How Penfold prevents it |
|------------------------------|-------------------------|
| **Subscription bait-and-switch** — GoodNotes GN5→GN6, Notability 2021, Nebo, Noteshelf NS2→NS3 | MIT license, no paid tiers. All features ship in the open-source app. Monetization (if any) is donations or separate optional builds — never edit limits or notebook caps. |
| **Usage-metered free tiers** — Notability (monthly edit limit), GoodNotes (3 notebooks) | No meters on strokes, erases, or notebooks. Free means fully functional forever. |
| **Mandatory accounts for local use** — GoodNotes GN6, Nebo sync, Samsung Cloud | No sign-in screen. First launch goes straight to library. Cloud/sync is never a prerequisite to create or edit. |
| **Sync failures → data loss** — GoodNotes iCloud, Notability Cloud, Noteshelf Drive/iCloud, Nebo, Samsung Cloud, OneNote OneDrive | **No sync server.** Single device is source of truth. If optional export/sync is added later: conflict UI, never silent overwrite, never "force open" that deletes data (Noteshelf). Until then: document manual backup of `penfold.db`. |
| **Cross-platform sync promises that don't deliver** — Noteshelf (iOS↔Android silos), GoodNotes (no iOS↔Android) | Never market sync Penfold doesn't have. Tagline: "local-first, one device, yours forever." Honesty beats half-sync. |
| **Handwriting search that only works on one platform** — OneNote (Windows indexes, mobile doesn't), GoodNotes Android lagged years | Index on-device at write time on Android. Same code path on all supported devices. Show indexing status in UI. |
| **Search regressions** — Samsung Notes (body search broke in updates) | FTS regression tests in CI. Search integration test: create note → search body → assert hit. Never ship a release that breaks existing indexed content. |
| **Ink lag / dropped strokes after updates** — Samsung Notes, GoodNotes Android, OneNote large notebooks | Ink perf benchmarks in release checklist. Canary testing on Tab S6 Lite + flagship Tab. Rollback plan for ink regressions. |
| **Performance collapse on large notebooks** — OneNote ("page too full to write"), GoodNotes 6–8 hr sessions, Nebo 25+ pages | Page complexity budget: warn when stroke count exceeds threshold. Offer "split page" tool. Lazy-render off-screen content. |
| **PDF export quality bugs** — Samsung Notes (blurry, opaque highlights), GoodNotes (hangs, blank pages) | Vector-first export; highlighter alpha preserved. Export stress tests on 50+ page notebooks. Cancel button + error message, never infinite spinner. |
| **Destructive restore** — Squid (restore deletes all local notes) | Restore = import merge or explicit "replace all" with typed confirmation + pre-restore auto-copy of current DB. |
| **Paywalling PDF import** — Squid Premium | PDF import stays free in Penfold forever (already shipped). |
| **Proprietary lock-in export** — GoodNotes `.goodnotes`, OneNote `.one` / `.onepkg` | Standard exports only. Document SQL schema in ARCHITECTURE.md so users can query their own data. |
| **Strokes vanishing on pen lift** — Nebo (unrecognized ink in text blocks), GoodNotes (auto-delete while writing bugs) | Freeform ink model: strokes always persist until user erases. OCR indexes ink; it never deletes source strokes. |
| **Toolbar UX regressions** — GoodNotes GN6 (undo by back button, buried tools) | Usability review before toolbar changes. Undo stays in center cluster, away from navigation. User-configurable tool order. |
| **Infinite canvas chaos** — OneNote (overlapping content, poor PKM scaling) | Structured pages with fixed sizes as default. Optional infinite canvas only if explicitly requested — not the only mode. |
| **Multiple app variants with different behavior** — OneNote 2016 vs UWP vs Mac | Single Penfold app, single behavior. No "lite" vs "pro" SKUs with different ink engines. |
| **Aggressive in-app upsell** — Notability, GoodNotes AI Pass | No subscription prompts on the writing surface. Settings/about only for any future donate link. |
| **Android as second-class PWA** — GoodNotes Android | Native Flutter/Dart, not a web shell. Android-first release cadence; no "iOS gets features first" split (N/A — Android-only focus). |
| **AI credit limits / feature creep** — GoodNotes, Noteshelf, Nebo | No AI credit meters. Core note-taking never depends on network or AI. |
| **Migration that locks old data** — Noteshelf NS2→NS3, GoodNotes one-time→subscription | Schema migrations are automatic and backward-compatible. Document migration in CHANGELOG. Never require paid upgrade to access old notebooks. |
| **Family sharing / device cap frustration** — Notability (10 devices), GoodNotes | N/A — local app, no device registration. |
| **Backup confusion** — Samsung Notes (excluded from device backup) | README + in-app "Your data" screen: exact path to `penfold.db`, backup steps, restore steps. |

---

## 3. Priority roadmap (top 15)

Ranked by impact for Penfold's Android/S Pen, local-first users. All items respect the ground rules above.

| Rank | Item | Rationale | Apps that prove demand |
|------|------|-----------|------------------------|
| **1** | **On-device handwriting OCR search** | #1 reason users stay on GoodNotes; Squid's top request for 10+ years; OneNote mobile fails here; Nebo sets accuracy bar | GoodNotes, Squid, OneNote, Nebo |
| **2** | **Pixel / stroke-splitting eraser** | Table stakes; whole-stroke eraser is Penfold's known gap; Notability/Samsung users expect partial erase | Notability, GoodNotes, Squid |
| **3** | **Ink latency & stroke fidelity hardening** | Samsung Notes regressions and GoodNotes Android lag create opening; must match Squid/Samsung at best | Samsung Notes, Squid, GoodNotes |
| **4** | **Large-PDF performance (no blank/flicker pages)** | Squid/GoodNotes pain; students live in slide decks | Squid, GoodNotes, OneNote |
| **5** | **High-quality PDF export (vector ink, alpha highlighter)** | Samsung Notes export is notoriously bad; export reliability builds trust | Samsung Notes, GoodNotes |
| **6** | **Full-database backup + safe restore** | Answers sync/data-loss anxiety across all cloud apps; non-destructive restore | Noteshelf, Squid, Samsung Notes, OneNote |
| **7** | **Page bookmarks + quick jump** | Low effort, high daily use for long notebooks | GoodNotes, Noteshelf |
| **8** | **Tags on notebooks** | Folders alone break at scale; GoodNotes still lacks tags | Noteshelf, OneNote, user requests |
| **9** | **Toolbar customization (tool order, undo position)** | GN6 backlash proved this matters; cheap win | GoodNotes, Noteshelf |
| **10** | **Tape / hide-reveal study tool** | GoodNotes differentiator for flashcard-style review; pure local ink | GoodNotes |
| **11** | **Per-page template/size change** | Noteshelf/OneNote users expect flexibility without new notebook | Noteshelf, Squid |
| **12** | **Mixed-orientation pages in one notebook** | Samsung Notes forces split notes; easy schema win | Samsung Notes |
| **13** | **Audio recording + stroke timestamps** | Notability moat for students; local-only recording | Notability, GoodNotes, Samsung Notes |
| **14** | **OCR custom dictionary** | Nebo proves domain terms matter for lecture notes | Nebo |
| **15** | **Play Store listing + screenshots** | Discovery gap; competitors win by default install or store presence | All (especially Samsung Notes preinstall) |

### Explicitly deferred (not in top 15)

- Cloud sync (out of scope by design)
- Real-time collaboration (OneNote/GoodNotes Pro — needs server)
- AI summarization / quizzes (resent upsell across GoodNotes, Notability, Nebo, Noteshelf)
- iOS build (Android-first)
- Nebo-style real-time ink reflow (conflicts with freeform ink model)
- Marketplace / sticker store (GoodNotes — not local-first priority)

---

## How this feeds Penfold

1. **Issues** — Create GitHub issues for roadmap ranks 1–6 first.
2. **CHANGELOG** — Reference synthesis when shipping OCR, eraser, backup.
3. **Marketing** — Lead with: *local ink search that works on your tablet*, *no accounts*, *export you own*, vs GoodNotes Android PWA and Samsung cloud roulette.
4. **Re-review** — Update this doc when a major competitor shifts (e.g. GoodNotes Android native, Squid10 GA).

---

*Synthesis version: 2026-07-15 · Penfold v0.2.6*
