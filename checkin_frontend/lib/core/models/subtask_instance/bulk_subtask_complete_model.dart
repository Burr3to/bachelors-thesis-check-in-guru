import 'package:freezed_annotation/freezed_annotation.dart';

part 'bulk_subtask_complete_model.freezed.dart';
part 'bulk_subtask_complete_model.g.dart';

@freezed
sealed class BulkSubtaskCompleteModel with _$BulkSubtaskCompleteModel {
  const factory BulkSubtaskCompleteModel({
    required List<String> instanceIds,
    required String respondentName,
  }) = _BulkSubtaskCompleteModel;

  factory BulkSubtaskCompleteModel.fromJson(Map<String, dynamic> json) =>
      _$BulkSubtaskCompleteModelFromJson(json);
}