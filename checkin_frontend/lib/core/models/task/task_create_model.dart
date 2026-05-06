import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/task_enums.dart';
import '../subtask_template/subtask_template_create_model.dart';

part 'task_create_model.freezed.dart';
part 'task_create_model.g.dart';

@freezed
sealed class TaskCreateModel with _$TaskCreateModel {
  const factory TaskCreateModel({
    required String title,
    String? notes,
    required DateTime deadLine,
    required SubtaskMode subtaskMode,
    @Default(true) bool requiresAuthenticationToComplete,
    @Default([]) List<SubtaskTemplateCreateModel> subtasks,
    @Default([]) List<String> invitedEmails,
    @Default(false) bool sendInvitesImmediately,
    String? allowedDomain,

    @JsonKey(includeToJson: false)
    @Default(null) bool? isDomainValid, // null = unchecked, true = ok, false = suspicious
  }) = _TaskCreateModel;

  factory TaskCreateModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCreateModelFromJson(json);
}