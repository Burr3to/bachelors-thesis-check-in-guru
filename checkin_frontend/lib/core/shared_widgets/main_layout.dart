import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'app_top_bar.dart';

class MainLayout extends StatelessWidget{
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      child: Scaffold(
        appBar: const AppTopBar(),
        drawer: const AppDrawer(),
        body: child,
      ),
    );
  }
}