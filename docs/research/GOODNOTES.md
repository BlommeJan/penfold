# GoodNotes — Competitive Research

> Sources: App Store reviews, Goodnotes feedback forums, Reddit/Hacker News/MPU Talk, Android Police, TechCrunch, support docs (2024–2026).  
> Penfold baseline: **v0.2.6** — local-first Flutter notebook, Android/S Pen, SQLite, no cloud.

---

## Strengths

- **Natural handwriting feel** — pressure-sensitive ink, multiple pen styles, shape recognition; widely praised as the closest to paper on iPad
- **Handwriting search (OCR)** — find text inside handwritten notes, typed text, and PDFs; core reason users stay (iOS mature; Android added Sept 2025)
- **Organization** — nested folders, colored covers/icons, favorites/bookmarks, library search
- **PDF workflow** — import large textbooks, annotate, hyperlinks (read-only mode), templates (lined/grid/dotted)
- **Rich toolset** — pen, highlighter, eraser, lasso, shapes, fill, text, tape (active recall), ruler, stickers, image crop
- **Study features** — tape tool (hide/reveal), study sets/flashcards, AI spellcheck and math assistance
- **Audio recording** — record lectures synced to ink strokes; tap handwriting to replay that moment (iOS)
- **Export & backup** — PDF, images, `.goodnotes` format; share sheet integration
- **Cross-device sync** — iCloud (Apple) and Goodnotes Cloud (Essential/Pro); iPad + Mac + iPhone ecosystem
- **Toolbar customization** — reorder tools, overflow menu, undo/redo position (added after GN6 backlash)
- **Marketplace** — planners, templates, stickers; subscriber specials
- **Brand trust** — long-time GN5 one-time buyers; huge student/professional install base

---

## Weaknesses

- **Subscription / pricing complexity** — moved from ~$10 one-time (GN5) to freemium (3 notebooks) + tiers; confusing plan matrix (Essential, Pro, Special Edition, AI Pass)
- **Feature gating by tier** — cross-platform sync, collaboration, image generation, and some AI behind higher plans; one-time purchase lacks cloud sync
- **Performance & stability** — lag, freezes, crashes on GN6; degrades over long sessions (6–8 hr); M-series iPads still report issues
- **Sync reliability** — iCloud greyed-out docs, missing pages after reinstall, "Backup Failed", version-mismatch errors, data loss scares
- **Android is second-class** — web/PWA architecture, higher latency, offline gaps, feature lag vs iOS; Samsung-only early beta
- **No iOS↔Android notebook sync** — separate apps; breaks multi-device workflows
- **Export fragility** — PDF export hangs/crashes on large notebooks; blank pages after export; OCR layers stripped on export
- **Account lock-in** — sign-in required for GN6; can't switch one-time → subscription without account reset
- **Family sharing friction** — GN6 sharing broken/confusing for many; Pro and AI Pass not shareable
- **AI credit limits** — monthly caps; AI Pass upsell; features users didn't ask for crowding core UX
- **GN6 UI regressions** — tools grouped/nested, undo near back button, audio controls harder to find; learning curve
- **Eraser & input lag** — chronic complaints on eraser and scrolling; stroke lag vs Apple Notes
- **Missing tags** — folders only; no document/paragraph-level tagging (long-standing request)
- **Audio Android gap** — recording and note-replay largely iOS-only
- **Support burden** — users directed to self-serve troubleshooting; data-loss cases escalate slowly

---

## User Complaints (themes, 2024–2026)

### Pricing & subscription
- "I already paid for v5 — why subscribe?"
- Free tier capped at 3 notebooks feels like bait-and-switch
- Pricing page hides actual prices; too many plan names
- One-time purchase users locked out or asked to pay again
- Can't migrate one-time purchase to subscription without losing data
- Real-time collaboration moved to Pro tier
- AI Pass feels like nickel-and-diming on top of subscription

### Sync & data loss
- Notebooks partially sync after reinstall; pages missing
- "Backup Failed" persistent errors
- iCloud corruption; greyed-out documents
- Cross-platform sync doesn't work on Essential (post–Sept 2025 plan changes)
- "All Platforms" label misleading when iPad↔Windows won't sync

### Performance
- App freezes when switching pages, editing text, or writing
- Auto-deleting strokes while writing
- Overheating and thermal throttling during long use
- PDF pages go blank while scrolling
- Must force-quit and restart to recover
- GN6 worse than GN5 — users downgrade

### Android / platform
- S Pen lag; writing stutters mid-sentence
- Offline editing unreliable
- Portrait mode broken (early beta)
- Pressure sensitivity inconsistent
- Paying premium for "glorified web browser"
- Handwriting search missing for years on Android (fixed late 2025)

### Features & UX
- No native tags; folders insufficient for multi-category notes
- Pixel eraser / stroke-splitting eraser requested
- Handwriting search indexing slow or broken
- Image insert workflow slower after updates
- Unified toolbar slows tool switching for teachers
- No audio on Android
- Infinite canvas requested
- Bookmark navigation ("next favorite") awkward

### Export & portability
- PDF export stuck spinning; app crashes
- Notebooks blank after failed export
- Exported PDFs lose searchability / hyperlinks
- `.goodnotes` format not portable outside ecosystem

### Trust & anti-patterns
- GN5 owners feel abandoned
- Family sharing stopped working for GN6
- Account required where none was needed before
- Fear that v5 will stop working to force upgrade

---

## Penfold Takeaway

**Positioning**
- Penfold's "no accounts, no cloud, no telemetry" is a direct answer to GoodNotes' biggest trust complaints — lead with data ownership and a single inspectable `penfold.db`
- Target Android tablet users burned by GoodNotes' PWA experience and Samsung Notes power users who want GoodNotes-style UX natively

**Match or exceed (high impact)**
- Handwriting OCR search — GoodNotes' killer feature; Penfold roadmap item; ship local on-device indexing (titles + typed text done; handwriting is the gap)
- Low-latency S Pen input — GoodNotes' Android weakness is Penfold's opening; prioritize stroke prediction and eraser responsiveness
- Solid PDF import + offline export — users rage about export crashes; Penfold's local PNG/PDF export is a selling point if kept reliable
- Nested folders + FTS search — already have; polish library UX and thumbnails
- Pixel / partial eraser — explicitly on Penfold roadmap; common GoodNotes gap

**Do not copy**
- Subscription tiers, notebook limits, or AI credit systems
- Mandatory accounts or opaque sync
- Feature gating that removes sync from lower tiers
- GN6-style toolbar regressions (undo next to back, buried tools)
- Proprietary lock-in formats as the only backup path

**Differentiators to emphasize**
- One price / free / MIT — no bait-and-switch
- Full offline, always — no "can't edit without internet" (Android GN pain)
- Transparent storage — SQLite + files, user-owned backup
- Android-first native performance vs GoodNotes web shell

**Priority gaps vs GoodNotes (for Penfold backlog)**
1. Handwriting OCR search (local)
2. Pixel eraser
3. Audio recording + stroke sync (optional, later)
4. Tape / hide-reveal study tool
5. Page bookmarks + quick jump
6. Tags or multi-axis organization
7. Toolbar customization (undo position, tool layout)
8. Large-PDF performance (blank page prevention)
9. Play Store listing + screenshots (discovery)
10. Optional manual backup/export of full DB (not just per-notebook PDF)

**Anti-patterns to avoid**
- Moving from one-time purchase to subscription without a fair grandfather path
- Hiding prices or plan differences
- Shipping cross-platform apps that don't sync
- Letting sync/backup failures cause silent data loss
- Degrading performance in major version upgrades
- Requiring accounts for local-only use
