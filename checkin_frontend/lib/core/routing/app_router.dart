import 'package:checkin_frontend/features/home/views/pages/home_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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

// 1. DEFINÍCIA KĽÚČA (Tento riadok tu musí byť hore)
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<bool>(false);

  // Sledujeme zmeny authProvidera, aby sme spustili redirect
  ref.listen(authProvider, (_, __) {
    refreshListenable.value = !refreshListenable.value;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    debugLogDiagnostics: true,

    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],

    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isInitializing) return null;

      final bool isLoggedIn = auth.user != null;
      final String path = state.uri.path;

      // 1. Ak je prihlásený a ide na login, pošli ho do appky (predvolene na tasks)
      if (path == '/login' && isLoggedIn) {
        final String? redirectTo = state.uri.queryParameters['redirect'];
        return (redirectTo != null && redirectTo.isNotEmpty) ? redirectTo : '/app/tasks';
      }

      // 2. Ochrana súkromných ciest
      // POZOR: Povolíme cestu '/app/home' aj pre neprihlásených
      if (path.startsWith('/app') && path != '/app/home') {
        if (!isLoggedIn) {
          return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
        }
      }

      // 3. Ak niekto príde na čisté "/" alebo "/app", pošleme ho na home
      if (path == '/' || path == '/app') return '/app/home';

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          // 2. OPRAVA authState: Použijeme Consumer, aby sme sledovali loading
          return Consumer(
            builder: (context, ref, _) {
              final auth = ref.watch(authProvider);
              if (auth.isInitializing) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return MainLayout(child: child);
            },
          );
        },
        routes: [
          GoRoute(
              path: '/app/home',
              builder: (context, state) => const HomePage()
          ),
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
          // 3. OPRAVA authState aj tu (pre verejnú stránku)
          return Consumer(
            builder: (context, ref, _) {
              final auth = ref.watch(authProvider);
              if (auth.isInitializing) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return TaskRespondPage(taskHash: state.pathParameters['hash']!);
            },
          );
        },
      ),
    ],
  );
});