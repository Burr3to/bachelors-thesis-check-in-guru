import 'package:flutter/material.dart';

class AppSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        required IconData icon,
        required Color backgroundColor,
        Duration duration = const Duration(seconds: 2),
      }) {
    // Ak by sme sa pokúsili zobraziť snackbar po tom, čo sme odišli z obrazovky
    if (!context.mounted) return;

    // Najprv skryjeme predchádzajúci snackbar, ak nejaký svieti
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        width: 400,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green[700]!,
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red[700]!,
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue[700]!,
    );
  }
}