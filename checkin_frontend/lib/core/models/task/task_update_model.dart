import 'package:freezed_annotation/freezed_annotation.dart';

import '../subtask_template/subtask_template_create_model.dart';

part 'task_update_model.freezed.dart';
part 'task_update_model.g.dart';

@freezed
sealed class TaskUpdateModel with _$TaskUpdateModel {
  const factory TaskUpdateModel({
    required String id,
    required String title,
    String? notes,
    required DateTime deadLine,

    @Default([]) List<String> invitedEmails,
    @Default([]) List<SubtaskTemplateCreateModel> subtasks,
  }) = _TaskUpdateModel;

  factory TaskUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$TaskUpdateModelFromJson(json);
}