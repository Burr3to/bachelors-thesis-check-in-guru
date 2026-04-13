import 'package:flutter/material.dart';

class AppToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final String activeLabel;
  final IconData activeIcon;
  final Color? activeColor;
  final String inactiveLabel;
  final IconData inactiveIcon;
  final Color? inactiveColor;
  final String? activeTooltip;
  final String? inactiveTooltip;

  const AppToggleButton({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.activeLabel,
    required this.activeIcon,
    this.activeColor,
    required this.inactiveLabel,
    required this.inactiveIcon,
    this.inactiveColor,
    this.activeTooltip,
    this.inactiveTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color color = isActive
        ? (activeColor ?? theme.colorScheme.primary)
        : (inactiveColor ?? theme.colorScheme.onSurfaceVariant);

    final currentIcon = isActive ? activeIcon : inactiveIcon;
    final currentLabel = isActive ? activeLabel : inactiveLabel;
    final tooltip = isActive ? activeTooltip : inactiveTooltip;

    final backgroundColor = color.withAlpha(isDark ? 38 : 20);

    Widget button = OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(currentIcon, color: color),
      label: Text(
        currentLabel,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        side: BorderSide(
          color: isActive ? color : theme.colorScheme.outlineVariant,
          width: 2,
        ),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: color,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: button,
      );
    }

    return button;
  }
}