## 1.0.1

- **Two-page view** — the pages on screen were taken for far ones (the
  page view's position was divided by the whole screen, not by one page's
  half of it), so they were built late: a blank page for a second or two
  after a jump (most visible on the web). The item width now comes from
  the page view's own controller.

## 1.0.0

First release: quran_library 5.0.1, copied as is (renamed to himma_quran), with these changes.


- **Page turns** — each page view item (`_KeepAlive`, page_view_build.dart)
  builds at once only when it is the page on screen; the pages around it
  build after the turn has stopped, one per frame, nearest first. Upstream
  built the page two ahead in the middle of the slide (a 50–70 ms frame on
  each new page); the slide's frames are now 1–3 ms.
- **Memory** — pages are kept alive only within 6 of the one on screen
  (upstream kept every page ever opened).
- **Theme changes** — a page off screen keeps the theme it was drawn with
  and takes the new one after the page on screen, one per frame (upstream
  re-laid out every kept page in the frame of the change).
- **Highlight colours** — a line's cache key (`_computeFingerprint`,
  rich_text_build.dart) includes its colours: upstream kept a line in the
  old highlight / text colour when only the colour changed.
- **Fonts** — each page loads only the copies its current mode draws with
  (no tajweed: `n` + `nd`; tajweed: `''` + `d`), not all five; the others
  (and `nr`, the ten readings' red) load when their mode is turned on, a
  loaded copy drawing meanwhile (`QuranFontsService.variantFamily`).

### One page size on every screen
- Mushaf lines are always laid out at `QuranPageScale.lineFontSize` (100) and the page is fitted to its box; upstream used `23.1.sp` (phone), `15.sp` (tablet) or 100 (landscape), so given header sizes were off on tablets and wide single pages.
- Header styles (banner, surah name, basmala) are given in those page units; `scaledBy` extensions scale them where they sit over normal text (zoomed flowing page, ayah + tafsir, surah view).

### More than one mushaf open
- `QuranPagesController` (patched_preload_page_view.dart) replaces the plain `PreloadPageController`: a jump moves every attached page view and `page` reads the newest. The base controller threw "Too many elements" when a mushaf kept in a tab sat under a screen with another one, so the jump never happened (the parent's «في المصحف» opened on the wrong page with no marks).

### Word sheet shows its word
- The word info sheet (short hold on a word) now shows the word itself in the mushaf's face above «عن الكلمة»; `QpcHafsWordByWordAssetsLoader.shared()` loads the word list once for the sheet and the app.
