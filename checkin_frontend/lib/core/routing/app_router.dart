import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Importy tvojich featúr
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:checkin_frontend/features/auth/views/pages/login_page.dart';
import 'package:checkin_frontend/core/shared_widgets/main_layout.dart';
import 'package:checkin_frontend/features/task_create/views/pages/task_create_page.dart';
import 'package:checkin_frontend/features/task_list/views/pages/task_list_page.dart';
import 'package:checkin_frontend/features/task_overview/views/pages/task_overview_page.dart';
import 'package:checkin_frontend/features/task_respond/views/pages/task_respond_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {

  // Vytvoríme inštanciu routera
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',

    // Zapne logovanie zmien v konzole (veľmi užitočné pri vývoji)
    debugLogDiagnostics: true,

    redirect: (context, state) {
      // TU ČÍTAME TVOJ STAV (JWT token z Backend-u)
      final authState = ref.read(authProvider);
      final isLoggedIn = authState != null;

      final path = state.uri.path;
      final queryParams = state.uri.queryParameters;

      print("---------------------------------------");
      print("ROUTER REDIRECT LOG:");
      print("Aktuálna cesta (path): $path");
      print("Prihlásený (Backend JWT): $isLoggedIn");
      print("Query parametre: $queryParams");

      // 1. Verejné linky checkin - ignorujeme, nech si ich rieši stránka sama
      if (path.startsWith('/checkin')) {
        return null;
      }

      final isLoggingIn = path == '/login';

      // 2. Logika po prihlásení (keď už máme JWT)
      if (isLoggedIn && isLoggingIn) {
        final redirectTo = queryParams['redirect'];

        if (redirectTo != null && redirectTo.isNotEmpty) {
          print("ROUTER: Užívateľ prihlásený, vraciam sa na: $redirectTo");
          return redirectTo;
        }

        print("ROUTER: Žiadny redirect, idem na /home");
        return '/home';
      }

      // 3. Logika pre neprihláseného užívateľa
      if (!isLoggedIn && !isLoggingIn) {
        print("ROUTER: Neprihlásený užívateľ, smerujem na login.");
        return '/login';
      }

      return null;
    },

    routes: [
      // Stránka prihlásenia
      GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage()
      ),

      // Verejná stránka pre Task (CheckIn)
      GoRoute(
        path: '/checkin/:hash',
        builder: (context, state) {
          final hash = state.pathParameters['hash'];
          return TaskRespondPage(taskHash: hash!);
        },
      ),

      // Chránené cesty zabalené v MainLayout (ShellRoute)
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const TaskListPage(),
            routes: [
              // Cesta: /home/task/:taskId
              GoRoute(
                path: 'task/:taskId',
                builder: (context, state) {
                  final id = state.pathParameters['taskId'];
                  return TaskOverviewPage(taskId: id!);
                },
              ),
              // Cesta: /home/create
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  return const TaskCreatePage();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // --- TOTO JE TA NAJDÔLEŽITEJŠIA ČASŤ ---
  // Sledujeme tvoj authProvider. Keď sa v ňom zmení stav
  // (napr. úspešne prebehne overenie Firebase tokenu na tvojom Backende),
  // povieme routeru, aby znova spustil funkciu redirect.
  ref.listen(authProvider, (previous, next) {
    if (previous != next) {
      print("ROUTER: AuthProvider sa zmenil! Osviežujem redirect logiku...");
      router.refresh();
    }
  });

  return router;
});