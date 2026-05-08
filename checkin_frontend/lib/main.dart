// lib/main.dart
import 'package:checkin_frontend/core/theme/app_theme.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/locale_provider.dart';
import 'core/routing/app_router.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializuj SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  if (kReleaseMode) {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }

  usePathUrlStrategy();

  runApp(
    ProviderScope(
      overrides: [
        // 2. Prekryjeme provider reálnou inštanciou prefs
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'CheckIn App',
      debugShowCheckedModeBanner: false,

      locale: locale,

      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],

      supportedLocales: AppLocalizations.supportedLocales,

      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      routerConfig: ref.watch(routerProvider),
    );
  }
}
