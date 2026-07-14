# Samsung Notes — Competitive Research

Research date: July 2026. Sources: Samsung support docs, Samsung Community/Members forums, Android Authority, SamMobile, Techjockey user reviews, student-focused comparisons.

Target audience overlap: Galaxy Tab owners using S Pen for lectures, work notes, and PDF markup.

---

## Strengths

- **Best-in-class S Pen feel (when it works)** — Widely regarded as the lowest-latency, most responsive handwriting experience on Galaxy tablets; competitors (OneNote, Goodnotes on Android) are often described as softer or laggier.
- **Free and pre-installed** — No subscription; ships on every Galaxy phone/tablet, so zero onboarding friction for Samsung buyers.
- **Deep S Pen integration** — Hover, quick highlight with pen, handwriting-to-text conversion, Always-On Notes for fast capture, and Galaxy AI “Note assist” on newer One UI versions.
- **Solid core note features** — Typed + handwritten notes, folders/subfolders, page templates (lined, grid, dotted, etc.), multimedia embeds, voice recording sync, sticky notes, and reminders.
- **PDF import and markup** — Can import PDFs, annotate with pen/highlighter, and export back to PDF, Word, or PowerPoint.
- **Offline-first on device** — Notes work without network; Samsung Cloud sync when signed in.
- **Windows companion (improving)** — Samsung Notes on Microsoft Store + Samsung Account app; recently opened to non–Galaxy Book PCs after years of ecosystem gating (though with “optimized for Galaxy Book” disclaimers).
- **Handwriting recognition** — Built-in conversion to text; generally praised vs. OneNote on Android.
- **Rich pen toolbox** — Multiple brush types (fountain, calligraphy, pencil, brush), color mixer, and shape tools for casual sketching.

---

## Weaknesses / complaints

### S Pen & writing performance (top complaint on tablets)

- **Pen input lag after updates** — Recurring reports (notably Nov 2024 update on Tab S6 Lite and similar) of severe slowdown when writing quickly; users rolled back APK versions and disabled auto-update to recover.
- **Incomplete strokes on fast writing** — Default “Pen” tool drops ~90% of long quick strokes; workaround is switching to fountain/calligraphy/pencil/brush. Issue reported device-specific but absent in OneNote, ibisPaint, Sketchbook on same hardware.
- **No stroke-smoothing toggle** — Users request ability to disable smoothing; not exposed in settings.
- **Drawing crashes** — Samsung acknowledged crashes when using drawing tools on Android 14 / One UI 6.x (2024); “create a copy of note” workaround suggested.
- **Performance degrades on large notes** — Lag when notes contain many images, long content, or heavy multimedia; app “slows down” per user reviews.

### PDF workflow

- **Basic vs. study-focused apps** — PDF annotation considered weaker than Flexcil or dedicated PDF apps; no deep textbook workflow (split view, advanced annotation layers).
- **Export quality bugs** — Exported PDFs often rasterize handwriting at low resolution (blurry); highlights lose transparency and become opaque blocks covering text; long-standing community reports.
- **Orientation lock frustration** — Landscape default blocks portrait PDF pages (and vice versa); users must match orientation or split into separate notes.
- **Imported PDFs not truly editable** — Only overlay annotations; underlying PDF structure unchanged; some export/share options greyed out on older versions.
- **Searchability** — Text boxes may not embed as searchable text layers in exported PDFs.

### Organization & search

- **Shallow organization** — Folders/subfolders only; no tags, databases, or wiki-style linking; “basic” vs. Notion/OneNote power users.
- **Search regressions** — Multiple 2024–2025 reports that search only matches note titles, not body/handwriting content; previously searchable content became unfindable after updates.
- **Clunky/slow search UI** — Even when working, search described as slow and not deep for handwritten content.
- **No web clipper** — Poor fit for research-heavy workflows.

### Ecosystem & sync lock-in

- **Samsung-only cloud** — No native iOS/macOS; cross-platform users stuck or forced into workarounds.
- **OneNote sync ending July 2026** — “Sync to Microsoft OneNote” feature discontinued; mobile-to-Windows bridge removed; pushes users toward Samsung’s own Windows app or full migration.
- **Windows app whiplash** — 2023 lockout to Galaxy Book only (users locked out of notes on PC); partial reversal later; erodes trust in long-term access.
- **Sync reliability** — Delayed or failed Samsung Cloud sync; sync stops reported after very large notebooks (~100k strokes); notes may live in cloud not local when sync on — reinstall/accidental delete can mean partial data loss.
- **Backup confusion** — Samsung Notes excluded from generic device backup; relies on Samsung Cloud auto-backup (charging + Wi-Fi + screen off); users lost notes after reinstall despite believing sync was on.
- **Account required for multi-device** — Conflicts with privacy-minded users who want local-only ownership.

### Export, collaboration & customization

- **Limited export formats** — PDF/Word/PPT/SNS share; no easy .docx/.txt bulk export; export options criticized as narrow.
- **No real-time collaboration** — Share/export only; cannot co-edit with coworkers or classmates.
- **Low customization** — Layouts, toolbar, and settings less flexible than GoodNotes/Notability; “not as customizable as other apps.”
- **Drawing tools adequate, not pro** — Fine for notes, not for illustration; artists redirect to dedicated apps.
- **Cannot uninstall/disable** — System app; force-stop only; frustrating when broken version cannot be removed.

---

## Penfold takeaway

Samsung Notes is the **incumbent default** for Penfold’s target user: Galaxy Tab + S Pen owners who want free, fast handwriting. Penfold should assume users have already tried Samsung Notes and may still use it for quick capture — competition is less about “another notes app” and more about **trust, ownership, and workflow depth**.

| Samsung Notes pain | Penfold opportunity |
|---|---|
| Pen lag / broken strokes after updates | Prioritize **stable, predictable ink performance**; treat latency and stroke fidelity as release blockers, not polish items |
| Cloud/sync lock-in and data-loss anxiety | Lead with **local-first, inspectable `penfold.db`** — no account, no sync surprises, user owns the file |
| PDF export quality & study workflow gaps | Invest in **clean PDF export** and import/markup; Flexcil owns heavy PDF study — Penfold can win “notebook + reasonable PDF” without cloud |
| Search regressions & shallow organization | **Reliable full-text search** (titles + typed text today; handwriting OCR on roadmap) and nested folders without Samsung Cloud dependency |
| Ecosystem whiplash (Windows/OneNote) | Stay **Android-first and honest** — no faux cross-platform promises; appeal to users burned by Samsung reversing Windows/OneNote access |
| Privacy / account fatigue | “No sign-in” is a **differentiator**, not a missing feature — mirror Samsung’s ink quality where possible without Samsung Account |

**Positioning sketch:** *“Samsung Notes ink feel, without Samsung’s cloud roulette.”* Penfold wins users who love S Pen writing but distrust sync, export, update regressions, or vendor lock-in — students and professionals who want a **GoodNotes-style library** that stays on-device.

**Do not compete head-on on:** Galaxy AI assist, Always-On quick memo, voice-to-text, free preinstall, or Microsoft Office export — those are Samsung platform perks.

**Must match or beat on tablet:** palm rejection, pressure curves, hover (where hardware supports), undo depth, page templates, and **consistent stroke rendering under fast writing**.
