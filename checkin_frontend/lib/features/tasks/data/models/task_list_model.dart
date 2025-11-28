import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_list_model.freezed.dart';
part 'task_list_model.g.dart';

@freezed
sealed class TaskListModel with _$TaskListModel {
  const factory TaskListModel({
    required String id,          // C# Guid -> Dart String
    required String title,
    required String hash,
    required DateTime createdAt,
    required DateTime deadLine,  // Dávaj pozor na veľké/malé písmená, JSON to zvyčajne posiela camelCase (deadLine)
    required String createdById,     // C# Guid -> Dart String
  }) = _TaskListModel;

  factory TaskListModel.fromJson(Map<String, dynamic> json) => _$TaskListModelFromJson(json);
}