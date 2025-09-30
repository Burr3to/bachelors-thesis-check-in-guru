// lib/widgets/app_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/config/app_constants.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart';

import 'package:web/web.dart' as web;

class AppNavigationBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppNavigationBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Handles the Google Sign-In process by opening a new browser window
  void _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final String backendGoogleLoginUrl = kBackendGoogleLoginEndpoint;

    try {
      final web.Window? newWindow = web.window.open(
        backendGoogleLoginUrl,
        '_blank',
      );

      if (newWindow == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nepodarilo sa spustiť Google prihlásenie.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chyba pri spúšťaní Google prihlásenia: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authProvider to get the current user's profile and react to changes.
    final userProfile = ref.watch(authProvider);
    final isLoggedIn = userProfile != null;
    final authNotifier = ref.read(authProvider.notifier);

    return AppBar(
      title: InkWell(
        onTap: () {
          GoRouter.of(context).go(navBarPaths[0]);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_box, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Check In Guru',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),

      backgroundColor: Colors.blueAccent,
      elevation: 4,

      actions: [
        TextButton(
          onPressed: () {
            GoRouter.of(context).go(navBarPaths[1]);
          },
          child: const Text(
            'Eventy',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        if (isLoggedIn)
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      userProfile!.name ?? userProfile.email,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      userProfile.email,
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Odhlásiť sa',
                onPressed: () {
                  authNotifier.signOut();
                  GoRouter.of(context).go(navBarPaths[0]);
                },
              ),
            ],
          )
        else
          TextButton.icon(
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Prihlásiť sa',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              _handleGoogleSignIn(context, ref);
            },
          ),

        const SizedBox(width: 8),
      ],
    );
  }
}
