import 'dart:async'; // Potrebné pre Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/utils/l10n_extensions.dart';

class TaskActionButtons extends ConsumerStatefulWidget {
  final String taskId;
  final String taskLink;
  final VoidCallback onDeleteSuccess;

  const TaskActionButtons({
    super.key,
    required this.taskId,
    required this.taskLink,
    required this.onDeleteSuccess,
  });

  @override
  ConsumerState<TaskActionButtons> createState() => _TaskActionButtonsState();
}

class _TaskActionButtonsState extends ConsumerState<TaskActionButtons> {
  bool _isConfirming = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // Dôležité vyčistiť časovač pri zatvorení stránky
    super.dispose();
  }

  void _startConfirmation() {
    setState(() {
      _isConfirming = true;
    });

    // Po 2 sekundách vrátime tlačidlo do pôvodného stavu
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    });
  }

  Future<void> _handleDelete() async {
    // Ak ešte nie sme v móde potvrdenia, len ho aktivujeme
    if (!_isConfirming) {
      _startConfirmation();
      return;
    }

    // Ak už sme v móde potvrdenia a user klikol znova, mažeme
    _timer?.cancel();
    try {
      await ref.read(taskApiServiceProvider).deleteTask(widget.taskId);
      ref.invalidate(taskListProvider);
      widget.onDeleteSuccess();
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Dynamické farby podľa stavu
    final Color bgColor = _isConfirming ? Colors.red : colorScheme.surface;
    final Color fgColor = _isConfirming ? Colors.white : Colors.red;
    final String label = _isConfirming ? context.l10n.overview_btn_confirm : context.l10n.common_delete;
    final IconData icon = _isConfirming ? Icons.warning_amber_rounded : Icons.delete;

    return Row(
      children: [
        // DELETE BUTTON
        SizedBox(
          width: 120, // Fixná šírka, aby tlačidlo neskákalo pri zmene textu
          child: OutlinedButton.icon(
            onPressed: _handleDelete,
            label: Text(label, style: TextStyle(color: fgColor)),
            icon: Icon(icon, color: fgColor, size: 18),
            style: OutlinedButton.styleFrom(
              backgroundColor: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),

        const Spacer(),

        // COPY LINK BUTTON
        OutlinedButton.icon(
          icon: Icon(Icons.copy, color: colorScheme.primary),
          label: Text(context.l10n.overview_btn_copy_link, style: TextStyle(color: colorScheme.primary)),
          style: OutlinedButton.styleFrom(
            backgroundColor: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: colorScheme.primary, width: 1),
          ),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: widget.taskLink));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.overview_msg_copied),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}