import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/invitation_providers.dart';
import '../../../../core/providers/task_create/task_create_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';

enum InviteTiming { immediately, later }

class TaskInviteSection extends ConsumerStatefulWidget {
  final Function(List<String>) onEmailsChanged;
  final bool isExpanded;
  final VoidCallback onCollapse;

  const TaskInviteSection({
    super.key,
    required this.onEmailsChanged,
    required this.isExpanded,
    required this.onCollapse,
  });

  @override
  ConsumerState<TaskInviteSection> createState() => _TaskInviteSectionState();
}

class _TaskInviteSectionState extends ConsumerState<TaskInviteSection> {
  final _emailInputController = TextEditingController();
  bool _isChecking = false;
  List<String> _detectedEmails = [];
  InviteTiming _selectedTiming = InviteTiming.later;

  Future<void> _handleParse() async {
    final rawText = _emailInputController.text.trim();
    if (rawText.isEmpty) return;

    setState(() => _isChecking = true);
    try {
      final api = ref.read(invitationApiServiceProvider);
      final List<String> result = await api.parseEmails('"$rawText"');

      setState(() {
        _detectedEmails = {..._detectedEmails, ...result}.toList();
        _emailInputController.clear();
      });
      widget.onEmailsChanged(_detectedEmails);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to parse emails.")));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _removeEmail(String email) {
    setState(() => _detectedEmails.remove(email));
    widget.onEmailsChanged(_detectedEmails);
  }

  void _removeAll() {
    setState(() => _detectedEmails.clear());
    widget.onEmailsChanged(_detectedEmails);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.task_create_invite_title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
              IconButton(
                onPressed: widget.onCollapse,
                icon: const Icon(Icons.close, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),

        IntrinsicHeight( // Zabezpečí, že deti v Row budú môcť mať rovnakú výšku
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _emailInputController,
                  maxLines: 1, // Dôležité pre funkciu Enter-u
                  onSubmitted: (_) => _isChecking ? null : _handleParse(),
                  decoration: InputDecoration(
                    hintText: "Emails in any format test@gmail.com; test2@vutbr.com - test3...",
                    hintStyle: TextStyle(fontSize: 12, color: cs.onSurfaceVariant.withAlpha(150)),
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isChecking ? null : _handleParse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: _isChecking
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("ADD", style: TextStyle(fontWeight: FontWeight.normal)),
              ),
            ],
          ),
        ),

          if (_detectedEmails.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _removeAll,
              icon: Icon(Icons.delete_sweep_outlined, size: 16, color: cs.error),
              label: Text("Remove all", style: TextStyle(color: cs.error, fontSize: 12)),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _detectedEmails.map((email) => InputChip(
                label: Text(email, style: const TextStyle(fontSize: 12)),
                onDeleted: () => _removeEmail(email),
                deleteIcon: const Icon(Icons.remove_circle_outline, size: 16),
                deleteIconColor: cs.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          ],

          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),

          Text(
            "When should the invites be sent?",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTimingOption(
                timing: InviteTiming.immediately,
                label: "Immediately when created",
                icon: Icons.bolt,
                cs: cs,
              ),
              const SizedBox(width: 12),
              _buildTimingOption(
                timing: InviteTiming.later,
                label: "Later manually in detail",
                icon: Icons.timer_outlined,
                cs: cs,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildTimingOption({
    required InviteTiming timing,
    required String label,
    required IconData icon,
    required ColorScheme cs,
  }) {
    final isSelected = _selectedTiming == timing;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedTiming = timing);
          // PREPOJENIE S PROVIDEROM:
          ref.read(taskCreateProvider.notifier).setSendImmediately(timing == InviteTiming.immediately);
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            //isSelected ? cs.primary.withAlpha(40) : Colors.transparent,
            color: isSelected ? cs.primary.withAlpha(35) : cs.surfaceContainerHigh.withAlpha(100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}