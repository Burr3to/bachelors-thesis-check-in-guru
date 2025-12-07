import 'package:freezed_annotation/freezed_annotation.dart';

enum TaskStatus {
  @JsonValue(0) todo,
  @JsonValue(1) inProgress,
  @JsonValue(2) completed
}

enum SubtaskMode {
  @JsonValue(1) shared,
  @JsonValue(2) individual
}