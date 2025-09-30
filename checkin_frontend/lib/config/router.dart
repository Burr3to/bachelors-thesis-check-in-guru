// lib/config/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:checkin_frontend/widgets/main_layout.dart';
import 'package:checkin_frontend/pages/checkin_events_page.dart';
import 'package:checkin_frontend/pages/homepage.dart';
import 'package:checkin_frontend/config/app_constants.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart';
import 'package:checkin_frontend/pages/login_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authProvider.notifier);

  return GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final currentIndex = navBarPaths.indexWhere((path) => state.matchedLocation == path);

          return MainLayout(currentIndex: currentIndex < 0 ? 0 : currentIndex, child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(path: '/CheckInEvents', builder: (context, state) => const CheckInEventsPage()),
          GoRoute(
            path: '/login-success',
            builder: (context, state) {
              final token = state.uri.queryParameters['token'];
              if (token != null && token.isNotEmpty) {
                Future.microtask(() => authNotifier.signInWithToken(token));
                return const Text('Prebieha prihlasovanie...');
              }
              return const LoginPage(errorMessage: 'Chyba: Token pre prihlásenie nebol nájdený.');
            },
          ),
          GoRoute(
            path: '/login-error',
            builder: (context, state) {
              final message =
                  state.uri.queryParameters['message'] ?? 'Neznáma chyba pri prihlásení.';
              return LoginPage(errorMessage: message);
            },
          ),
        ],
      ),
    ],
  );
});
