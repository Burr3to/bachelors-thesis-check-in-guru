import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_detail_model.freezed.dart';
part 'task_detail_model.g.dart';

@freezed
sealed class TaskDetailModel with _$TaskDetailModel {
  const factory TaskDetailModel({
    // --- Polia z List Modelu ---
    required String id,
    required String title,
    required String hash,
    required DateTime createdAt,
    required DateTime deadLine,
    required String createdById,
    // (A nezabudni na Status, ktorý ti v Dart List modeli chýbal!)
    // required TaskStatus status,

    // --- Nové polia pre Detail ---
    String? notes, // Nullable, lebo v C# máš string?

    // Defaultne prázdny zoznam, ak príde null alebo nič
    // @Default([]) List<TaskResponseListModel> responses,
  }) = _TaskDetailModel;

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) => _$TaskDetailModelFromJson(json);
}