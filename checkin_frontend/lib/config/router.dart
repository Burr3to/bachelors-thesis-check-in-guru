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
          // Nová cesta pre spracovanie úspešného prihlásenia z backendu
          GoRoute(
            path: '/login-success',
            builder: (context, state) {
              print('Router: Zachytená /login-success cesta. Celá URI: ${state.uri}'); // <--- PRIDANÉ
              final token = state.uri.queryParameters['token'];
              print('Router: Extrahovaný token: ${token != null && token.isNotEmpty ? "Áno" : "Nie"}'); // <--- PRIDANÉ
              if (token != null && token.isNotEmpty) {
                Future.microtask(() => authNotifier.signInWithToken(token));
                print('Router: Volám authNotifier.signInWithToken'); // <--- PRIDANÉ
                return const Text('Prebieha prihlasovanie...');
              }
              print('Router: Token chýba alebo je prázdny, zobrazujem chybu.'); // <--- PRIDANÉ
              return const LoginPage(errorMessage: 'Chyba: Token pre prihlásenie nebol nájdený.');
            },
          ),
          GoRoute(
            path: '/login-error',
            builder: (context, state) {
              final message = state.uri.queryParameters['message'] ?? 'Neznáma chyba pri prihlásení.';
              print('Router: Zachytená /login-error cesta. Správa: $message'); // <--- PRIDANÉ
              return LoginPage(errorMessage: message);
            },
          ),
        ],
      ),
    ],
  );
});
