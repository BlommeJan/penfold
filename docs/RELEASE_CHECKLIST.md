# Penfold release checklist

Hardware targets for ink latency and regression QA before shipping.

## Devices

| Tier | Device | SoC | Notes |
|------|--------|-----|-------|
| **Budget** | Galaxy Tab S6 Lite | Snapdragon 720G | Minimum supported; ink must not drop strokes |
| **Flagship** | Galaxy Tab S9 / S9+ | Snapdragon 8 Gen 2 | Reference latency; no visible lag vs Samsung Notes |

## Ink latency (v0.2.10+)

- [ ] Pen-down to first pixel **< 16 ms** on flagship, **< 32 ms** on S6 Lite
- [ ] Continuous stroke at max speed: no dropped segments, no visible gaps > 2 mm
- [ ] Scroll notebook with 20+ inked pages: no jank spikes > 1 frame on active page
- [ ] `flutter test test/ink_perf_test.dart` passes (coalesce point budget)
- [ ] Partial eraser drag on 500+ stroke page remains responsive

## Functional smoke

- [ ] FTS search regression (`test/database_test.dart`)
- [ ] PDF import + export (`test/page_export_test.dart`)
- [ ] Undo/redo 100 steps on single page
- [ ] Stylus-only mode: finger pans, stylus draws

## Export / backup

- [ ] 50+ page PDF export completes; cancel does not hang
- [ ] Highlighter alpha visible in exported PDF (not opaque blocks)

---

*Checklist version: v0.2.10 · Updated 2026-07-15*
