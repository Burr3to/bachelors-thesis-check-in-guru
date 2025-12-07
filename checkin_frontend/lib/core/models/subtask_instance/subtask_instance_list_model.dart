import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_instance_list_model.freezed.dart';
part 'subtask_instance_list_model.g.dart';

@freezed
sealed class SubtaskInstanceListModel with _$SubtaskInstanceListModel {
  const factory SubtaskInstanceListModel({
    required String id,
    required String templateSubtaskId,
    String? assignedToUserId,
    @Default(false) bool isCompleted,
    String? completedByUserId,
    DateTime? completedAt,
  }) = _SubtaskInstanceListModel;

  factory SubtaskInstanceListModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskInstanceListModelFromJson(json);
}