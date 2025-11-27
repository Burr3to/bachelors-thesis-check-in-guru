import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:checkin_frontend/features/auth/views/pages/login_page.dart';
import 'package:checkin_frontend/core/shared_widgets/main_layout.dart';

import '../../features/tasks/views/pages/task_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Home")));
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // ZMENA 1: Sledujeme priamo STAV (UserProfile?), nie notifier.
  // Toto spôsobí, že sa router "prebuduje" a skontroluje redirect vždy, keď sa zmení user.
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',

    // ZMENA 2: Logika redirectu na základe stavu (authState môže byť null)
    redirect: (context, state) {
      // Ak authState nie je null, sme prihlásení
      final isLoggedIn = authState != null;
      final isLoggingIn = state.uri.path == '/login';

      // 1. Ak sme prihlásení a snažíme sa ísť na login -> pošli na home
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      // 2. Ak NIE sme prihlásení a snažíme sa ísť niekam inam ako na login -> pošli na login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // Inak nerob nič (dovoľ navigáciu)
      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const TaskListPage()),
        ],
      ),
    ],
  );
});
