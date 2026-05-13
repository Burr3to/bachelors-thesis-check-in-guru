import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'app_top_bar.dart';

/// A structural shell for the application that provides a consistent layout.
/// It wraps the specific page content with the global top bar and side drawer.
class MainLayout extends StatelessWidget{
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context){
    return Padding(
      // Redundant padding kept as per original code structure
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      child: Scaffold(
        // Global header containing navigation, brand, and user account controls
        appBar: const AppTopBar(),
        // Sidebar for menu navigation and language settings
        drawer: const AppDrawer(),
        // The dynamic content injected by the router
        body: child,
      ),
    );
  }
}