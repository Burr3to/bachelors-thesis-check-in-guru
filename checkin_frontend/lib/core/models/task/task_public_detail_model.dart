import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../features/task_overview/data/models/subtask_combined_list_model.dart';
import '../enums/task_enums.dart';

part 'task_public_detail_model.freezed.dart';
part 'task_public_detail_model.g.dart';

@freezed
sealed class TaskPublicDetailModel with _$TaskPublicDetailModel {
  const factory TaskPublicDetailModel({
    required String id,
    required String title,
    String? notes,
    required DateTime deadLine,
    required TaskState state,
    required SubtaskMode subtaskMode,
    required bool requiresAuthenticationToComplete,
    @Default([]) List<SubtaskCombinedListModel> subtasks,
  }) = _TaskPublicDetailModel;

  factory TaskPublicDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TaskPublicDetailModelFromJson(json);
}