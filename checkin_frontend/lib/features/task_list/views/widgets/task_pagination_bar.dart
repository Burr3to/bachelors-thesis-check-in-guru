import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/utils/l10n_extensions.dart';

/// A floating pagination control bar for navigating through task list pages.
/// It observes the current query state and calculates total pages based on total task count.
class TaskPaginationBar extends ConsumerWidget {
  final int totalCount;
  const TaskPaginationBar({super.key, required this.totalCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // Watch taskQueryProvider to synchronize pagination with active filters
    final query = ref.watch(taskQueryProvider);

    // Calculate the total number of pages based on total count and current page size
    final totalPages = (totalCount / query.pageSize).ceil();

    // Do not render the bar if all items fit on a single page
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
            // Navigation to the previous page
            _PageButton(
              icon: Icons.arrow_back_ios_new,
              onPressed: query.pageNumber > 1
                  ? () => ref.read(taskQueryProvider.notifier).setPage(query.pageNumber - 1)
                  : null,
            ),
            const SizedBox(width: 16),

            // Current page status indicator
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    context.l10n.tasks_pagination_page,
                    style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)
                ),
                Text(
                    "${query.pageNumber} / $totalPages",
                    style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface, fontSize: 14)
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Navigation to the next page
            _PageButton(
              icon: Icons.arrow_forward_ios,
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

/// A private helper widget for rendering styled pagination arrow buttons.
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: cs.surfaceContainerHighest,
        ),
      ),
    );
  }
}