import 'package:flutter/material.dart';


class AppToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  // Parametre pre "Active" stav
  final String activeLabel;
  final IconData activeIcon;
  final Color activeColor;

  // Parametre pre "Inactive" stav
  final String inactiveLabel;
  final IconData inactiveIcon;
  final Color inactiveColor;

  const AppToggleButton({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.activeLabel,
    required this.activeIcon,
    this.activeColor = Colors.blue, // Default modrá
    required this.inactiveLabel,
    required this.inactiveIcon,
    this.inactiveColor = Colors.orange, // Default oranžová
  });

  @override
  Widget build(BuildContext context) {
    // Vyberieme správne hodnoty podľa stavu
    final currentColor = isActive ? activeColor : inactiveColor;
    final currentIcon = isActive ? activeIcon : inactiveIcon;
    final currentLabel = isActive ? activeLabel : inactiveLabel;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(currentIcon, color: currentColor),
      label: Text(
        currentLabel,
        style: TextStyle(color: currentColor, fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: currentColor, width: 2),
        // Jemný nádych farby na pozadí
        backgroundColor: currentColor.withAlpha(23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}