import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/task_enums.dart';

part 'task_list_model.freezed.dart';
part 'task_list_model.g.dart';

@freezed
sealed class TaskListModel with _$TaskListModel {
  const factory TaskListModel({
    required String id,
    required String title,
    String? notes,
    required String hash,
    required DateTime createdAt,
    required DateTime deadLine,
    required String createdById,
    required TaskState state,
    required SubtaskMode subtaskMode,
    @Default(true) bool requiresAuthenticationToComplete,
    String? allowedDomain,
  }) = _TaskListModel;

  factory TaskListModel.fromJson(Map<String, dynamic> json) => _$TaskListModelFromJson(json);
}