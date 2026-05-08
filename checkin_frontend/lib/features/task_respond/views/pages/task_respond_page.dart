import 'package:checkin_frontend/core/shared_widgets/app_top_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/providers/respond_providers.dart';
import 'package:go_router/go_router.dart';
// Importy pre SignalR
import '../../../../core/services/signalr_service.dart';
import '../../../../core/providers/signalr_provider.dart';

import '../../../../core/models/subtask_instance/bulk_subtask_complete_model.dart';
import '../../../../core/models/user/user_profile.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/shared_widgets/app_snack_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../auth/views/providers/auth_provider.dart';
import '../../../../core/models/subtask_instance/subtask_combined_list_model.dart';
import '../widgets/login_required_view.dart';
import '../widgets/respondent_signature_field.dart';
import '../widgets/subtask_list_card.dart';
import '../widgets/task_header.dart';

class TaskRespondPage extends ConsumerStatefulWidget {
  final String taskHash;
  const TaskRespondPage({super.key, required this.taskHash});

  @override
  ConsumerState<TaskRespondPage> createState() => _TaskRespondPageState();
}

class _TaskRespondPageState extends ConsumerState<TaskRespondPage> {
  final _nameCtrl = TextEditingController();
  final Set<String> _selectedIds = {};
  bool _isLoading = false;
  bool _isSubmittedSuccess = false;

  late SignalRService _signalRService;
  String? _joinedTaskIdRoom;

  @override
  void initState() {
    super.initState();
    _signalRService = ref.read(signalRProvider);

    // Spustíme nastavenie SignalR hneď po prvom vykreslení
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSignalR();
    });
  }

  Future<void> _setupSignalR() async {
    try {
      print("SignalR (Respond): Začínam setup pre hash ${widget.taskHash}");

      final publicTask = await ref.read(publicTaskProvider(widget.taskHash).future);

      if (publicTask.id == null || publicTask.id.isEmpty) {
        print("SignalR ERROR: publicTask.id je prázdne! Backend ho asi neposiela.");
        return;
      }

      final roomName = publicTask.id.toLowerCase().trim();
      print("SignalR (Respond): Pokúšam sa pripojiť do miestnosti: $roomName");

      // Tu sa uisti, že SignalR je "Connected", ak máš na to metódu
      // napr. await _signalRService.ensureConnection();

      _joinedTaskIdRoom = roomName;
      await _signalRService.joinTaskRoom(roomName);

      _signalRService.connection?.on("TaskInstancesChanged", _handleDataChanged);
      _signalRService.connection?.on("TaskUpdated", _handleDataChanged);

      print("SignalR (Respond): Úspešne pripojené do miestnosti: $roomName");
    } catch (e, stacktrace) {
      print("SignalR (Respond) CRITICAL ERROR: $e");
      print(stacktrace);
    }
  }

  void _handleDataChanged(List<Object?>? arguments) {
    if (!mounted) return;
    print("SignalR: Prijatý signál o zmene pre TaskHash: ${widget.taskHash}");

    // Obnovíme dáta zo servera (to automaticky prekreslí UI)
    ref.invalidate(publicTaskProvider(widget.taskHash));

    setState(() {
      // Ak mal používateľ niečo zakliknuté, radšej to zrušíme a ukážeme notifikáciu
      if (_selectedIds.isNotEmpty) {
        _selectedIds.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dáta boli aktualizované iným používateľom."),
            backgroundColor: Colors.blueAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();

    // Odstránime listenerov
    _signalRService.connection?.off("TaskInstancesChanged", method: _handleDataChanged);
    _signalRService.connection?.off("TaskUpdated", method: _handleDataChanged);
    _signalRService.connection?.off("TaskInvitationsChanged", method: _handleDataChanged);

    // Odpojíme sa od skupiny
    if (_joinedTaskIdRoom != null) {
      _signalRService.leaveTaskRoom(_joinedTaskIdRoom!);
    }

    super.dispose();
  }

  void _submit(UserProfile? auth) async {
    if (_isLoading) return;

    final String respondentName = auth != null ? auth.name : _nameCtrl.text.trim();
    if (respondentName.isEmpty || _selectedIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final model = BulkSubtaskCompleteModel(
        instanceIds: _selectedIds.toList(),
        respondentName: respondentName,
      );

      await ref.read(subtaskInstanceApiServiceProvider).bulkComplete(model);

      if (mounted) {
        AppSnackBar.showSuccess(context, context.l10n.overview_msg_task_updated);

        final asyncData = ref.read(publicTaskProvider(widget.taskHash));
        bool isNowEverythingDone = false;
        if (asyncData.hasValue) {
          final List<SubtaskCombinedListModel> subtasks = List.from(asyncData.value!.subtasks);
          final remainingCount = subtasks.where((s) => !s.isCompleted).length;
          if (remainingCount <= _selectedIds.length) isNowEverythingDone = true;
        }

        setState(() {
          _selectedIds.clear();
          if (isNowEverythingDone) _nameCtrl.clear();
          _isSubmittedSuccess = isNowEverythingDone;
        });

        // Toto vyvolá refresh aj u nás, akurát backend nás medzitým tiež notifikuje
        ref.invalidate(publicTaskProvider(widget.taskHash));
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.user != next.user) {
        ref.invalidate(publicTaskProvider(widget.taskHash));
      }
    });

    final asyncData = ref.watch(publicTaskProvider(widget.taskHash));
    final auth = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return asyncData.when(
      loading: () => const Scaffold(
        appBar: AppTopBar(),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: const AppTopBar(),
        body: _buildErrorState(ref, e),
      ),
      data: (dynamic publicTask) {
        if (publicTask.requiresAuthenticationToComplete && auth == null) {
          return const Scaffold(
              appBar: AppTopBar(),
              body: LoginRequiredView()
          );
        }

        return Scaffold(
          appBar: const AppTopBar(),
          backgroundColor: cs.surface,
          body: _buildTaskBody(publicTask, auth, cs),
        );
      },
    );
  }

  Widget _buildTaskBody(dynamic publicTask, UserProfile? auth, ColorScheme cs) {
    final List<SubtaskCombinedListModel> subtasks = List<SubtaskCombinedListModel>.from(
      publicTask.subtasks,
    );

    final bool isMainTaskOnly =
        subtasks.isNotEmpty &&
            subtasks.every((SubtaskCombinedListModel s) => s.isGeneratedFromTask);

    if (isMainTaskOnly && subtasks.isNotEmpty && !subtasks.first.isCompleted && !_isSubmittedSuccess) {
      if (!_selectedIds.contains(subtasks.first.id)) {
        Future.microtask(() {
          if (mounted) setState(() => _selectedIds.add(subtasks.first.id));
        });
      }
    }

    final bool allFinishedInDb = subtasks.isNotEmpty && subtasks.every((s) => s.isCompleted);
    final bool showCompletedBadge = isMainTaskOnly
        ? (allFinishedInDb || _isSubmittedSuccess)
        : allFinishedInDb;

    final bool hasPendingTasks = !showCompletedBadge;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              TaskHeader(
                title: publicTask.title,
                notes: publicTask.notes,
                deadline: publicTask.deadLine,
              ),

              if (!isMainTaskOnly) ...[
                Text(
                  context.l10n.respond_tasks_label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                SubtaskListCard(
                  subtasks: publicTask.subtasks,
                  selectedIds: _selectedIds,
                  onSelectionChanged: (id, isSelected) {
                    setState(() {
                      isSelected ? _selectedIds.add(id) : _selectedIds.remove(id);
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 24),
              if (hasPendingTasks) ...[
                if (isMainTaskOnly && auth == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      context.l10n.respond_sign_hint,
                      style: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant),
                    ),
                  ),
                RespondentSignatureField(
                  auth: auth,
                  controller: _nameCtrl,
                  onChanged: () => setState(() {}),
                  onSubmitted: () => _submit(auth),
                ),
                const SizedBox(height: 24),
                _buildSubmitButton(auth, isMainTaskOnly, cs),
              ] else ...[
                _buildAllCompletedBadge(cs),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(UserProfile? auth, bool isMainTaskOnly, ColorScheme cs) {
    final bool isDisabled =
        _isLoading || _selectedIds.isEmpty || (auth == null && _nameCtrl.text.isEmpty);
    String buttonText = isMainTaskOnly
        ? context.l10n.respond_btn_sign_send
        : context.l10n.respond_btn_submit(_selectedIds.length);

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _submit(auth),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          disabledBackgroundColor: cs.onSurface.withAlpha(30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildAllCompletedBadge(ColorScheme cs) {
    return Card(
      color: Colors.green.withAlpha(50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              context.l10n.respond_all_completed,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    // Kód pre chybový stav ostáva nezmenený
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String title = context.l10n.error_access_denied;
    String message = "Došlo k chybe pri načítaní úlohy.";
    IconData icon = Icons.error_outline;
    bool showLoginButton = false;

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 403) {
        title = context.l10n.error_not_on_list;
        message = context.l10n.error_not_on_list_msg;
        icon = Icons.person_off_outlined;
      } else if (statusCode == 401) {
        title = context.l10n.error_private_task;
        message = context.l10n.error_private_task_msg;
        icon = Icons.lock_person_outlined;
        showLoginButton = true;
      } else if (statusCode == 404) {
        title = context.l10n.error_not_found;
        message = context.l10n.error_not_found_msg;
        icon = Icons.search_off;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Icon(icon, size: 80, color: cs.primary),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (showLoginButton)
              PrimaryButton(
                text: context.l10n.auth_askforlogin,
                onPressed: () => context.push('/login'),
              )
            else
              OutlinedButton(
                onPressed: () => context.go('/'),
                child: Text(context.l10n.common_back_to_home),
              ),
          ],
        ),
      ),
    );
  }
}