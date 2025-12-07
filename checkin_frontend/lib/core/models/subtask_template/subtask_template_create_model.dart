import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_template_create_model.freezed.dart';
part 'subtask_template_create_model.g.dart';

@freezed
sealed class SubtaskTemplateCreateModel with _$SubtaskTemplateCreateModel {
  const factory SubtaskTemplateCreateModel({
    required String title,
    String? description,
    // Pri vytváraní nového tasku toto ID ešte nemáme,
    // ale ak to backend vyžaduje v modeli, musíme to tam dať (môžeš poslať prázdny string alebo null ak dovolí)
    @Default('00000000-0000-0000-0000-000000000000') String parentTaskId,
  }) = _SubtaskTemplateCreateModel;

  factory SubtaskTemplateCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskTemplateCreateModelFromJson(json);
}