import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

enum TaskState {
  @JsonValue(0)
  todo,
  @JsonValue(1)
  inProgress,
  @JsonValue(2)
  completed;

  String get label {
    return switch (this) {
      TaskState.todo => "ToDo",
      TaskState.inProgress => "In Progress",
      TaskState.completed => "Completed",
    };
  }

  Color get color {
    return switch (this) {
      TaskState.todo => Color.fromRGBO(155, 29, 219, 1.0),
      TaskState.inProgress => Colors.blue,
      TaskState.completed => Colors.green,
    };
  }
}

enum SubtaskMode {
  @JsonValue(0)
  shared,
  @JsonValue(1)
  individual,
}

enum AuthMode { public, verified }