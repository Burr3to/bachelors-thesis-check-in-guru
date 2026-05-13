import '../../models/task/task_create_model.dart';
import '../../../../core/models/enums/task_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/subtask_template/subtask_template_create_model.dart';

part 'task_create_provider.g.dart';

/// Notifier responsible for managing the state of the task creation form.
/// It uses a [TaskCreateModel] as the state, which is updated as the user fills out the UI.
@riverpod
class TaskCreateNotifier extends _$TaskCreateNotifier {
  @override
  TaskCreateModel build() {
    // Initializes the state with default values for a new task
    return TaskCreateModel(
      title: '',
      deadLine: DateTime.now().add(const Duration(days: 1)).toUtc(),
      subtaskMode: SubtaskMode.shared,
      requiresAuthenticationToComplete: false,
      invitedEmails: [],
      subtasks: [],
    );
  }

  /// Updates the main title of the task.
  void updateTitle(String title) => state = state.copyWith(title: title);

  /// Updates the task description/notes.
  void updateDescription(String? notes) => state = state.copyWith(notes: notes);

  /// Sets the task deadline and ensures it is stored in UTC.
  void setDeadline(DateTime date) => state = state.copyWith(deadLine: date.toUtc());

  /// Toggles whether users must be authenticated to check off subtasks.
  void toggleAuth(bool value) => state = state.copyWith(requiresAuthenticationToComplete: value);

  /// Sets the logic mode (Shared vs Individual).
  void setSubtaskMode(SubtaskMode mode) => state = state.copyWith(subtaskMode: mode);

  /// Sets whether invitation emails should be dispatched immediately upon creation.
  void setSendImmediately(bool value) {
    state = state.copyWith(sendInvitesImmediately: value);
  }

  /// Adds a unique email address to the invitation list.
  void addEmail(String email) {
    if (!state.invitedEmails.contains(email)) {
      state = state.copyWith(invitedEmails: [...state.invitedEmails, email]);
    }
  }

  /// Updates the validation status of the email domain currently being entered.
  void setDomainValidation(bool? isValid) {
    state = state.copyWith(isDomainValid: isValid);
  }

  /// Removes a specific email address from the invitation list.
  void removeEmail(String email) {
    state = state.copyWith(
        invitedEmails: state.invitedEmails.where((e) => e != email).toList()
    );
  }

  /// Replaces the entire list of invited emails.
  void setEmails(List<String> emails) => state = state.copyWith(invitedEmails: emails);

  /// Sets a specific allowed domain for task access.
  void updateAllowedDomain(String? domain) {
    state = state.copyWith(allowedDomain: domain);
  }

  /// Adds a new subtask template to the task definition.
  void addSubtask(String title) {
    final newSubtask = SubtaskTemplateCreateModel(
      title: title,
      description: '',
      parentTaskId: '00000000-0000-0000-0000-000000000000', // Placeholder ID until saved
    );
    state = state.copyWith(subtasks: [...state.subtasks, newSubtask]);
  }

  /// Removes all subtasks from the current draft.
  void clearSubtasks() {
    state = state.copyWith(subtasks: []);
  }

  /// Deletes a subtask at the specified index.
  void removeSubtask(int index) {
    final list = List<SubtaskTemplateCreateModel>.from(state.subtasks);
    list.removeAt(index);
    state = state.copyWith(subtasks: list);
  }

  /// Updates the description of a specific subtask by its index.
  void updateSubtaskDescription(int index, String description) {
    final list = List<SubtaskTemplateCreateModel>.from(state.subtasks);
    list[index] = list[index].copyWith(description: description);
    state = state.copyWith(subtasks: list);
  }
}