import 'package:flutter/material.dart';

import '../utils/l10n_extensions.dart';

/// A utility class to display a warning dialog when emails fail validation
/// (e.g., due to invalid formats or forbidden domains).
class InvalidEmailsDialog {
  /// Displays an alert dialog containing a scrollable list of the rejected emails.
  static void show(BuildContext context, List<String> invalidEmails) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

          // Dialog Header with warning icon and localized title
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cs.error, size: 28),
              const SizedBox(width: 12),
              Text(context.l10n.dialog_invalid_emails_title),
            ],
          ),

          // Main content area with width constraints for responsive layout
          content: SelectionArea(
            child: ConstrainedBox(
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

                  // Scrollable container for the list of invalid emails
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: cs.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                              Expanded(
                                child: Text(
                                  email,
                                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Footer with additional instructions or clarification
                  Text(
                    context.l10n.dialog_invalid_emails_footer,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          // Dialog actions
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