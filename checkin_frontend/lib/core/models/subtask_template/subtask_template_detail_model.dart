import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_template_detail_model.freezed.dart';
part 'subtask_template_detail_model.g.dart';

@freezed
sealed class SubtaskTemplateDetailModel with _$SubtaskTemplateDetailModel {
  const factory SubtaskTemplateDetailModel({
    required String id,
    required String title,
    String? description,
    required String parentTaskId,
    DateTime? createdAt,
    @Default(false) bool isGeneratedFromTask,
  }) = _SubtaskTemplateDetailModel;

  factory SubtaskTemplateDetailModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskTemplateDetailModelFromJson(json);
}