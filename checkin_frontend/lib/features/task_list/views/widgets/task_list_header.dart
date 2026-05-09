import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/task/query/task_list_query.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/utils/l10n_extensions.dart';

// --- TENTO IMPORT PRIDAJ ---
import '../../../../core/utils/responsive.dart';

class TaskListHeader extends ConsumerStatefulWidget {
  const TaskListHeader({super.key});

  @override
  ConsumerState<TaskListHeader> createState() => _TaskListHeaderState();
}

class _TaskListHeaderState extends ConsumerState<TaskListHeader> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(taskQueryProvider.notifier).updateSearch(query.isEmpty ? null : query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final query = ref.watch(taskQueryProvider);
    final filterCount = query.activeFilterCount;
    final hasFilters = filterCount > 0;
    final isMobile = context.isMobile;

    // Na mobile mierne znížime výšku search baru pre elegantnejší vzhľad
    final double commonHeight = isMobile ? 50.0 : 60.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          // 1. SEARCH BAR
          Expanded(
            child: SizedBox(
              height: commonHeight,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.center,
                // Na mobile menší font (16 miesto 18)
                style: TextStyle(color: cs.onSurface, fontSize: isMobile ? 16 : 18),
                decoration: InputDecoration(
                  hintText: context.l10n.tasks_header_search_hint,
                  // ZMENA: Ak sme na mobile, zmenšíme hint, aby sa nestal pretečeným
                  hintStyle: TextStyle(
                      fontSize: isMobile ? 14 : null,
                      color: cs.onSurfaceVariant.withOpacity(0.7)
                  ),
                  suffixIcon: Icon(Icons.search, color: cs.primary),
                  filled: true,
                  fillColor: cs.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 2. FILTER BUTTON s Badge
          SizedBox(
            width: commonHeight,
            height: commonHeight,
            child: Badge(
              isLabelVisible: hasFilters,
              label: Text('$filterCount'),
              backgroundColor: cs.primary,
              textColor: cs.onPrimary,
              offset: const Offset(2, -2),
              child: IconButton.outlined(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: Icon(hasFilters ? Icons.filter_alt : Icons.filter_list),
                style: IconButton.styleFrom(
                  minimumSize: Size(commonHeight, commonHeight),
                  fixedSize: Size(commonHeight, commonHeight),
                  backgroundColor: hasFilters ? cs.primaryContainer : cs.surface,
                  foregroundColor: hasFilters ? cs.onPrimaryContainer : cs.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(
                    color: hasFilters ? cs.primary : cs.outlineVariant,
                    width: hasFilters ? 2 : 1,
                  ),
                ),
              ),
            ),
          ),

          // 3. CREATE TASK BUTTON (Zobrazí sa LEN na desktope)
          if (!isMobile) ...[
            const SizedBox(width: 12),
            PrimaryButton(
              text: context.l10n.task_create_btn_create,
              icon: Icons.add,
              height: commonHeight,
              onPressed: () => context.go('/tasks/create'),
            ),
          ],
        ],
      ),
    );
  }
}