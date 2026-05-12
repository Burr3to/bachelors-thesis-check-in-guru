import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../auth/views/providers/auth_provider.dart';
// Tvoj nový import pre responzivitu
import '../../../../core/utils/responsive.dart';

class LoginRequiredView extends ConsumerWidget {
  const LoginRequiredView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.isMobile ? 16 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Icon(Icons.lock_outline, size: context.isMobile ? 64 : 80, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              context.l10n.respond_auth_required_title,
              style: TextStyle(
                fontSize: context.isMobile ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.respond_auth_required_subtitle,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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