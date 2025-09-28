import 'package:flutter/material.dart';
import 'package:checkin_frontend/widgets/app_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/config/app_constants.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // Stránka, ktorá sa mení
  final int currentIndex;

  const MainLayout({
    required this.child,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Horná lišta: Používame náš vlastný komplexný widget
      // POZNÁMKA: Tu by sme mohli predať currentIndex, ak by AppBar menil svoj vzhľad
      // na základe aktívnej stránky, ale momentálne ponechávame const.
      appBar: const AppNavigationBar(),

      body: child,
    );
  }
}
