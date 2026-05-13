import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../auth/views/providers/auth_provider.dart';
import '../../../../core/utils/responsive.dart';

/// A view that prompts the user to log in when authentication is required
/// to view or complete a task.
class LoginRequiredView extends ConsumerWidget {
  const LoginRequiredView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final bool isMobile = context.isMobile;

    return Center(
      child: Padding(
        // Responsive padding adjustment
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Locked icon representation
            Icon(Icons.lock_outline, size: isMobile ? 64 : 80, color: cs.primary),
            const SizedBox(height: 16),

            // Header text explaining the restriction
            Text(
              context.l10n.respond_auth_required_title,
              style: TextStyle(
                fontSize: isMobile ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle with more detail
            Text(
              context.l10n.respond_auth_required_subtitle,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Primary login action trigger
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              icon: const Icon(Icons.login),
              label: Text(context.l10n.auth_googlelogin),
              onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
            ),
          ],
        ),
      ),
    );
  }
}