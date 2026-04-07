import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/user/user_profile.dart';

class RespondentSignatureField extends StatelessWidget {
  final UserProfile? auth;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const RespondentSignatureField({
    super.key,
    required this.auth,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (auth == null) {
      return TextField(
        controller: controller,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          labelText: "Your name / signature",
          labelStyle: TextStyle(color: cs.onSurfaceVariant),
          filled: true,
          fillColor: cs.surfaceContainer,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.person_outline, color: cs.primary),
        ),
        onChanged: (_) => onChanged(),
      );
    }

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
          "Signed as: ${auth!.name}",
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        subtitle: Text(auth!.email, style: TextStyle(color: cs.onSurfaceVariant)),
      ),
    );
  }
}
