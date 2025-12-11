import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:checkin_frontend/features/task_respond/data/respond_providers.dart';

import '../../../../core/models/action/bulk_subtask_complete_model.dart';

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

  void _submit() async {
    if (_nameCtrl.text.isEmpty || _selectedIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final model = BulkSubtaskCompleteModel(
          instanceIds: _selectedIds.toList(),
          respondentName: _nameCtrl.text
      );
      await ref.read(subtaskInstanceApiServiceProvider).bulkComplete(model);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Sucessfully Saved"),
          duration: Duration(seconds: 2),
        ));

        // Refresh dát z API
        ref.invalidate(publicTaskProvider(widget.taskHash));

        // Vyčistíme len výber (IDčka), lebo tie sú už splnené.
        // Meno (_nameCtrl) necháme, aby user nemusel písať znova.
        _selectedIds.clear();
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Chyba: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(publicTaskProvider(widget.taskHash));

    return Scaffold(
      appBar: AppBar(title: const Text("Check-In")),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Loading Error: $e")),

        data: (publicTask) {
          final deadlineStr = DateFormat('dd.MM.yyyy HH:mm').format(publicTask.deadLine.toLocal());
          // Zistíme, či existujú nejaké NESPLNENÉ úlohy (či je čo robiť)
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
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
                            border: Border.all(color: Colors.red[200]!)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm, size: 16, color: Colors.red),
                            const SizedBox(width: 6),
                            Text("Deadline: $deadlineStr", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- ZOZNAM ÚLOH ---
                    const Text("Tasks:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                                  leading: const Icon(Icons.check_circle, color: Colors.green),
                                  title: Text(
                                    subtask.title,
                                    style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (subtask.description != null) Text(subtask.description!),
                                      const SizedBox(height: 4),
                                      // Info o splnení
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 14, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Completed by: ${subtask.respondentName ?? 'Unknown'}",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                                          ),
                                          const SizedBox(width: 8),
                                          if (subtask.completedAt != null)
                                            Text(
                                              DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal()),
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              // B) Ak nie je hotový -> Checkbox (Aktívny)
                              else
                                CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading, // Checkbox vľavo
                                  title: Text(subtask.title),
                                  subtitle: subtask.description != null ? Text(subtask.description!) : null,
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
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Your name / signature",
                          hintText: "Sign yourself here",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        // Keď dopíše meno, prebudujeme widget (aby sa aktivoval button)
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          // Button je aktívny len ak:
                          // 1. Nie je loading
                          // 2. Je niečo vybraté
                          // 3. Meno nie je prázdne
                          onPressed: (_isLoading || _selectedIds.isEmpty || _nameCtrl.text.isEmpty)
                              ? null
                              : _submit,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300], // Farba keď je neaktívne
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
                              Text("All Tasks are Completed!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
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