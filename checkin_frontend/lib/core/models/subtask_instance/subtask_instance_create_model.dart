import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_instance_create_model.freezed.dart';
part 'subtask_instance_create_model.g.dart';

@freezed
sealed class SubtaskInstanceCreateModel with _$SubtaskInstanceCreateModel {
  const factory SubtaskInstanceCreateModel({
    required String templateSubtaskId,
    String? assignedToUserId, // Nullable Guid
  }) = _SubtaskInstanceCreateModel;

  factory SubtaskInstanceCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskInstanceCreateModelFromJson(json);
}