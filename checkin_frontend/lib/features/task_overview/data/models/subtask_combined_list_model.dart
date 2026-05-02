import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_combined_list_model.freezed.dart';
part 'subtask_combined_list_model.g.dart';

@freezed
sealed class SubtaskCombinedListModel with _$SubtaskCombinedListModel {
  const factory SubtaskCombinedListModel({
    required String id,               // ID Inštancie
    @Default(false) bool isCompleted,
    required String responseGroupId,
    String? respondentName,
    String? comment,
    String? assignedToUserId,
    String? completedByUserId,
    DateTime? completedAt,
    required String title,
    String? assignedToEmail,
    required DateTime deadline,
    DateTime? createdAt,
    String? description,              // Popis zo šablóny
    required String templateSubtaskId,
    @Default(false) bool isGeneratedFromTask,
  }) = _SubtaskCombinedListModel;

  factory SubtaskCombinedListModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskCombinedListModelFromJson(json);
}