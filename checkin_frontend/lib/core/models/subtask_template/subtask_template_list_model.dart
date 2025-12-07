import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_template_list_model.freezed.dart';
part 'subtask_template_list_model.g.dart';

@freezed
sealed class SubtaskTemplateListModel with _$SubtaskTemplateListModel {
  const factory SubtaskTemplateListModel({
    required String id,
    required String title,
    String? description,
    required String parentTaskId,
  }) = _SubtaskTemplateListModel;

  factory SubtaskTemplateListModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskTemplateListModelFromJson(json);
}