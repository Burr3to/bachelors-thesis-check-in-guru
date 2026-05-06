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
import '../../../../core/shared_widgets/app_snack_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
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
      final isEditorEmpty =
          _quillCtrl.document.isEmpty() || _quillCtrl.document.toPlainText().trim().isEmpty;

      final notes = !isEditorEmpty ? QuillUtils.controllerToString(_quillCtrl) : null;
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

  DateTime _normalizeToEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
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
      AppSnackBar.showInfo(context, context.l10n.task_create_err_required);
      return;
    }

    if (taskData.requiresAuthenticationToComplete &&
        taskData.allowedDomain != null &&
        taskData.isDomainValid == false) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Domain Warning"),
          content: Text(
            "We couldn't verify that '${taskData.allowedDomain}' is a valid mail domain."
            " If it's incorrect, invited respondents won't be able to access the task. Do you want to proceed anyway?",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("PROCEED", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (proceed != true) return; // Ak klikol cancel, nepokračujeme
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Definujeme fixné šírky pre rôzne zariadenia
    double contentWidth;
    if (screenWidth < 600) {
      contentWidth = screenWidth; // Mobil: na celú šírku
    } else if (screenWidth < 1200) {
      contentWidth = 700; // Tablet/Menší notebook: fixných 700px
    } else {
      contentWidth = 800; // Veľký desktop: fixných 800px
    }

    final deadline = ref.watch(taskCreateProvider.select((s) => s.deadLine));
    final requiresAuth = ref.watch(
      taskCreateProvider.select((s) => s.requiresAuthenticationToComplete),
    );
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
            constraints: BoxConstraints(maxWidth: contentWidth),
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
                    border: Border.all(color: cs.outlineVariant.withAlpha(125)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TaskBasicInfo(titleController: _titleCtrl, quillController: _quillCtrl),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                      // SECTION 2: OPTIONAL SECTIONS (VERTICAL STACK)
                      Column(
                        children: [
                          // INVITE SECTION
                          if (!_inviteExpanded)
                            _CollapsedButton(
                              icon: Icons.person_add_alt_1,
                              label: context.l10n.task_create_btn_invite,
                              onTap: () => setState(() => _inviteExpanded = true),
                            )
                          else
                            TaskInviteSection(
                              isExpanded: true,
                              onEmailsChanged: notifier.setEmails,
                              onCollapse: () => setState(() => _inviteExpanded = false),
                            ),

                          const SizedBox(height: 12),

                          // SUBTASK SECTION
                          if (!_subtasksExpanded)
                            _CollapsedButton(
                              icon: Icons.list_alt,
                              label: context.l10n.task_create_btn_subtasks,
                              onTap: () => setState(() => _subtasksExpanded = true),
                            )
                          else
                            SubtaskInputSection(
                              key: const ValueKey('subtask_section'),
                              onRemoveSection: () => setState(() => _subtasksExpanded = false),
                            ),
                        ],
                      ),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),

                      // SECTION 3: SETTINGS
                      TaskSettingsSection(
                        selectedDeadline: deadline,
                        requiresAuth: requiresAuth,
                        currentMode: mode,
                        onDomainChanged: (domain) {
                          ref.read(taskCreateProvider.notifier).updateAllowedDomain(domain);
                        },
                        onDateTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            final endOfDay = _normalizeToEndOfDay(picked);
                            notifier.setDeadline(endOfDay.toUtc());
                          }
                        },
                        onAuthChanged: notifier.toggleAuth,
                        onModeChanged: notifier.setSubtaskMode,
                        onDateQuickSelect: (date) {
                          final endOfDay = _normalizeToEndOfDay(date);
                          notifier.setDeadline(endOfDay.toUtc());
                        },
                      ),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),

                      // SECTION 4: SUBMIT
                      PrimaryButton(
                        text: context.l10n.task_create_btn_create,
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
          height: 4,
          width: 60,
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.task_create_header_title,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        Text(
          context.l10n.task_create_header_subtitle,
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    context.l10n.task_create_optional,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.add, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
