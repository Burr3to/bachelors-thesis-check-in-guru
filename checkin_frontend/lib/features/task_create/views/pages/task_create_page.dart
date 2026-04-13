import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/task_create/task_create_provider.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/utils/quill_utils.dart';
import '../widgets/subtask_input_section.dart';
import '../widgets/task_basic_info.dart';
import '../widgets/task_invite_section.dart';
import '../widgets/task_settings_section.dart';

class TaskCreatePage extends ConsumerStatefulWidget {
  const TaskCreatePage({super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  // UI State: Controls visibility of optional sections
  bool _inviteExpanded = false;
  bool _subtasksExpanded = false;
  bool _isLoading = false;

  // Controllers: Controllers stay in the State for lifecycle management
  late final TextEditingController _titleCtrl;
  late final QuillController _quillCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _quillCtrl = QuillController.basic();

    // Sync Title Controller with Provider
    _titleCtrl.addListener(() {
      ref.read(taskCreateProvider.notifier).updateTitle(_titleCtrl.text);
    });

    // Sync Quill with Provider (Notes)
    _quillCtrl.changes.listen((_) {
      final isEditorEmpty = _quillCtrl.document.isEmpty() ||
          _quillCtrl.document.toPlainText().trim().isEmpty;

      final notes = !isEditorEmpty
          ? QuillUtils.controllerToString(_quillCtrl)
          : null;
      ref.read(taskCreateProvider.notifier).updateDescription(notes);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _quillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Watch data from provider
    final taskData = ref.watch(taskCreateProvider);
    final notifier = ref.read(taskCreateProvider.notifier);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(cs),
                const SizedBox(height: 24),

                // MAIN FORM CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // SECTION 1: REQUIRED
                      TaskBasicInfo(
                        titleController: _titleCtrl,
                        quillController: _quillCtrl,
                      ),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                      // SECTION 2: OPTIONAL COLLAPSIBLE SECTIONS
                      if (!_inviteExpanded || !_subtasksExpanded)
                        Row(
                          children: [
                            if (!_inviteExpanded)
                              _CollapsedButton(
                                icon: Icons.person_add_alt_1,
                                label: "Invite People",
                                onTap: () => setState(() => _inviteExpanded = true),
                              ),
                            if (!_inviteExpanded && !_subtasksExpanded) const SizedBox(width: 12),
                            if (!_subtasksExpanded)
                              _CollapsedButton(
                                icon: Icons.calendar_today_outlined,
                                label: "Add Subtasks",
                                onTap: () => setState(() => _subtasksExpanded = true),
                              ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      if (_inviteExpanded)
                        TaskInviteSection(
                          isExpanded: true,
                          onExpand: () {}, // Already expanded
                          onCollapse: () => setState(() => _inviteExpanded = false),
                          onEmailsChanged: notifier.setEmails,
                        ),

                      // Sub-divider if both are visible
                      if (_inviteExpanded && _subtasksExpanded)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: Icon(Icons.more_horiz, size: 16, color: Colors.grey)),
                        ),

                      if (_subtasksExpanded)
                        SubtaskInputSection(
                          onRemoveSection: () {
                            setState(() => _subtasksExpanded = false);
                          },
                        ),

                      // Divider appears only if at least one optional section is expanded
                      if (_inviteExpanded || _subtasksExpanded)
                        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                      // SECTION 3: SETTINGS
                      TaskSettingsSection(
                        selectedDeadline: taskData.deadLine,
                        requiresAuth: taskData.requiresAuthenticationToComplete,
                        currentMode: taskData.subtaskMode,
                        onDateTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) notifier.setDeadline(picked);
                        },
                        onAuthChanged: notifier.toggleAuth,
                        onModeChanged: notifier.setSubtaskMode,
                      ),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                      // SECTION 4: SUBMIT
                      PrimaryButton(
                        text: "Create Task",
                        isLoading: _isLoading,
                        onPressed: () {
                          // TODO: Implement Submit using taskData
                        },
                      ),

                      const SizedBox(height: 24),
                      _buildKeyboardHint(cs),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2)
            )
        ),
        const SizedBox(height: 12),
        Text("Create New Task",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cs.onSurface)),
        Text("Build collaborative workflows with precision",
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildKeyboardHint(ColorScheme cs) {
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("Press ⌘ + Enter to create",
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, letterSpacing: 0.5)),
        ),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}

class _CollapsedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CollapsedButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface)),
                  Text("Optional", style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}