import 'package:checkin_frontend/features/auth/data/auth_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:checkin_frontend/features/task_respond/data/respond_providers.dart';

import '../../../../core/models/action/bulk_subtask_complete_model.dart';
import '../../../../core/models/user/user_profile.dart';
import '../../../auth/views/providers/auth_provider.dart';

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

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit(UserProfile? auth) async {
    // Rozhodneme sa, aké meno použijeme
    final String respondentName = auth != null ? auth.name : _nameCtrl.text;

    if (respondentName.isEmpty || _selectedIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final model = BulkSubtaskCompleteModel(
        instanceIds: _selectedIds.toList(),
        respondentName: respondentName, // Toto meno sa pošle na BE
      );

      await ref.read(subtaskInstanceApiServiceProvider).bulkComplete(model);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Successfully Saved")));

        // Refresh dát
        ref.invalidate(publicTaskProvider(widget.taskHash));

        // Reset výberu
        setState(() {
          _selectedIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Chyba: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLoginRequiredUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 80, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            "Task requires to be loggen in",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text("Google login"),
            onPressed: () {
              // Pošleme ho na login a vrátime ho sem
              final String targetPath = '/checkin/${widget.taskHash}';
              print("DEBUG: Klik na login, cieľová cesta: $targetPath");

              // Použi Uri na bezpečné zostavenie cesty (GoRouter to má rád)
              final uri = Uri(path: '/login', queryParameters: {'redirect': targetPath});
              context.go(uri.toString());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(publicTaskProvider(widget.taskHash));
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("CheckInGuru"),
        actions: [
          // Ak je užívateľ prihlásený, ukážeme jeho meno a logout tlačidlo
          if (auth != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  auth.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Odhlásiť sa",
              onPressed: () async {
                // Zavoláme logout z tvojho authProvidera
                await ref.read(authProvider.notifier).signOut();

                // Voliteľné: Ak chceš po odhlásení skočiť na home
                // context.go('/home');

                // Ak ostaneš na tejto stránke a task vyžaduje auth,
                // vďaka Riverpodu sa UI samo prepne späť na "Login Required" zámok.
              },
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),

      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Text("Error: $e"),

        data: (publicTask) {
          // --- LOGIKA PRE ZAMKNUTÝ TASK ---
          // Ak task vyžaduje prihlásenie a užívateľ nie je prihlásený
          if (publicTask.requiresAuthenticationToComplete && auth == null) {
            return _buildLoginRequiredUI(context);
          }

          final deadlineStr = DateFormat(
            'dd.MM.yyyy HH:mm',
          ).format(publicTask.deadLine.toLocal());
          // Zistíme, či existujú nejaké NESPLNENÉ úlohy (či je čo robiť)
          // TODO zobrazit aj ulohy co ostatny splnili asi?
          final hasPendingTasks = publicTask.subtasks.any((s) => !s.isCompleted);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- HLAVIČKA TASKU ---
                    Text(
                      publicTask.title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    if (publicTask.notes != null) ...[
                      Text(
                        publicTask.notes!,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Deadline Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm, size: 16, color: Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              "Deadline: $deadlineStr",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- ZOZNAM ÚLOH ---
                    const Text(
                      "Tasks:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      child: Column(
                        children: publicTask.subtasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final subtask = entry.value;
                          final isDone = subtask.isCompleted;

                          return Column(
                            children: [
                              // A) Ak je hotový -> Len Info (ReadOnly)
                              if (isDone)
                                ListTile(
                                  leading: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    subtask.title,
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (subtask.description != null)
                                        Text(subtask.description!),
                                      const SizedBox(height: 4),
                                      // Info o splnení
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 14,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Completed by: ${subtask.respondentName ?? 'Unknown'}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (subtask.completedAt != null)
                                            Text(
                                              DateFormat(
                                                'dd.MM HH:mm',
                                              ).format(subtask.completedAt!.toLocal()),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              // B) Ak nie je hotový -> Checkbox (Aktívny)
                              else
                                CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading, // Checkbox vľavo
                                  title: Text(subtask.title),
                                  subtitle: subtask.description != null
                                      ? Text(subtask.description!)
                                      : null,
                                  value: _selectedIds.contains(subtask.id),
                                  activeColor: Colors.blue,
                                  onChanged: (bool? checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedIds.add(subtask.id);
                                      } else {
                                        _selectedIds.remove(subtask.id);
                                      }
                                    });
                                  },
                                ),

                              // Čiara medzi položkami (okrem poslednej)
                              if (index != publicTask.subtasks.length - 1)
                                const Divider(height: 1, indent: 16, endIndent: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- FORMULÁR NA ODOSLANIE ---
                    // Zobrazíme ho VŽDY, ak existujú nejaké nesplnené úlohy
                    if (hasPendingTasks) ...[
                      // 1. Logika pre Signature / Meno
                      if (auth == null) ...[
                        // ANONYMNÝ POUŽÍVATEĽ -> Musí napísať meno
                        TextField(
                          controller: _nameCtrl,
                          maxLength: 25,
                          decoration: const InputDecoration(
                            labelText: "Your name / signature",
                            hintText: "Sign yourself here",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                        ],
                          onChanged: (_) => setState(() {}),
                        ),
                      ] else ...[
                        // PRIHLÁSENÝ POUŽÍVATEĽ -> Ukážeme mu len info
                        Card(
                          color: Colors.blue.withAlpha(25),
                          child: ListTile(
                            leading: const Icon(Icons.verified_user, color: Colors.blue),
                            title: Text("Signed as: ${auth.name}"),
                            subtitle: Text(auth.email),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_isLoading ||
                                  _selectedIds.isEmpty ||
                                  (auth == null &&
                                      _nameCtrl
                                          .text
                                          .isEmpty)) // Ak nie je auth, meno je povinné
                              ? null
                              : () => _submit(auth), // Pošleme auth do submitu
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _selectedIds.isEmpty
                                      ? "Check tasks you have completed"
                                      : "Submit (${_selectedIds.length})",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ] else ...[
                      const Card(
                        color: Colors.greenAccent,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.thumb_up, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "All Tasks are Completed!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
