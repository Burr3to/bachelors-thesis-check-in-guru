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

  ref.listen(authProvider, (_, __) {
    refreshListenable.value = !refreshListenable.value;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    debugLogDiagnostics: true, // GoRouter sám bude vypisovať detaily do konzoly

    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isInitializing) return null;

      final bool isLoggedIn = auth.user != null;
      final String path = state.uri.path;

      // DEBUG VÝPISY
      debugPrint('--- [ROUTER REDIRECT] ---');
      debugPrint('Current Path: $path');
      debugPrint('Logged In: $isLoggedIn');
      debugPrint('Redirect Query Param: ${state.uri.queryParameters['redirect']}');

      // --- LOGIKA PRE ROOT "/" ---
      if (path == '/') {
        final target = isLoggedIn ? '/tasks' : '/welcome';
        debugPrint('Root path "/" detected. Sending to: $target');
        return target;
      }

      // --- FIX: LOGIKA PRE PRIHLÁSENÉHO NA LOGIN STRÁNKE ---
      if (isLoggedIn && path == '/login') {
        final String? from = state.uri.queryParameters['redirect'];
        if (from != null && from.isNotEmpty) {
          debugPrint('User logged in. Found redirect parameter. Sending to: $from');
          return from; // Vráti ho tam, odkiaľ prišiel (napr. /tasks/create)
        }
        debugPrint('User logged in. No redirect param. Sending to default: /tasks');
        return '/tasks';
      }

      // --- OCHRANA SÚKROMNÝCH CIEST ---
      final publicPaths = ['/welcome', '/login'];
      final isPublicPath = publicPaths.contains(path) || path.startsWith('/p/');

      if (!isPublicPath && !isLoggedIn) {
        final encodedRedirect = Uri.encodeComponent(state.uri.toString());
        debugPrint('Unauthorized access to $path. Redirecting to login with return path.');
        return '/login?redirect=$encodedRedirect';
      }

      debugPrint('No redirect needed for: $path');
      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      ShellRoute(
        builder: (context, state, child) {
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
            path: '/welcome',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const TaskCreatePage(),
              ),
              GoRoute(
                path: ':taskId',
                builder: (context, state) => TaskOverviewPage(taskId: state.pathParameters['taskId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/shared',
            builder: (context, state) => const Scaffold(body: Center(child: Text("Shared Tasks coming soon"))),
          ),
        ],
      ),

      GoRoute(
        path: '/p/:hash',
        builder: (context, state) => TaskRespondPage(taskHash: state.pathParameters['hash']!),
      ),
    ],
  );
});