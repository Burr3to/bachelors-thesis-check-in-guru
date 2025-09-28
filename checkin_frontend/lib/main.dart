import 'package:checkin_frontend/widgets/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:checkin_frontend/pages/checkin_events_page.dart';
import 'package:checkin_frontend/pages/homepage.dart';
import 'package:checkin_frontend/config/app_constants.dart';

final GoRouter _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final currentIndex = navBarPaths.indexWhere(
          (path) => state.matchedLocation == path,
        );

        return MainLayout(
          currentIndex: currentIndex < 0 ? 0 : currentIndex,
          child: child,
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/CheckInEvents',
          builder: (context, state) => const CheckInEventsPage(),
        ),
      ],
    ),
  ],
);

// 2. Wrapni aplikáciu v ProviderScope pre Riverpod
void main() {
  runApp(
    const ProviderScope(
      // Kľúčový obal pre Riverpod
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CheckIn Guru',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}
