import '../../../features/task_create/data/models/task_create_model.dart';
import '../../../../core/models/enums/task_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/subtask_template/subtask_template_create_model.dart';

part 'task_create_provider.g.dart';

@riverpod
class TaskCreateNotifier extends _$TaskCreateNotifier {
  @override
  TaskCreateModel build() {
    // Return initial empty state
    return TaskCreateModel(
      title: '',
      deadLine: DateTime.now().add(const Duration(days: 1)),
      subtaskMode: SubtaskMode.shared,
      requiresAuthenticationToComplete: false,
      invitedEmails: [],
      subtasks: [],
    );
  }

  // Update methods
  void updateTitle(String title) => state = state.copyWith(title: title);

  void updateDescription(String? notes) => state = state.copyWith(notes: notes);

  void setDeadline(DateTime date) => state = state.copyWith(deadLine: date);

  void toggleAuth(bool value) => state = state.copyWith(requiresAuthenticationToComplete: value);

  void setSubtaskMode(SubtaskMode mode) => state = state.copyWith(subtaskMode: mode);

  void addEmail(String email) {
    if (!state.invitedEmails.contains(email)) {
      state = state.copyWith(invitedEmails: [...state.invitedEmails, email]);
    }
  }

  void removeEmail(String email) {
    state = state.copyWith(
        invitedEmails: state.invitedEmails.where((e) => e != email).toList()
    );
  }

  void setEmails(List<String> emails) => state = state.copyWith(invitedEmails: emails);

  void addSubtask(String title) {
    final newSubtask = SubtaskTemplateCreateModel(
      title: title,
      description: '', // Default empty, can be edited later
    );
    state = state.copyWith(subtasks: [...state.subtasks, newSubtask]);
  }

  void removeSubtask(int index) {
    final list = List<SubtaskTemplateCreateModel>.from(state.subtasks);
    list.removeAt(index);
    state = state.copyWith(subtasks: list);
  }

  void updateSubtaskDescription(int index, String description) {
    final list = List<SubtaskTemplateCreateModel>.from(state.subtasks);
    list[index] = list[index].copyWith(description: description);
    state = state.copyWith(subtasks: list);
  }
}