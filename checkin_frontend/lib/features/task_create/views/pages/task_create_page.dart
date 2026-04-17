import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/signalr_provider.dart';
import '../../../../core/providers/task_create/task_create_provider.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/shared_widgets/invalid_emails_dialog.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/utils/app_snack_bar.dart';
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
  bool _inviteExpanded = false;
  bool _subtasksExpanded = false;
  bool _isLoading = false;
  late SignalRService _signalRService;

  late final TextEditingController _titleCtrl;
  late final QuillController _quillCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _quillCtrl = QuillController.basic();
    _signalRService = ref.read(signalRProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSignalR();
    });

    _titleCtrl.addListener(() {
      ref.read(taskCreateProvider.notifier).updateTitle(_titleCtrl.text);
    });

    _quillCtrl.changes.listen((_) {
      final isEditorEmpty = _quillCtrl.document.isEmpty() ||
          _quillCtrl.document.toPlainText().trim().isEmpty;

      final notes = !isEditorEmpty
          ? QuillUtils.controllerToString(_quillCtrl)
          : null;
      ref.read(taskCreateProvider.notifier).updateDescription(notes);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signalR = ref.read(signalRProvider);
      final userId = ref.read(authProvider).user?.userId;

      if (userId != null) {
        signalR.joinUserRoom(userId); // Aby backend vedel, komu poslať "InvalidEmailsFound"
        signalR.connection?.on("InvalidEmailsFound", _handleInvalidEmails);
      }
    });
  }

  void _setupSignalR() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    print("DEBUG: SignalR - Pripájam sa do UserRoom pre: ${user.userId}");

    // 1. Vstúpime do User Room
    await _signalRService.joinUserRoom(user.userId);

    // 2. Začneme počúvať na event "InvalidEmailsFound"
    _signalRService.connection?.on("InvalidEmailsFound", _handleInvalidEmails);
  }


  void _handleInvalidEmails(List<Object?>? arguments) {
    // V SignalR prichádza zoznam emailov ako prvý argument (arguments[0])
    final rawList = arguments?[0] as List?;
    if (rawList == null) return;

    final invalidEmails = rawList.map((e) => e.toString()).toList();
    print("DEBUG: SignalR - PRIJATÉ neplatné maily: $invalidEmails");

    if (invalidEmails.isNotEmpty) {
      // KĽÚČOVÁ OPRAVA: Spustíme to v ďalšom mikro-tasku, aby layout stihol "vydýchnuť"
      Future.microtask(() {
        if (mounted) {
          InvalidEmailsDialog.show(context, invalidEmails);
        }
      });
    }
  }


  @override
  void dispose() {
    _titleCtrl.dispose();
    _quillCtrl.dispose();
    _signalRService.connection?.off("InvalidEmailsFound", method: _handleInvalidEmails);
    super.dispose();
  }

  // --- SUBMIT LOGIKA ---
  Future<void> _handleCreateTask() async {
    final taskData = ref.read(taskCreateProvider);

    if (taskData.title.isEmpty || taskData.deadLine == null) {
      AppSnackBar.showInfo(context, "Deadline and Title are required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final createdTask = await ref.read(taskApiServiceProvider).createTask(taskData);

      if (mounted) {
        ref.invalidate(taskListProvider);
        // Reset provideru po úspechu (ak máš metódu reset)
        context.go('/tasks/${createdTask.id}');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, "Error creating task: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Sledujeme len to, čo potrebujeme pre UI zmeny v tomto widgete
    // Týmto sme odstránili "final taskData = ref.watch(taskCreateProvider)" -> už to nebude skákať!
    final deadline = ref.watch(taskCreateProvider.select((s) => s.deadLine));
    final requiresAuth = ref.watch(taskCreateProvider.select((s) => s.requiresAuthenticationToComplete));
    final mode = ref.watch(taskCreateProvider.select((s) => s.subtaskMode));

    // Tieto premenné sledujeme, aby sme vedeli, či sú sekcie prázdne/využívané
    final hasEmails = ref.watch(taskCreateProvider.select((s) => s.invitedEmails.isNotEmpty));
    final hasSubtasks = ref.watch(taskCreateProvider.select((s) => s.subtasks.isNotEmpty));

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
                      TaskBasicInfo(
                        titleController: _titleCtrl,
                        quillController: _quillCtrl,
                      ),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                      // SECTION 2: OPTIONAL
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
                                icon: Icons.list_alt, // Opravená ikona podľa Figmy
                                label: "Add Subtasks",
                                onTap: () => setState(() => _subtasksExpanded = true),
                              ),
                          ],
                        ),

                      if (_inviteExpanded) ...[
                        const SizedBox(height: 12),
                        TaskInviteSection(
                          isExpanded: true,
                          onExpand: () {},
                          onCollapse: () => setState(() => _inviteExpanded = false),
                          onEmailsChanged: notifier.setEmails,
                        ),
                      ],

                      if (_inviteExpanded && _subtasksExpanded)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: Icon(Icons.more_horiz, size: 16, color: Colors.grey)),
                        ),

                      if (_subtasksExpanded) ...[
                        const SizedBox(height: 12),
                        SubtaskInputSection(
                          key: const ValueKey('subtask_section'),
                          onRemoveSection: () => setState(() => _subtasksExpanded = false),
                        ),
                      ],

                      if (_inviteExpanded || _subtasksExpanded)
                        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),


                      const SizedBox(height: 24),

                      // SECTION 3: SETTINGS
                      TaskSettingsSection(
                        selectedDeadline: deadline,
                        requiresAuth: requiresAuth,
                        currentMode: mode,
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
                          onDateQuickSelect: (date) {
                            notifier.setDeadline(date.toUtc());
                          },
                      ),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                      // SECTION 4: SUBMIT
                      PrimaryButton(
                        text: "Create Task",
                        isLoading: _isLoading,
                        onPressed: _handleCreateTask,
                      ),

                      const SizedBox(height: 24),
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
          height: 4, width: 60,
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 12),
        Text("Create New Task", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cs.onSurface)),
        Text("Build collaborative workflows with precision", style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
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