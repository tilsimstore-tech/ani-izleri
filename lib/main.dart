import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'data/models/media_item.dart';
import 'data/models/memory_entry.dart';
import 'data/providers/app_provider.dart';
import 'features/cover/cover_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MemoryEntryAdapter());
  Hive.registerAdapter(MediaItemAdapter());
  final appProvider = AppProvider();
  await appProvider.init();
  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const TilsimApp(),
    ),
  );
}

class TilsimApp extends StatelessWidget {
  const TilsimApp({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().theme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anı İzleri',
      locale: const Locale('tr', 'TR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        colorSchemeSeed: t.accent,
        useMaterial3: true,
        scaffoldBackgroundColor: t.bg,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: t.ink,
          contentTextStyle: TextStyle(color: t.bg),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const CoverScreen(),
    );
  }
}