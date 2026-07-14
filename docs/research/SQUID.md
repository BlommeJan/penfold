# Squid — Competitive Research

> Sources: Google Play reviews, Squid Help Center, UserVoice feedback forum, Samsung Members, Android Developers (ChromeOS story), NoteLyn/Huion roundups (2024–2026).  
> Penfold baseline: **v0.2.7** — local-first Flutter notebook, Android/S Pen, SQLite, no cloud.

**Product context:** Squid (formerly **Papyrus**) is a handwriting-first Android/ChromeOS app from Stylus Labs / Steadfast Innovation. It has been on the market 10+ years and is positioning a major refresh as **Squid10** (opt-in beta). Core focus: vector ink, stylus input, and PDF markup — not an all-in-one notes platform.

---

## Strengths

- **Top-tier vector ink** — strokes stay crisp at any zoom; widely praised as among the smoothest handwriting on Android
- **Low-latency stylus feel** — strong integration with Android’s low-latency stylus API; ChromeOS users report ink that “comes out of the pen”
- **Handwriting-first design** — built for tablets and active pens since early Android Honeycomb era; not a general notes app bolted onto drawing
- **PDF annotation workflow** — import PDFs, write directly on pages, export annotated PDFs; often cited as best-in-class on Android for lecture slides and form fill/sign
- **Pressure-sensitive pens** — active stylus support; works well with Samsung S Pen workflows (e.g. pen write, finger erase)
- **Vector editing** — lasso select, move, and resize ink as objects; shape recognition cleans rough drawings
- **Flexible pages** — ruled, grid, dotted, and other templates; fixed sizes (A4, Letter, etc.) or infinite canvas
- **Image insert** — drop images into notes and reposition/resize within the layout
- **Local-first storage** — notes on device by default; no account required for core use
- **ChromeOS polish** — keyboard shortcuts, trackpad scrolling, clipboard support; 4.6★ average on Chromebooks per Google developer story
- **Presentation mode** — Chromecast casting for live whiteboard-style display
- **Robust free tier** — basic handwriting and notebooks usable without paying; long-standing install base and brand recognition on Android
- **Education licensing** — bulk/classroom licensing option for schools
- **Mature export options** — PDF export; premium cloud backup to Google Drive, Dropbox, or Box

---

## Weaknesses

- **No handwriting search (OCR)** — most-requested feature for years on UserVoice; users switch to Nebo, Samsung Notes, or Noteshelf for HWR
- **No note search at all** — cannot search titles, tags, or content; painful with hundreds/thousands of notes even when folder-organized
- **No real multi-device sync** — cloud backup is restore-point only, not live sync; edits on one device do not propagate to another
- **Platform lock-in** — Android and ChromeOS only; no native Windows, macOS, or iOS (users resort to emulators or Amazon Appstore workarounds)
- **Premium paywall on core workflows** — PDF import/markup, premium paper backgrounds, and cloud backup require Squid Premium (~$3.99/mo or ~$29.99/yr per roundups)
- **Backup/restore fragility** — restore overwrites and deletes all existing notes on device; Play Store reports of data loss during backup/migration to new tablets
- **PDF performance issues** — complaints of slow page redraw, half-screen flicker, and lag when navigating multi-page PDFs vs OneNote/Xodo
- **Limited tool depth** — fewer pen types (no meaningful fountain vs ballpoint difference per power users), limited highlighter styles, no laser pointer, math box, or advanced shape editing
- **No audio recording** — no lecture capture or stroke-synced playback (common in Samsung Notes, Notability, GoodNotes)
- **No ink-to-text** — handwritten content stays visual; no scribble-to-text conversion
- **UI learning curve** — interface described as confusing or dated; toolbar placement not customizable; endless scroll vs page-turn modes debated
- **Organizational gaps** — folders help but no tags; no robust table of contents beyond page overview; bookmarking limited
- **Sync UX confusion** — users expect Google Drive “backup” to behave like sync; developer acknowledges sync is “very difficult” with no ETA
- **Competitive stagnation** — Samsung Notes, Nebo, and Noteshelf added HWR/search while Squid lagged; risk of users leaving for iPad + GoodNotes/Notability
- **Squid10 transition risk** — major rewrite opt-in; not yet fully featured; migration and regression risk during long-running product refresh
- **Subscription model friction** — users who paid for premium still compare unfavorably to free OneNote (sync + PDF) and Xodo (large PDF handling)

---

## Penfold Takeaway

**Positioning**
- Squid proves sustained demand for a **native Android handwriting + PDF** app — Penfold competes in the same lane but with GoodNotes-style ambition and stricter local-first privacy
- Squid users who outgrow it often cite **search** and **sync** — Penfold already beats Squid on library FTS (titles + typed text) and should market that clearly
- Squid’s “backup ≠ sync” confusion and restore-overwrites-data model is a trust trap — Penfold should keep backup/export semantics obvious and non-destructive

**Match or exceed (high impact)**
- **Ink latency and vector quality** — Squid’s core moat; Penfold must match perceived S Pen responsiveness and zoom-stable strokes
- **PDF import + offline annotation** — Squid’s premium differentiator; Penfold already imports PDFs locally — keep large-document performance a priority (Squid’s redraw complaints are an opening)
- **Shape recognition + lasso editing** — table stakes Squid does well; Penfold has these; polish selection/move UX
- **Page templates and sizes** — Squid’s paper variety is expected; Penfold’s template set should stay competitive
- **Handwriting OCR search** — Squid’s #1 unshipped request; Penfold roadmap item; shipping local HWR would leapfrog a 10-year incumbent

**Do not copy**
- Paywalling PDF import behind subscription (Penfold includes PDF import free)
- Marketing cloud backup as sync when it is restore-only
- Destructive restore flows without strong warnings and merge options
- Years of ignoring search/HWR while competitors ship it
- Subscription upsell for basics that free rivals (OneNote, Xodo) cover

**Differentiators to emphasize**
- **Search today** — FTS library search Squid still lacks for note titles/content
- **Transparent storage** — single inspectable `penfold.db` vs opaque Squid backup blobs
- **No account, no subscription gate** — MIT/free posture vs Squid Premium for PDF + cloud backup
- **GoodNotes-style UX** — folders, covers, richer editor vs Squid’s simpler but aging UI
- **Intentional no-sync** — honest local-only vs Squid’s half-solution that frustrates multi-device users

**Priority gaps vs Squid (for Penfold backlog)**
1. Handwriting OCR search (local) — Squid’s longest-standing gap; Penfold’s biggest leapfrog opportunity
2. Large-PDF page navigation performance — avoid Squid’s redraw/flicker complaints
3. Safe full-database export/backup — user-owned, non-destructive, documented restore path
4. Audio recording + stroke sync (optional, later) — Squid lacks; Samsung Notes users expect it
5. Richer pen/highlighter variety — Squid criticized for shallow ink tools
6. Tags or multi-axis organization — Squid folders-only model breaks down at scale
7. Pixel / partial eraser — on Penfold roadmap; Squid uses whole-stroke eraser patterns

**Anti-patterns to avoid**
- Shipping without any search while users accumulate hundreds of notebooks
- Restore flows that silently wipe current data
- Premium tiers that gate PDF workflows Android users consider essential
- Promising sync “soon” for years without shipping or scoping honestly
- Letting PDF rendering regress on page switches (half-drawn screens)
