import 'package:flutter/material.dart';

/// A circular avatar that displays the capitalized initials of a given name.
class AvatarCircle extends StatelessWidget {
  final String name;
  const AvatarCircle({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    // Extract the first character of the first two words in the name
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.blueAccent,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// A compact, pill-shaped badge used for displaying statuses or labels with an icon.
class PillBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const PillBadge({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // Use a subtle transparent background based on the provided color
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}