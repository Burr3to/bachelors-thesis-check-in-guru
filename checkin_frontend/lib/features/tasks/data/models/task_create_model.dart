import 'package:freezed_annotation/freezed_annotation.dart';

// Tieto riadky musíš napísať, inak ti build runner nebude fungovať
part 'task_create_model.freezed.dart';
part 'task_create_model.g.dart';

@freezed
sealed class TaskCreateModel with _$TaskCreateModel {
  const factory TaskCreateModel({
    required String title,
    String? notes,
    required DateTime deadLine,
  }) = _TaskCreateModel;

  factory TaskCreateModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCreateModelFromJson(json);
}
