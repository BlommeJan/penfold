# Penfold — Device Testing Checklist

**Version:** 0.2.47

Install the release APK from `APKs/` (for example `Penfold-v0.2.47.apk`) on your Android tablet or phone, then work through the sections below. Check each box when the feature works as expected.

---

## Data recovery (adb)

If a notebook was deleted or the app misbehaved, your data may still be in SQLite on the device. **Do not reinstall or clear app data** until you have pulled a copy.

**Package:** `com.itsbryce.penfold`

**Database path (internal storage):**

```text
/data/data/com.itsbryce.penfold/databases/penfold.db
```

**App documents** (images, PDFs, thumbnails, auto-backups) live under the app’s private files directory — typically:

```text
/data/data/com.itsbryce.penfold/app_flutter/
```

Auto-backup zips (when present) are in:

```text
/data/data/com.itsbryce.penfold/app_flutter/backups/auto-backup-*.zip
```

### Pull database with adb (debug build or backupable app)

1. Enable **Developer options** and **USB debugging** on the device.
2. Connect via USB; confirm the device: `adb devices`
3. Pull the database to your PC:

```bash
adb exec-out run-as com.itsbryce.penfold cat databases/penfold.db > penfold-recovered.db
```

If `run-as` fails (release build without debuggable flag), use a full backup or root:

```bash
adb backup -f penfold.ab com.itsbryce.penfold
```

Then extract `penfold.db` from the backup on a workstation, or use Settings → **Recover from backup** / **Restore backup** inside Penfold if an auto-backup or manual zip exists.

4. Inspect the file with any SQLite browser, or copy it into a test device’s app documents and use **Restore backup**.

### In-app recovery

- [ ] Settings → **Recover from backup** appears when an auto-backup exists (created at most once per 24h on app open)
- [ ] Settings → **Restore backup** accepts a Penfold `.zip` from manual export
- [ ] Long-press notebook → **Move to Trash** → **Export first** shares a backup zip before trashing

---

## Library & organization

- [ ] Create a new notebook from the library
- [ ] Open a notebook and return to the library
- [ ] Rename a notebook (long-press or menu)
- [ ] Delete a notebook (moves to Trash — hidden from library; data kept on device)
- [ ] Create nested folders and drill in with breadcrumbs
- [ ] Move a notebook into a folder
- [ ] Filter: All, Uncategorized, and folder chips
- [ ] Search notebooks by title or content
- [ ] Add tags to a notebook and filter by tag
- [ ] Notebook covers show a first-page thumbnail
- [ ] Import a PDF from the library
- [ ] Export full-database backup (Settings → Backup & Restore)
- [ ] Restore from backup and confirm data returns

---

## Notebook & pages

- [ ] Scroll vertically through pages (default continuous scroll)
- [ ] Turn on page-turn mode in Settings and swipe one page at a time
- [ ] Add a new page from the toolbar
- [ ] Open page overview (grid of thumbnails)
- [ ] Jump to a page from the overview
- [ ] Reorder pages by dragging in the overview
- [ ] Long-press to multi-select pages and batch-delete
- [ ] Bookmark a page in page settings
- [ ] Jump to previous / next bookmark from the toolbar
- [ ] Change page template (blank, lined, grid, dotted, college ruled)
- [ ] Change page size (A4, A5, Letter) — confirm dialog if page has ink
- [ ] Set a page to portrait or landscape (non-PDF pages)
- [ ] Insert an image on a page
- [ ] Open auto table of contents and jump to a heading
- [ ] Heavy page warning appears around 2000 strokes; try Split page
- [ ] Switch pages, draw on each, switch back — undo history is still there

---

## Drawing & tools

- [ ] Draw with pen (pressure feels natural on stylus)
- [ ] Switch brush types: fountain, pencil, marker, calligraphy
- [ ] Draw with highlighter (semi-transparent)
- [ ] Erase whole strokes with the eraser
- [ ] Partial eraser: clip ink inside the eraser circle (toggle in eraser options)
- [ ] Draw shapes (line, rectangle, ellipse, arrow)
- [ ] Tap inside a closed pen/shape loop to flood-fill
- [ ] Add typed text; tap existing text to edit
- [ ] Rotate typed text with selection handles
- [ ] Lasso: draw a loop, move, copy, paste, scale, and rotate selection
- [ ] Selection tool: marquee select, move, scale, rotate (including images)
- [ ] Convert selected handwriting to typed text (lasso or selection)
- [ ] Tape tool: cover ink, tap tape to hide/reveal
- [ ] Undo and redo (up to 100 steps on one page)
- [ ] Toggle stroke smoothing in Settings and compare ink feel

---

## S Pen

- [ ] Hold S Pen barrel button → temporary eraser; release restores prior tool
- [ ] Change barrel action in Settings (eraser, lasso, or pen)
- [ ] Stylus-only mode: stylus draws, finger pans and zooms (no finger ink)
- [ ] Finger drawing mode: finger can draw on the page

---

## OCR & search

- [ ] Write by hand; wait for OCR badge on page overview (indexed)
- [ ] Search notebook finds your handwritten words (after indexing)
- [ ] Add custom OCR terms in Settings; search recognizes domain words better
- [ ] Scratch a zigzag over indexed handwriting to delete it (Settings toggle)
- [ ] Search also finds typed text and notebook titles

---

## PDF

- [ ] Import a multi-page PDF; pages render when opened
- [ ] Draw and annotate on imported PDF pages
- [ ] Tap a hyperlink on a PDF page (finger, not stylus) — opens in browser
- [ ] Search finds text that was embedded in the PDF at import

---

## Export

- [ ] Export current page as PNG (page settings → share sheet)
- [ ] Export current page as PDF
- [ ] Export full notebook as multi-page PDF (progress dialog on large notebooks)
- [ ] Pen and highlighter strokes stay crisp when zooming the exported PDF

---

## Audio on pages

- [ ] Attach a local audio file to a page (page settings)
- [ ] Play and pause the attached audio preview
- [ ] Audio stays with the page after closing and reopening the notebook

---

## Settings

- [ ] **Your data** — shows database path and folder sizes
- [ ] **OCR dictionary** — add and remove custom terms
- [ ] **Toolbar order** — drag tools to reorder; editor reflects new order
- [ ] **S Pen** — barrel button action and description
- [ ] **Page-turn scroll mode** — toggle on/off
- [ ] **Stroke smoothing** — toggle on/off
- [ ] **Gesture ink editing** — toggle scratch-to-delete on/off
- [ ] **Backup & Restore** — export zip, recover from auto-backup, restore from file

---

## Zoom & navigation

> Pinch zoom reliability fix shipped in **v0.2.41**.

- [ ] Pinch to zoom in and out on a page (two fingers)
- [ ] Pinch zoom works in stylus-only mode (finger pinches, stylus can still draw)
- [ ] Pinch zoom works in finger drawing mode
- [ ] Pan around while zoomed in
- [ ] Ink stays aligned on the paper after zooming
- [ ] **Landscape device + portrait A4 page:** page is centered; pinch zoom for detail; rotate device — ink still on paper
- [ ] Vertical scroll between pages still feels smooth while zoomed

---

## Session

- [ ] Force-close the app while editing a notebook
- [ ] Reopen — same notebook, same page, same scroll position, same tool selected

---

*Last updated for Penfold v0.2.47*
