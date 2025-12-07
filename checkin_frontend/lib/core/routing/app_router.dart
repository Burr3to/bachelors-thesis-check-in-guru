import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:checkin_frontend/features/auth/views/pages/login_page.dart';
import 'package:checkin_frontend/core/shared_widgets/main_layout.dart';

import '../../features/task_create/views/pages/task_create_page.dart';
import '../../features/task_overview/views/pages/task_overview_page.dart';
import '../../features/task_respond/views/pages/task_respond_page.dart';
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
      final isLoggedIn = authState != null;

      // Zistíme, kam user ide
      final path = state.uri.path;
      final isLoggingIn = path == '/login';

      // NOVÉ: Zistíme, či ide na verejný checkin link
      final isPublicLink = path.startsWith('/checkin');

      // 1. Ak je prihlásený a ide na login -> presmeruj na home
      if (isLoggedIn && isLoggingIn) return '/home';

      // 2. Ak NIE JE prihlásený
      if (!isLoggedIn) {
        // Povolíme mu ísť na Login ALEBO na Verejný link
        if (isLoggingIn || isPublicLink) {
          return null; // Dovoľ mu pokračovať tam, kam ide
        }

        // Inak ho pošli na login (napr. ak sa snaží ísť na /home bez prihlásenia)
        return '/login';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/checkin/:hash',
        builder: (context, state) {
          final hash = state.pathParameters['hash'];
          return TaskRespondPage(taskHash: hash!); // Pošleme Hash, nie ID
        },
      ),

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
              GoRoute(
                path: 'create', // Žiadna lomka! Výsledok: /home/create
                builder: (context, state) {
                  return const TaskCreatePage(); // Tvoja nová stránka
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
