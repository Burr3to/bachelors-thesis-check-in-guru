import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/invitation_providers.dart';

class TaskInviteSection extends ConsumerStatefulWidget {
  final Function(List<String>) onEmailsChanged;

  const TaskInviteSection({super.key, required this.onEmailsChanged});

  @override
  ConsumerState<TaskInviteSection> createState() => _TaskInviteSectionState();
}

class _TaskInviteSectionState extends ConsumerState<TaskInviteSection> {
  bool _isExpanded = false;
  bool _isChecking = false;
  final _emailInputController = TextEditingController();
  List<String> _detectedEmails = [];

  @override
  void dispose() {
    _emailInputController.dispose();
    super.dispose();
  }

  Future<void> _handleCheck() async {
    final rawText = _emailInputController.text.trim();
    if (rawText.isEmpty) return;

    setState(() => _isChecking = true);

    try {
      final api = ref.read(invitationApiServiceProvider);
      // Obalíme text do úvodzoviek, aby to BE spracoval ako platný JSON string
      final List<String> result = await api.parseEmails('"$rawText"');

      setState(() {
        _detectedEmails = result;
      });
      widget.onEmailsChanged(_detectedEmails);
    } on DioException catch (e) {
      String errorMsg = "Could not parse emails. Please check the format.";
      if (e.response?.statusCode == 400) {
        errorMsg = "Invalid input format. Try simpler text.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_isExpanded) {
      return OutlinedButton.icon(
        onPressed: () => setState(() => _isExpanded = true),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text("Invite people to this task"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(color: colorScheme.outlineVariant, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant, width: 2),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("EMAIL INVITATIONS",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)
                ),
                IconButton(
                  onPressed: () => setState(() => _isExpanded = false),
                  icon: const Icon(Icons.close, size: 18),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Dôležité: Zarovnaj na vrch
              children: [
                // LEFT SIDE: INPUT
                Expanded(
                  child: Container(
                    // Fixujeme výšku kontajnera, aby ladil s 5 riadkami textu
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Stack(
                      children: [
                        TextField(
                          controller: _emailInputController,
                          maxLines: 5,
                          minLines: 5,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: "Paste emails here...",
                            hintStyle: TextStyle(fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 45),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: IconButton.filled(
                            onPressed: _isChecking ? null : _handleCheck,
                            icon: _isChecking
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.person_search, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // RIGHT SIDE: DETECTED
                Expanded(
                  child: Container(
                    height: 155, // Fixná výška, aby lícovala s ľavou stranou (5 lines + padding)
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Detected Emails:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _detectedEmails.isEmpty
                                ? const Text("No emails found yet.", style: TextStyle(fontSize: 11, color: Colors.grey))
                                : Wrap(
                              spacing: 6,
                              runSpacing: 0,
                              children: _detectedEmails.map((email) {
                                return Chip(
                                  label: Text(email, style: const TextStyle(fontSize: 12)),
                                  onDeleted: () {
                                    setState(() {
                                      _detectedEmails.remove(email);
                                      widget.onEmailsChanged(_detectedEmails);
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}