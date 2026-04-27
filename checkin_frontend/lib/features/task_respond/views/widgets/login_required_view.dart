import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../auth/views/providers/auth_provider.dart';

class LoginRequiredView extends ConsumerWidget {
  const LoginRequiredView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            context.l10n.respond_auth_required_title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.respond_auth_required_subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            icon: const Icon(Icons.login),
            label: Text(context.l10n.auth_googlelogin),
            onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
          ),
        ],
      ),
    );
  }
}
