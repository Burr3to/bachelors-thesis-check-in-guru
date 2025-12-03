import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:checkin_frontend/features/auth/views/pages/login_page.dart';
import 'package:checkin_frontend/core/shared_widgets/main_layout.dart';

import '../../features/task_overview/views/pages/task_overview_page.dart';
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
    redirect: (context, state) {
      // ... tvoja existujúca redirect logika ...
      final isLoggedIn = authState != null;
      final isLoggingIn = state.uri.path == '/login';
      if (isLoggedIn && isLoggingIn) return '/home';
      if (!isLoggedIn && !isLoggingIn) return '/login';
      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // RODIČOVSKÁ CESTA (/home)
          GoRoute(
            path: '/home',
            builder: (context, state) => const TaskListPage(),

            // --- TU SÚ VNORENÉ CESTY (DETI) ---
            routes: [
              GoRoute(
                // Pozor: Žiadna lomka na začiatku!
                // Výsledná cesta bude: /home/task/:taskId
                path: 'task/:taskId',
                builder: (context, state) {
                  final id = state.pathParameters['taskId'];
                  return TaskOverviewPage(taskId: id!);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
