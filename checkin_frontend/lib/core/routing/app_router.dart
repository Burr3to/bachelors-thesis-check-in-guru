import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:checkin_frontend/features/auth/views/pages/login_page.dart';
import 'package:checkin_frontend/core/shared_widgets/main_layout.dart';
import 'package:checkin_frontend/features/task_create/views/pages/task_create_page.dart';
import 'package:checkin_frontend/features/task_list/views/pages/task_list_page.dart';
import 'package:checkin_frontend/features/task_overview/views/pages/task_overview_page.dart';
import 'package:checkin_frontend/features/task_respond/views/pages/task_respond_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Tu budeme sledovať authState, aby sme mohli reagovať na zmeny
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // DÔLEŽITÉ: initialLocation sa použije len vtedy, ak nie je zadaná žiadna URL
    initialLocation: '/app/tasks',
    debugLogDiagnostics: true,

    redirect: (context, state) {
      // Ak inicializujeme, nič nerobíme (ostávame na URL, ktorú užívateľ zadal)
      if (authState.isInitializing) return null;

      final bool isLoggedIn = authState.user != null;
      final String path = state.uri.path;

      // Debug logy pre tvoju kontrolu
      print("ROUTER REDIRECT: path=$path, loggedIn=$isLoggedIn");

      if (path == '/' || path == '/app') return '/app/tasks';

      // Ochrana /app zóny
      if (path.startsWith('/app')) {
        if (!isLoggedIn) return '/login?redirect=${Uri.encodeComponent(path)}';
        return null;
      }

      if (path == '/login' && isLoggedIn) return '/app/tasks';

      return null;
    },

    routes: [
      // PRIDAJ TÚTO CESTU PRE LOADING (voliteľné, ale dobré)
      // GoRoute(path: '/loading', builder: (context, state) => const LoadingPage()),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          // TU VYRIEŠIME LOADING OBRAZOVKU
          if (authState.isInitializing) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/app/tasks',
            builder: (context, state) => const TaskListPage(),
            routes: [
              GoRoute(
                path: 'details/:taskId',
                builder: (context, state) => TaskOverviewPage(taskId: state.pathParameters['taskId']!),
              ),
            ],
          ),
          GoRoute(path: '/app/create', builder: (context, state) => const TaskCreatePage()),
        ],
      ),

      GoRoute(
        path: '/p/:hash',
        builder: (context, state) {
          // AJ TU VYRIEŠIME LOADING PRE VEREJNÚ STRÁNKU
          if (authState.isInitializing) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return TaskRespondPage(taskHash: state.pathParameters['hash']!);
        },
      ),
    ],
  );
});