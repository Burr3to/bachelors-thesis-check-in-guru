import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/models/enums/task_enums.dart';

part 'task_list_query.freezed.dart';
part 'task_list_query.g.dart';

@freezed
sealed class TaskListQuery with _$TaskListQuery {
  const factory TaskListQuery({
    @Default(1) int pageNumber,
    @Default(12) int pageSize,
    @Default("createdat") String sortBy,
    @Default(true) bool sortDesc,
    String? nameContains,
    TaskState? status,
    DateTime? deadLineBefore,
    DateTime? deadLineAfter,
    SubtaskMode? mode,
    bool? requiresAuth,
    bool? onlyOverdue,
    bool? onlyActive,

  }) = _TaskListQuery;

  factory TaskListQuery.fromJson(Map<String, dynamic> json) =>
      _$TaskListQueryFromJson(json);
}