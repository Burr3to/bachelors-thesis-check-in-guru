import 'package:flutter/material.dart';

/// Utility class for displaying customized SnackBars with a progress timer bar.
class AppSnackBar {

  /// The core method to display a styled SnackBar.
  /// Includes an animated progress bar at the bottom matching the duration.
  static void show(
      BuildContext context, {
        required String message,
        required IconData icon,
        required Color backgroundColor,
        Duration duration = const Duration(seconds: 2),
      }) {
    if (!context.mounted) return;

    // Remove any currently visible snackbars to prevent overlapping
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Handle responsive width for desktop/web vs mobile
    double screenWidth = MediaQuery.of(context).size.width;
    double? customWidth = screenWidth > 600 ? 400 : screenWidth * 0.9;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        width: customWidth,
        padding: EdgeInsets.zero, // Zero padding allows the timer to sit flush at the bottom
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main content area containing the Icon and Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Animated Progress Indicator (Timer Bar)
            TweenAnimationBuilder<double>(
              duration: duration,
              tween: Tween<double>(begin: 1.0, end: 0.0),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor: Colors.white.withAlpha(70),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a green success SnackBar.
  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
    show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green[700]!,
      duration: duration,
    );
  }

  /// Displays a red error SnackBar.
  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red[700]!,
      duration: duration,
    );
  }

  /// Displays a blue information SnackBar.
  static void showInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
    show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue[700]!,
      duration: duration,
    );
  }
}