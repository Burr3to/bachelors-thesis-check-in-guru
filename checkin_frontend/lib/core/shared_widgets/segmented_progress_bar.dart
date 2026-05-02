import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SegmentedProgressBar extends StatelessWidget {
  final int green;
  final int orange;
  final int grey;
  final double height;

  const SegmentedProgressBar({
    super.key,
    required this.green,
    this.orange = 0,
    required this.grey,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final int total = green + orange + grey;

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
          if (green > 0)
            Expanded(flex: green, child: Container(color: Colors.green.shade400)),
          if (orange > 0)
            Expanded(flex: orange, child: Container(color: Colors.orange.shade300)),
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