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
    initialLocation: '/app/tasks',
    refreshListenable: refreshListenable,
    debugLogDiagnostics: true,

    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],

    redirect: (context, state) {
      // Získame aktuálny stav (read namiesto watch)
      final auth = ref.read(authProvider);

      if (auth.isInitializing) return null;

      final bool isLoggedIn = auth.user != null;
      final String path = state.uri.path;

      // Logika pre návrat z Login stránky
      if (path == '/login' && isLoggedIn) {
        final String? redirectTo = state.uri.queryParameters['redirect'];
        return (redirectTo != null && redirectTo.isNotEmpty) ? redirectTo : '/app/tasks';
      }

      // Ochrana súkromných ciest
      if (path.startsWith('/app')) {
        if (!isLoggedIn) {
          return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
        }
        return null;
      }

      if (path == '/' || path == '/app') return '/app/tasks';

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