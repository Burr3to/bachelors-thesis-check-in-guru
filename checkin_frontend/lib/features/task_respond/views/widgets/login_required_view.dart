import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/views/providers/auth_provider.dart';

class LoginRequiredView extends ConsumerWidget {
  const LoginRequiredView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 80, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            "Task requires to be logged in",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text("Google login"),
            onPressed: () async {
              try {
                await ref.read(authProvider.notifier).signInWithGoogle();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Login failed: $e")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}