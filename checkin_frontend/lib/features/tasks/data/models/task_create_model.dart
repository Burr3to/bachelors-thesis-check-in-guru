import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/models/subtask_template/subtask_template_create_model.dart';

part 'task_create_model.freezed.dart';
part 'task_create_model.g.dart';

@freezed
sealed class TaskCreateModel with _$TaskCreateModel {
  const factory TaskCreateModel({
    required String title,
    String? notes,
    required DateTime deadLine,

    // Nové polia
    required SubtaskMode subtaskMode,
    @Default(true) bool requiresAuthenticationToComplete,

    // Zoznam podúloh na vytvorenie
    @Default([]) List<SubtaskTemplateCreateModel> subtasks,
  }) = _TaskCreateModel;

  factory TaskCreateModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCreateModelFromJson(json);
}