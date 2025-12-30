// features/task_list/data/models/query_result.dart

import 'package:json_annotation/json_annotation.dart';

part 'query_result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class QueryResult<T> {
  // 'items' zodpovedá poľu 'Items' v C#
  final List<T> items;
  // 'totalCount' zodpovedá 'TotalCount' v C#
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  QueryResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  // Custom Factory pre generické triedy, ktorý zabezpečí správnu deserializáciu
  factory QueryResult.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$QueryResultFromJson<T>(json, fromJsonT);
}