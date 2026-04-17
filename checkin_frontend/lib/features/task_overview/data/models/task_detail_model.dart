import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/models/invitations/invitation_list_model.dart';
import '../../../../core/models/subtask_template/subtask_template_list_model.dart';

part 'task_detail_model.freezed.dart';
part 'task_detail_model.g.dart';

@freezed
sealed class TaskDetailModel with _$TaskDetailModel {
  const factory TaskDetailModel({
    // --- Polia z List Modelu ---
    required String id,
    required String title,
    String? notes,
    required String hash,
    required DateTime createdAt,
    required DateTime deadLine,
    required DateTime lastModifiedAt,
    required String createdById,
    required TaskState state,
    required SubtaskMode subtaskMode,
    @Default(true) bool requiresAuthenticationToComplete,
    @Default([]) List<InvitationListModel> invitations,
    @Default([]) List<SubtaskTemplateListModel> subtasks,
  }) = _TaskDetailModel;

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) => _$TaskDetailModelFromJson(json);
}