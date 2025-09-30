import 'package:flutter/material.dart';
import 'package:checkin_frontend/widgets/app_navigation_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({required this.child, required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const AppNavigationBar(), body: child);
  }
}
