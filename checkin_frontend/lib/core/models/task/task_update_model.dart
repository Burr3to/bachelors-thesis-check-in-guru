import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/task_enums.dart';
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
    @Default(true) bool requiresAuthenticationToComplete,
    TaskState? state,

    @Default([]) List<String> invitedEmails,
    @Default([]) List<SubtaskTemplateCreateModel> subtasks,
    String? allowedDomain,

    @JsonKey(includeToJson: false) @Default(null) bool? isDomainValid,
  }) = _TaskUpdateModel;

  factory TaskUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$TaskUpdateModelFromJson(json);
}