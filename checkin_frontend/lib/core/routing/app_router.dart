import 'package:checkin_frontend/features/home/views/pages/home_page.dart';
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

/// Global key for the root navigator to allow navigation outside of the widget tree.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provides the GoRouter configuration for the application, handling deep linking and route protection.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<bool>(false);

  // Trigger router refresh whenever the authentication state changes
  ref.listen(authProvider, (_, __) {
    refreshListenable.value = !refreshListenable.value;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,

    /// Logic for handling redirects based on authentication status and deep link parameters.
    redirect: (context, state) {
      final auth = ref.read(authProvider);

      // Prevent redirection while the auth state is still loading from storage
      if (auth.isInitializing) return null;

      final bool isLoggedIn = auth.user != null;
      final String path = state.uri.path;

      // Handle root path redirection
      if (path == '/') {
        return isLoggedIn ? '/tasks' : '/welcome';
      }

      // Handle users accessing login while already authenticated
      if (isLoggedIn && path == '/login') {
        final String? from = state.uri.queryParameters['redirect'];
        // If a redirect URL was saved, send the user back there, otherwise go to dashboard
        if (from != null && from.isNotEmpty) {
          return from;
        }
        return '/tasks';
      }

      // Protect private routes from unauthorized access
      final publicPaths = ['/welcome', '/login'];
      final isPublicPath = publicPaths.contains(path) || path.startsWith('/p/');

      if (!isPublicPath && !isLoggedIn) {
        // Save the intended destination to return after successful login
        final encodedRedirect = Uri.encodeComponent(state.uri.toString());
        return '/login?redirect=$encodedRedirect';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      /// ShellRoute provides a shared layout (Navigation Bar/Drawer) for internal pages.
      ShellRoute(
        builder: (context, state, child) {
          return Consumer(
            builder: (context, ref, _) {
              final auth = ref.watch(authProvider);
              // Ensure layout is not rendered until authentication state is resolved
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

      /// Public route for responding to a task checklist (does not use MainLayout).
      GoRoute(
        path: '/p/:hash',
        builder: (context, state) => TaskRespondPage(taskHash: state.pathParameters['hash']!),
      ),
    ],
  );
});