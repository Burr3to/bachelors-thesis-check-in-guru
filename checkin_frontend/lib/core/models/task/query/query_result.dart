import 'package:json_annotation/json_annotation.dart';

part 'query_result.g.dart';

/// A generic container for paginated API responses.
/// This matches the C# back-end QueryResult<T> structure.
@JsonSerializable(genericArgumentFactories: true)
class QueryResult<T> {
  /// The collection of items for the current page.
  final List<T> items;

  /// Total number of items across all pages.
  final int totalCount;

  final int pageNumber;
  final int pageSize;

  QueryResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  /// Generic factory for JSON deserialization of nested types.
  factory QueryResult.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$QueryResultFromJson<T>(json, fromJsonT);
}