# Nebo / MyScript Notes — Competitive Research

**Product:** MyScript Notes (formerly Nebo) by MyScript  
**Focus:** Handwriting recognition and conversion (Interactive Ink)  
**Platforms:** iOS, Android, Windows (still branded Nebo), Mac  
**Pricing (2026):** Freemium — ~$1.99/mo, ~$7.99/yr, or ~$24.99 lifetime; legacy Nebo purchasers grandfathered  
**Researched:** July 2026

---

## Strengths

- **Best-in-class handwriting recognition** — Widely rated the most accurate note-app OCR; handles cursive, messy script, mixed languages, and technical notation better than GoodNotes/Notability.
- **Interactive Ink (real-time conversion)** — Live preview while writing; handwriting reflows and edits like typed text without a separate conversion step.
- **Gesture-based ink editing** — Scratch to erase, underline to emphasize, join/split words by writing; corrections stay in the handwriting workflow.
- **Math, diagrams, and structured content** — Recognizes equations (LaTeX export), cleans hand-drawn lines/shapes, and supports sketch blocks alongside text blocks.
- **Multi-language recognition** — Strong support for Latin scripts plus Chinese, Japanese, Korean, Russian (per product positioning and user reports).
- **Cross-platform with account sync** — Works on iPad, Android, Windows, and Mac; one of few premium handwriting apps on Android + Windows.
- **Export to editable formats** — Word, PDF, LaTeX, plain text; suited to turning handwritten meeting/lecture notes into shareable documents.
- **Minimal, writing-first UX** — UI stays out of the way; praised for feeling natural and fast once learned.
- **Custom dictionary** — Users can add domain-specific terms to improve recognition (one word at a time).
- **Recent AI features** — Summarization and quiz generation from notes (polarizing but valued by some students).

---

## Weaknesses

- **Notebook-first features lag competitors** — Weaker folder hierarchy, PDF annotation/hyperlink navigation, templates, and library organization vs GoodNotes/Notability.
- **No audio recording** — No lecture audio sync (Notability’s core student feature).
- **Sync is a major pain point** — Manual sync, conflicted copies, merge failures across devices, and reported data loss after updates; mixed sentiment despite high star ratings.
- **Account required for sync** — Mandatory MyScript account even when users prefer iCloud-only; privacy concerns raised in reviews.
- **Export and portability gaps** — Historically single-page PDF export, awkward bulk notebook export; notes can feel “trapped” in the app.
- **Navigation friction** — No in-notebook next/previous page while editing; must exit to library to switch pages.
- **Recognition constraints** — Struggles with very sloppy handwriting, oversized writing (strokes vanish), writing outside ruled lines, and jargon until custom dictionary is built.
- **Sketch vs text ambiguity** — Unrecognized strokes in text blocks disappear on pen lift; doodles require explicit sketch sections.
- **Stylus and palm rejection issues** — Requires quality active pens; passive styluses need mode toggling; palm rejection reported as erratic on Windows.
- **Stability and performance complaints** — Crashes, freezing, Pencil dropouts, lag on large notebooks (25+ pages), PDF annotation distortion bugs.
- **Pricing backlash** — Shift from one-time purchase to subscription/freemium (page limits, AI upsells) angered long-time users.
- **Typing mode bugs** — Keyboard typing reportedly crashes or fails to save; app marketed as hybrid but handwriting-first in practice.
- **No photo/scan OCR** — Converts live digital ink only; cannot transcribe existing paper notes.
- **AI feature creep** — Some loyal users feel recent AI additions degraded the core product.

---

## Penfold Takeaway

- **Nebo owns conversion; Penfold owns custody** — Nebo’s moat is MyScript’s Interactive Ink engine and real-time handwriting→text. Penfold’s moat is local-first, no-account, inspectable `penfold.db`. These are complementary positioning axes, not direct clones.
- **OCR is on Penfold’s roadmap — study Nebo’s UX, not their cloud** — When Penfold adds handwriting search/OCR (v0.2.7 searches titles + typed text only), prioritize on-device indexing and optional export over real-time reflow; Nebo proves users want live preview and gesture correction, but Penfold users chose privacy over sync.
- **Don’t chase Nebo’s document model** — Nebo is structured “blocks” (text vs sketch) optimized for conversion. Penfold’s GoodNotes-style infinite/scrolling pages fit freeform ink better; avoid forcing strokes to disappear when unrecognized.
- **Exploit Nebo’s Android pain points** — Android users praise Nebo’s recognition but complain about sync, organization, and performance at scale. A stable, offline Android notebook with eventual local OCR fills a gap Nebo doesn’t serve well.
- **Learn from sync/export failures** — Nebo’s worst reviews center on lost notes, conflicted copies, and poor bulk export. Penfold should keep export simple (PNG/PDF per page/notebook), avoid mandatory accounts, and never ship half-baked sync.
- **Recognition accuracy is table stakes for OCR features** — Nebo sets the bar for messy lecture notes, math, and mixed notation. Any Penfold OCR must be on-device and honest about limits; partner or embed a proven engine rather than shipping naive stroke OCR.
- **Stay notebook-first** — Nebo wins conversion; GoodNotes/Notability win library UX. Penfold should deepen folders, search, PDF import, and stylus feel before competing on AI summarization or quiz generation.

---

## Sources

- [MyScript Notes product page](https://www.myscript.com/notes/)
- [Paperlike — MyScript Notes review](https://paperlike.com/blogs/paperlikers-insights/myscript-notes-app-review)
- [CNET — Nebo review](https://www.cnet.com/reviews/myscript-nebo-review/)
- [dEssence — PKM handwriting recognition 2026](https://dessence.ai/blog/pkm-tools-that-handle-handwriting-recognition-2026)
- [ImageToTable — Best handwriting converters 2026](https://imagetotable.ai/blog/best-handwriting-to-text-converters-2026)
- [Branden Bodendorfer — Notability vs GoodNotes vs Nebo 2026](https://brandenbodendorfer.com/comparing-notability-goodnotes-and-nebo/)
- App Store / Google Play user reviews (2024–2026)
