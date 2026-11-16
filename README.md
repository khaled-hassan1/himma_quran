# himma_quran

A Flutter mushaf (Quran page) reader: the Madinah mushaf in the QPC v4
colour fonts, tajweed, the ten readings, tafsir, ayah audio and a
recitation check (tasmee').

It is built from [quran_library](https://pub.dev/packages/quran_library)
5.0.1 (MIT, © Alheekmah Library) and reworked for smooth page turns,
lower memory and one page size on every screen. Everything that changed
is listed in [CHANGELOG.md](CHANGELOG.md).

> **Note:** this package holds code only. The fonts, Quran data and
> images are read from `quran_library`'s own package assets
> (`packages/quran_library/...`), so `quran_library` 5.0.1 is a
> dependency and both are downloaded.

## What changed from quran_library

- **Smooth page turns:** the page on screen builds first, and its
  neighbours build one per frame after the turn stops. Frames during a
  slide take 1–3 ms (upstream: 50–70 ms on each new page).
- **Lower memory:** only the 6 pages around the one on screen are kept
  (upstream kept every page opened).
- **One page size:** lines are laid out at one size and the page is
  fitted to its box, so the surah banner, name and basmala keep their
  size on phones, tablets and wide screens.
- **Theme and highlight changes** repaint only what changed.
- **Fonts:** each page loads only the font copies its mode draws with.
- **Several mushafs open at once** (for example one in a tab under
  another screen) without the "Too many elements" error on a jump.
- **Word sheet** (short hold on a word) shows the word itself.

## Install

```yaml
dependencies:
  himma_quran: ^1.0.0
```

## Use

Call `QuranLibrary.init()` once before showing the mushaf, then put a
`QuranLibraryScreen` where it should show:

```dart
import 'package:flutter/material.dart';
import 'package:himma_quran/himma_quran.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuranLibrary.init();
  runApp(const MaterialApp(home: MushafPage()));
}

class MushafPage extends StatelessWidget {
  const MushafPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: QuranLibraryScreen(
        parentContext: context,
        appLanguageCode: 'ar',
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    ),
  );
}
```

The API is the same as `quran_library` 5.0.1's, so its documentation
applies (styles, bookmarks, search, audio, tafsir). A full example is in
[example/](example/).

## License

MIT. The original code is © 2025 Alheekmah Library; see [LICENSE](LICENSE).
