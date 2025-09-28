import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/config/app_constants.dart';

// POZNÁMKA: Pre jednoduchosť používame StatelessWidget.
// V reálnej aplikácii by tento widget musel sledovať stav užívateľa cez Riverpod.

class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavigationBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // '/'
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      
      backgroundColor: Colors.blueAccent,
      elevation: 4,

      actions: [
        // NOVÉ TLAČIDLO PRE EVENTY
        TextButton(
          onPressed: () {
            // CheckInEvents
            GoRouter.of(context).go(navBarPaths[1]); 
          },
          child: const Text(
            'Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Mini Profil Karta (Meno a Email)
        const Padding(
          padding: EdgeInsets.only(right: 16.0, left: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Test User', // TODO: Nahradiť za dynamické meno z Riverpodu
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Text(
                'test.user@checkin.sk', // TODO: Nahradiť za dynamický email
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        
        
        SizedBox(width: 8), // Malý priestor na konci
      ],
    );
  }
}
