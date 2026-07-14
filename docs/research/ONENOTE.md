# OneNote — Competitive Research

> Sources: PCMag, Zapier, Litmus, SmartRemoteGigs, MSW Tutor, Microsoft Support/Q&A, Paperlike, AFFiNE, Huion community, migration blogs (2024–2026).  
> Penfold baseline: **v0.2.6** — local-first Flutter notebook, Android/S Pen, SQLite, no cloud.

---

## Strengths

- **Free core tier** — unlimited notebooks/pages, ink, multimedia, web clipper, and cross-device sync without a paywall (5 GB OneDrive included)
- **Infinite freeform canvas** — place typed text, ink, images, audio, and attachments anywhere on a page; strong for mixed lecture capture
- **Deep stylus support** — pressure-sensitive pen, highlighter, shapes; Surface and iPad inking praised as among the best in free/cross-platform apps
- **Handwriting-to-text** — ink conversion and “text pen” (auto-convert while writing on supported builds); virtual highlighter for review
- **Searchable ink (when it works)** — OCR on handwriting and images; Windows desktop indexes locally; cloud OCR on other clients
- **Offline-first editing** — full create/edit offline; auto-sync when back online (strong vs cloud-only rivals)
- **Cross-platform reach** — Windows, Mac, iOS, Android, Web; best-in-class if you live in Microsoft 365
- **Organization model** — notebooks → sections → pages; familiar ring-binder metaphor; tags and section groups
- **Collaboration** — real-time co-editing on shared notebooks; Teams/Outlook/OneDrive integration
- **PDF & printouts** — insert documents as printouts and annotate on top; web clipper for research
- **Copilot / AI (M365)** — summarize, rewrite, Q&A across notebooks (paid; not on free tier)
- **Institutional adoption** — default for schools and enterprises already on Microsoft stack
- **No per-notebook cap** — unlike freemium rivals (e.g. GoodNotes’ 3-notebook free tier)

---

## Weaknesses

- **Handwriting search is unreliable** — top recurring complaint; ink created on iPad/iPhone/Android often not searchable; cloud OCR async and “notoriously unreliable”
- **Platform-dependent OCR** — only Windows desktop does full local ink indexing; mobile ink may stay unsearchable until a Windows PC processes it
- **Manual OCR workaround** — lasso → “treat selected ink as handwriting” required when auto-recognition fails
- **Ink quality vs dedicated apps** — handwriting feel and tool refinement lag GoodNotes/Notability on iPad; “good but not as refined”
- **Performance & ink lag** — slow/laggy on large notebooks, heavy PDF printouts, or during sync; Microsoft publishes perf-tuning guides
- **Page bloat** — too much content on one page causes write failures; users split pages/modules to recover
- **No audio-synced notes** — unlike Notability; audio can be embedded but not stroke-synced replay
- **Weak structured knowledge** — freeform canvas scales poorly; overlapping containers pile up; poor for long-term organized PKM
- **Export & portability pain** — proprietary `.one` / `.onepkg`; no one-click “export entire notebook” to open formats; PDF/DOCX/MHT lossy
- **Vendor lock-in** — mixed ink+graphics layout doesn’t survive export; users discover stickiness only when leaving
- **Web export regressions** — notebook ZIP export removed/broken on web; forces desktop workarounds
- **Mac export gap** — Mac client cannot export full notebooks; copy/move workarounds only
- **Two-app confusion (historical)** — OneNote 2016 vs “Windows 10” vs store “OneNote”; different OCR/sync behavior; UWP app EOL Oct 2025
- **Sync errors block migration** — unsynced notebooks, E000006C-style errors, read-only legacy clients; data trapped locally
- **OneDrive dependency** — sync and storage tied to Microsoft account; 5 GB free cap; institutional export restrictions
- **Limited OCR on export** — PCMag notes OCR “could be better”; image/PDF OCR imperfect in testing
- **No geotagging** — minor but noted in reviews
- **Copilot paywall** — AI features require M365; free users get stripped experience vs marketed “AI note app” narrative
- **Android ink search absent** — handwriting on Android not indexed (per Microsoft Q&A); Windows-created ink searchable everywhere
- **Institutional account traps** — export between org and personal accounts unsupported; workarounds need Windows desktop

---

## User Complaints (themes, 2024–2026)

### Handwriting search & OCR
- “I bought a Surface for searchable ink — new notes don’t search”
- iPad ink searchable only after Windows PC opens notebook
- Auto handwriting recognition stopped working; must lasso every selection
- Photos searchable but ink isn’t (different OCR pipelines)
- Months of ink unsearchable; exam-prep users feel misled by store marketing

### Performance & inking
- Apple Pencil delay in OneNote on iPad (sync, notebook size, post-update bugs)
- Surface/tablet lag during lectures; page too full to write anymore
- Must disable hardware acceleration, auto-sync, or handwriting recognition to cope
- Large PDF slide decks cause lag; split into smaller files

### Sync & product fragmentation
- Two OneNote installs with different content; can’t run both easily
- “NONE of those versions is the same! AND they don’t sync!”
- OneNote for Windows 10 EOL → read-only; migration anxiety
- Sync errors prevent notebooks appearing in new client

### Export & lock-in
- “OneNote data stays in OneNote” — no real Save As for mixed ink notes
- Export to PDF is print-only, not editable archive
- `.onepkg` not importable into Joplin/Obsidian; ZIP export broken on web
- GDPR/portability advocates cite inadequate structured export

### UX & workflow
- Less structured than GoodNotes for notebook-style study
- No stroke-synced lecture audio
- Cluttered infinite canvas hard to navigate at scale
- Feature differences between clients without clear labeling

---

## Penfold Takeaway

**Positioning**
- OneNote is the **free, cross-platform default** with the **widest ecosystem** — Penfold cannot compete on Teams/Outlook integration or M365 bundling
- Penfold can win **Android tablet users** who want GoodNotes-style structure without Microsoft account, OneDrive, or cloud OCR roulette
- OneNote’s **handwriting-search failures on mobile** are Penfold’s clearest opening: ship **local on-device ink indexing** that works the same on every Android device

**Match or exceed (high impact)**
- **Reliable handwriting search** — OneNote’s #1 ink complaint; Penfold roadmap item; must index on-device at write time, not async cloud
- **Low-latency native inking** — OneNote degrades on heavy pages; Penfold should cap page complexity and keep strokes snappy
- **Predictable offline** — OneNote is good offline but sync/state causes lag; Penfold’s always-local model avoids sync-induced ink delay
- **Structured notebooks** — folders, pages, templates; closer to GoodNotes than OneNote’s chaotic canvas
- **PDF import + annotate** — shared use case; Penfold already renders once to local PNG
- **Transparent export** — PNG/PDF per page/notebook today; add full DB backup to contrast OneNote’s `.one` trap

**Do not copy**
- Infinite unstructured canvas as the only mode (poor PKM scaling)
- Cloud-dependent OCR with platform-specific behavior
- Proprietary archive as the only exit path
- Account + cloud storage as prerequisites to write
- Multiple app variants with different feature sets
- Copilot/AI upsell on core note workflows

**Differentiators to emphasize**
- **No Microsoft account** — write immediately; no OneDrive quota
- **Single app, single behavior** — no “Windows indexes, iPad doesn’t” split
- **Inspectable `penfold.db`** — SQLite vs opaque `.one` blobs
- **Android-first native** — not a web shell; S Pen optimized
- **Privacy** — no telemetry; notes never leave device by design

**Priority gaps vs OneNote (for Penfold backlog)**
1. Handwriting OCR search (local, synchronous) — closes OneNote’s biggest mobile gap
2. Pixel / stroke-splitting eraser — OneNote has whole-stroke eraser too; table stakes
3. Audio recording + optional stroke sync — OneNote lacks Notability-style replay; future differentiator
4. Large-PDF / heavy-page performance guards — prevent OneNote-style “page too full to write”
5. Full-database backup/export — answer portability complaints OneNote users hit when migrating
6. Page bookmarks + quick jump — structure without infinite-canvas chaos

**Anti-patterns to avoid**
- Shipping ink search that only works on one platform or after a desktop sync
- Silent/async indexing with no user-visible “searchable” state
- Requiring cloud account for local notes
- Proprietary-only backup with no standard export
- Letting notebook size degrade write performance without warning or split tools
- Fragmenting features across multiple app SKUs
