import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_template_update_model.freezed.dart';
part 'subtask_template_update_model.g.dart';

@freezed
sealed class SubtaskTemplateUpdateModel with _$SubtaskTemplateUpdateModel {
  const factory SubtaskTemplateUpdateModel({
    required String id,
    required String title,
    String? description,
  }) = _SubtaskTemplateUpdateModel;

  factory SubtaskTemplateUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskTemplateUpdateModelFromJson(json);
}