import 'package:flutter/material.dart';
import 'package:himma_quran/himma_quran.dart';

/// The mushaf on one screen, in the system's light or dark theme.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Once, before the first mushaf shows.
  await QuranLibrary.init();
  runApp(const MushafApp());
}

class MushafApp extends StatelessWidget {
  const MushafApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'himma_quran',
    theme: ThemeData(useMaterial3: true),
    darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
    home: const MushafPage(),
  );
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
