// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/config/router.dart';
import 'package:checkin_frontend/widgets/auth_listener_initializer.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AuthListenerInitializer(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CheckIn Guru',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}