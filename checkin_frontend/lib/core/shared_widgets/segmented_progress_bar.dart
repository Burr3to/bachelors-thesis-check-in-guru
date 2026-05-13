import 'package:flutter/material.dart';

/// A custom progress bar that displays completion status using color-coded segments.
/// It visualizes on-time completions (green), late completions/issues (red),
/// and pending tasks (gray).
class SegmentedProgressBar extends StatelessWidget {
  final int green;
  final int red;
  final int grey;
  final double height;

  const SegmentedProgressBar({
    super.key,
    required this.green,
    this.red = 0,
    required this.grey,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final int total = green + red + grey;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: cs.outlineVariant,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // ON TIME: Represented by green
          if (green > 0)
            Expanded(
              flex: green,
              child: Container(color: Colors.green.shade400),
            ),

          // LATE OR OVERDUE: Represented by red
          if (red > 0)
            Expanded(
              flex: red,
              child: Container(color: Colors.red.shade400),
            ),

          // INCOMPLETE OR NOT STARTED: Represented by gray
          if (grey > 0 || total == 0)
            Expanded(
              flex: (total == 0) ? 1 : grey,
              child: Container(color: cs.surfaceContainerHighest),
            ),
        ],
      ),
    );
  }
}