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

/// Application entry point. Initializes core services, external configurations,
/// and starts the Flutter application within a ProviderScope.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage and cloud services
  final prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  // Enable performance monitoring only in release builds
  if (kReleaseMode) {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }

  // Use standard URL paths (removes the '#' from the URL in web browsers)
  usePathUrlStrategy();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the real SharedPreferences instance into the dependency tree
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application. Handles high-level configuration including
/// themes, localization, and routing based on global state.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch global providers for reactive UI updates (Theme and Language)
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'CheckIn App',
      debugShowCheckedModeBanner: false,

      // Localization configuration
        locale: const Locale('en', 'US'),
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
        supportedLocales: const [Locale('en', 'US')],

      // Theme configuration
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Routing configuration via GoRouter
      routerConfig: ref.watch(routerProvider),
    );
  }
}