import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_template_create_model.freezed.dart';
part 'subtask_template_create_model.g.dart';

@freezed
sealed class SubtaskTemplateCreateModel with _$SubtaskTemplateCreateModel {
  const factory SubtaskTemplateCreateModel({
    required String title,
    String? description,
    required String parentTaskId,
  }) = _SubtaskTemplateCreateModel;

  factory SubtaskTemplateCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskTemplateCreateModelFromJson(json);
}