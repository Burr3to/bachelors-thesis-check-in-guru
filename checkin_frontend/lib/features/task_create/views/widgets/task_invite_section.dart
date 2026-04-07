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
      final colorScheme = Theme.of(context).colorScheme;
      String errorMsg = "Could not parse emails. Please check the format.";
      if (e.response?.statusCode == 400) {
        errorMsg = "Invalid input format. Try simpler text.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: TextStyle(color: colorScheme.onError)),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (!_isExpanded) {
      return OutlinedButton.icon(
        onPressed: () => setState(() => _isExpanded = true),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text("Invite people to this task"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(color: colorScheme.outlineVariant, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: colorScheme.primary, // Modrá farba textu/ikony
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
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant
                    )
                ),
                IconButton(
                  onPressed: () => setState(() => _isExpanded = false),
                  icon: Icon(Icons.close, size: 18, color: colorScheme.onSurfaceVariant),
                )
              ],
            ),
          ),

          Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT SIDE: INPUT
                  Expanded(
                    child: Container(
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
                            style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: "Paste emails here...",
                              hintStyle: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 45),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: IconButton.filled(
                              onPressed: _isChecking ? null : _handleCheck,
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                              icon: _isChecking
                                  ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: colorScheme.onPrimary,
                                      strokeWidth: 2
                                  )
                              )
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
                      height: 155,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // V dark mode chceme o niečo výraznejšie pozadie pre kontrast
                        color: isDark
                            ? colorScheme.surfaceContainerHigh
                            : colorScheme.surface.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Detected Emails:",
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface
                              )
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _detectedEmails.isEmpty
                                  ? Text(
                                  "No emails found yet.",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant.withOpacity(0.7)
                                  )
                              )
                                  : Wrap(
                                spacing: 6,
                                runSpacing: 0,
                                children: _detectedEmails.map((email) {
                                  return Chip(
                                    label: Text(
                                        email,
                                        style: const TextStyle(fontSize: 11)
                                    ),
                                    backgroundColor: isDark ? colorScheme.surface : null,
                                    onDeleted: () {
                                      setState(() {
                                        _detectedEmails.remove(email);
                                        widget.onEmailsChanged(_detectedEmails);
                                      });
                                    },
                                    deleteIconColor: colorScheme.error,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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