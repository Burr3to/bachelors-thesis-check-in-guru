// lib/widgets/app_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/config/app_constants.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart';
// import 'package:url_launcher/url_launcher.dart'; // ZAKOMENTUJTE ALEBO ODSTRÁŇTE TENTO IMPORT
import 'dart:js_interop'; // PRIDAJTE TENTO IMPORT
import 'package:web/web.dart' as web; // PRIDAJTE TENTO IMPORT
import 'package:checkin_frontend/config/app_constants.dart';

class AppNavigationBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppNavigationBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final String backendGoogleLoginUrl = kBackendGoogleLoginEndpoint;
    print('AppNavigationBar: Pokúšam sa spustiť Google prihlásenie cez URL: $backendGoogleLoginUrl'); // DIAGNOSTIKA

    try {
      // *** KĽÚČOVÁ ZMENA: Priame volanie window.open bez noopener ***
      final web.Window? newWindow = web.window.open(backendGoogleLoginUrl, '_blank'); // Tretí parameter 'features' je prázdny reťazec, čo znamená žiadne špeciálne vlastnosti ako 'noopener'.

      if (newWindow == null) {
        print('AppNavigationBar: Chyba: Nepodarilo sa otvoriť nové okno pre Google prihlásenie.'); // DIAGNOSTIKA
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepodarilo sa spustiť Google prihlásenie.')),
        );
      } else {
        print('AppNavigationBar: Úspešne otvorené nové okno pre Google prihlásenie pomocou window.open.'); // DIAGNOSTIKA
        // Môžete zvážiť uloženie referencie na newWindow a sledovať jeho stav, ak potrebujete.
      }
    } catch (e) {
      print('AppNavigationBar: Chyba pri otváraní okna pomocou window.open: $e'); // DIAGNOSTIKA
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba pri spúšťaní Google prihlásenia: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(authProvider);
    final isLoggedIn = userProfile != null;
    final authNotifier = ref.read(authProvider.notifier);

    print('AppNavigationBar: build volaný. Používateľ je ${isLoggedIn ? 'prihlásený (${userProfile!.email})' : 'odhlásený'}.'); // DIAGNOSTIKA


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
            print('AppNavigationBar: Kliknuté na "Eventy".'); // DIAGNOSTIKA
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
                  print('AppNavigationBar: Kliknuté na "Odhlásiť sa".'); // DIAGNOSTIKA
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
              print('AppNavigationBar: Kliknuté na "Prihlásiť sa".'); // DIAGNOSTIKA
              _handleGoogleSignIn(context, ref);
            },
          ),

        const SizedBox(width: 8),
      ],
    );
  }
}