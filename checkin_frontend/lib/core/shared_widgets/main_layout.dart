import 'package:flutter/material.dart';
import 'app_top_bar.dart';

class MainLayout extends StatelessWidget{
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(left: 22, right: 22, top: 8, bottom: 8),
      child: Scaffold(
        appBar: const AppTopBar(),
        body: child,
      ),
    );
  }
}