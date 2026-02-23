// lib/features/auth/views/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared_widgets/app_top_bar.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppTopBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Prosím, prihláste sa.'),
            const SizedBox(height: 20),
            // Tu bude tlačidlo Google Login
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).signInWithGoogle();
                },
              child: const Text('Prihlásiť sa cez Google'),
            ),
          ],
        ),
      ),
    );
  }
}