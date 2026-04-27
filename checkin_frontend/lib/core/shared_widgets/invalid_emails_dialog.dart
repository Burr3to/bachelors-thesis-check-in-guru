import 'package:flutter/material.dart';

import '../utils/l10n_extensions.dart';

class InvalidEmailsDialog {
  static void show(BuildContext context, List<String> invalidEmails) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cs.error, size: 28),
              const SizedBox(width: 12),
              Text(context.l10n.dialog_invalid_emails_title),
            ],
          ),
          content: SelectionArea(
            child: ConstrainedBox( // PRIDANÉ: Explicitné obmedzenie šírky pre Web
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dialog_invalid_emails_msg,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: cs.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // ZMENA: SingleChildScrollView namiesto ListView
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: invalidEmails.map((email) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("• ", style: TextStyle(color: cs.error, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(email, style: const TextStyle(fontSize: 13, fontFamily: 'monospace'))),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.dialog_invalid_emails_footer, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.dialog_invalid_emails_btn),
            ),
          ],
        );
      },
    );
  }
}