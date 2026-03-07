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

  final String? commonTooltip;
  final String? activeTooltip;
  final String? inactiveTooltip;

  const AppToggleButton({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.activeLabel,
    required this.activeIcon,
    this.activeColor = Colors.blue,
    required this.inactiveLabel,
    required this.inactiveIcon,
    this.inactiveColor = Colors.orange,
    this.commonTooltip,
    this.activeTooltip,
    this.inactiveTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = isActive ? activeColor : inactiveColor;
    final currentIcon = isActive ? activeIcon : inactiveIcon;
    final currentLabel = isActive ? activeLabel : inactiveLabel;


    final String? effectiveTooltip = isActive
        ? (activeTooltip ?? commonTooltip)
        : (inactiveTooltip ?? commonTooltip);

    if (effectiveTooltip == null) {
      return _buildButton(currentColor, currentIcon, currentLabel);
    }

    return Tooltip(
      message: effectiveTooltip,
      waitDuration: const Duration(milliseconds: 500),
      preferBelow: false,
      verticalOffset: 30,
      child: _buildButton(currentColor, currentIcon, currentLabel),
    );
  }

  Widget _buildButton(Color color, IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: color, width: 2),
        backgroundColor: color.withAlpha(23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}
