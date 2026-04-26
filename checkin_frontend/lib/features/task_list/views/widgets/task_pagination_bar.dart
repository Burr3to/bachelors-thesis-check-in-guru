import 'dart:ui'; // Potrebné pre BackdropFilter (voliteľné)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/task_providers.dart';


class TaskPaginationBar extends ConsumerWidget {
  final int totalCount;
  const TaskPaginationBar({super.key, required this.totalCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // ZMENA TU: Sledujeme taskQueryProvider namiesto starého pagination providera
    final query = ref.watch(taskQueryProvider);

    // ZMENA TU: Používame query.pageNumber a query.pageSize
    final totalPages = (totalCount / query.pageSize).ceil();

    if (totalPages <= 1) return const SizedBox.shrink();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh.withAlpha(200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withAlpha(100)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageButton(
              icon: Icons.arrow_back_ios_new,
              // ZMENA TU: Voláme notifier na taskQueryProvider
              onPressed: query.pageNumber > 1
                  ? () => ref.read(taskQueryProvider.notifier).setPage(query.pageNumber - 1)
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Page", style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)),
                Text("${query.pageNumber} / $totalPages",
                    style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface, fontSize: 14)),
              ],
            ),
            const SizedBox(width: 16),
            _PageButton(
              icon: Icons.arrow_forward_ios,
              // ZMENA TU: Voláme notifier na taskQueryProvider
              onPressed: query.pageNumber < totalPages
                  ? () => ref.read(taskQueryProvider.notifier).setPage(query.pageNumber + 1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}


class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _PageButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        style: IconButton.styleFrom(
          // Viacej "square" s oblými hranami
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: cs.surfaceContainerHighest,
        ),
      ),
    );
  }
}