import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SegmentedProgressBar extends StatelessWidget {
  final int green;
  final int red; // Zmenené z orange na red
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
        children:[
          // VČAS: Zelená
          if (green > 0)
            Expanded(flex: green, child: Container(color: Colors.green.shade400)),
          // PO TERMÍNE (LATE): Červená
          if (red > 0)
            Expanded(flex: red, child: Container(color: Colors.red.shade400)),
          // NEDOKONČENÉ: Sivá
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