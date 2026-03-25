// lib/main.dart
import 'package:checkin_frontend/core/theme/app_theme.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'core/providers/locale_provider.dart';
import 'core/routing/app_router.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  if (kReleaseMode) {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    print("Firebase Performance Monitoring Enabled");
  }


  usePathUrlStrategy();

  runApp(const ProviderScope(child: MyApp()));
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
