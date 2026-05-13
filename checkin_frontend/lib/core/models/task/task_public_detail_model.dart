import 'package:freezed_annotation/freezed_annotation.dart';
import '../subtask_instance/subtask_combined_list_model.dart';
import '../enums/task_enums.dart';

part 'task_public_detail_model.freezed.dart';
part 'task_public_detail_model.g.dart';

@freezed
sealed class TaskPublicDetailModel with _$TaskPublicDetailModel {
  const factory TaskPublicDetailModel({
    String? id,
    String? hash,
    @Default('') String title,
    String? notes,
    DateTime? deadLine,
    @Default(TaskState.inProgress) TaskState state,
    @Default(SubtaskMode.individual) SubtaskMode subtaskMode,
    @Default(false) bool requiresAuthenticationToComplete,
    @Default([]) List<SubtaskCombinedListModel> subtasks,
    String? allowedDomain,
    @Default(false) bool isForbidden,
    String? forbiddenMessage,
  }) = _TaskPublicDetailModel;

  factory TaskPublicDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TaskPublicDetailModelFromJson(json);
}