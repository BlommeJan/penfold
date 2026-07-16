# Bug bash — device verification priorities (v0.2.61)

Use this after installing `APKs/Penfold-v0.2.61.apk`. Full checklist: [DEVICE_TESTING.md](../DEVICE_TESTING.md).

## P0 — test first

1. **Eraser** — partial erase on pen ink; whole-stroke erase on highlighter/tape. No crash, no ghost strokes, stroke count stays stable after long erase session.
2. **Export** — page settings chip → Export PDF; library long-press → Export workbook. Blocked pages show a clear message above 2000 strokes; use **Split page** on the warning snackbar.
3. **Page layout** — continuous scroll and page-turn mode: pages same card size, not stretched. Rotate page orientation in settings; zoom resets, PDFs letterboxed (not squished).
4. **Finger drawing** — Settings → Finger drawing ON; draw on page 1, switch to page 2; finger works without stylus hover stuck.

## P1 — handwriting & input

5. **Digital Ink OCR** — first convert-to-text needs one-time `en-US` model download (Wi‑Fi not required). Lasso ink → Convert to text; try fast "hello".
6. **S Pen barrel** — hold button while hovering; eraser (or configured tool) toggles; releases on move without lift.
7. **Pinch zoom** — Settings → Zoom navigation; toggle off/on; no conflict with scroll in continuous mode.

## P2 — library & data safety

8. **Trash** — delete notebook → Trash; restore within 30 days. Hamburger drawer → Trash count.
9. **Auto-backup** — Settings → Recover from backup (after 24h or cold start). See adb pull in DEVICE_TESTING.md for manual recovery.
10. **Session** — force-close app on a note; reopen should return to same notebook/page.

## Stress protocols

- **Eraser stress:** 50+ strokes, erase across highlighter and pen; confirm stroke count does not explode and app stays responsive.
- **OCR stress:** write 3–5 words quickly, convert; expect one merged text block, not per-stroke fragments.
- **PDF import:** landscape PDF page keeps aspect; no full-width stretch on rotate.

## Known limits

- Audio recording untested this pass (device stability focus).
- OCR quality depends on ML Kit `en-US` handwriting model; cursive and very small text may need slower writing.
