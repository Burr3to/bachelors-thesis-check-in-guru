import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/invitation_providers.dart';

enum InviteTiming { immediately, later }

class TaskInviteSection extends ConsumerStatefulWidget {
  final Function(List<String>) onEmailsChanged;
  final bool isExpanded;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;

  const TaskInviteSection({
    super.key,
    required this.onEmailsChanged,
    required this.isExpanded,
    required this.onExpand,
    required this.onCollapse,
  });

  @override
  ConsumerState<TaskInviteSection> createState() => _TaskInviteSectionState();
}

class _TaskInviteSectionState extends ConsumerState<TaskInviteSection> {
  final _emailInputController = TextEditingController();
  bool _isChecking = false;
  List<String> _detectedEmails = [];
  InviteTiming _selectedTiming = InviteTiming.immediately;

  @override
  void dispose() {
    _emailInputController.dispose();
    super.dispose();
  }

  Future<void> _handleParse() async {
    final rawText = _emailInputController.text.trim();
    if (rawText.isEmpty) return;

    setState(() => _isChecking = true);
    try {
      final api = ref.read(invitationApiServiceProvider);
      // BE expect quoted string
      final List<String> result = await api.parseEmails('"$rawText"');

      setState(() {
        // Merge unique emails
        _detectedEmails = {..._detectedEmails, ...result}.toList();
        _emailInputController.clear();
      });
      widget.onEmailsChanged(_detectedEmails);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to parse emails.")),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _detectedEmails.remove(email);
    });
    widget.onEmailsChanged(_detectedEmails);
  }

  void _removeAll() {
    setState(() {
      _detectedEmails.clear();
    });
    widget.onEmailsChanged(_detectedEmails);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // --- CASE 1: COLLAPSED VIEW (The side-by-side button style) ---
    if (!widget.isExpanded) {
      return Expanded(
        child: InkWell(
          onTap: widget.onExpand,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1_outlined, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Invite People",
                        style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface, fontSize: 13)),
                    Text("Optional",
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- CASE 2: EXPANDED VIEW ---
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
          // Header: Title + Remove Link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Invite Team Members",
                  style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
              TextButton(
                onPressed: widget.onCollapse,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: Text("Remove section",
                    style: TextStyle(color: cs.error, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Email Input + Parse Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailInputController,
                  decoration: InputDecoration(
                    hintText: "Enter or paste emails...",
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isChecking
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Parse"),
              ),
            ],
          ),

          // Email Chips Container
          if (_detectedEmails.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _detectedEmails.map((email) => InputChip(
                label: Text(email, style: const TextStyle(fontSize: 12)),
                onDeleted: () => _removeEmail(email),
                deleteIconColor: cs.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            TextButton(
              onPressed: _removeAll,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text("Remove All", style: TextStyle(fontSize: 12)),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Send Timing Selector
          Text("Send invites:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          SegmentedButton<InviteTiming>(
            segments: const [
              ButtonSegment(value: InviteTiming.immediately, label: Text("Immediately"), icon: Icon(Icons.bolt, size: 16)),
              ButtonSegment(value: InviteTiming.later, label: Text("Later"), icon: Icon(Icons.timer_outlined, size: 16)),
            ],
            selected: {_selectedTiming},
            onSelectionChanged: (val) => setState(() => _selectedTiming = val.first),
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              selectedBackgroundColor: cs.primaryContainer,
              selectedForegroundColor: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}