import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user/user_profile.dart';
import '../../../../core/utils/l10n_extensions.dart';

/// A widget that provides a signature input field for respondents.
/// If the user is unauthenticated, it shows a text field for manual name entry.
/// If authenticated, it displays a verified profile card with a logout option.
class RespondentSignatureField extends ConsumerWidget {
  final UserProfile? auth;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const RespondentSignatureField({
    super.key,
    required this.auth,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // CASE 1: Anonymous respondent - show a text input field
    if (auth == null) {
      return TextField(
        controller: controller,
        style: TextStyle(color: cs.onSurface),
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          labelText: context.l10n.respond_sig_label,
          labelStyle: TextStyle(color: cs.onSurfaceVariant),
          filled: true,
          fillColor: cs.surfaceContainer,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.person_outline, color: cs.primary),
        ),
        onChanged: (_) => onChanged(),
      );
    }

    // CASE 2: Authenticated user - show a verified identity card
    return Card(
      color: cs.primary.withAlpha(25),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.primary.withAlpha(75)),
      ),
      child: ListTile(
        leading: Icon(Icons.verified, color: cs.primary),
        title: Text(
          context.l10n.respond_sig_signed_as(auth!.name),
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        subtitle: Text(auth!.email, style: TextStyle(color: cs.onSurfaceVariant)),
        trailing: IconButton(
          icon: Icon(Icons.logout_rounded, color: cs.onSurfaceVariant, size: 20),
          onPressed: () => ref.read(authProvider.notifier).signOut(),
          tooltip: 'Logout',
        ),
      ),
    );
  }
}