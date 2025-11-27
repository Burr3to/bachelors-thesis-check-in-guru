import 'package:flutter/material.dart';
import 'app_top_bar.dart';

class MainLayout extends StatelessWidget{
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: const AppTopBar(),
      body: child,
    );
  }
}