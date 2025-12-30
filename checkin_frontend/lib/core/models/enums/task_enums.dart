import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

enum TaskStatus {
  @JsonValue(0)
  todo,
  @JsonValue(1)
  inProgress,
  @JsonValue(2)
  completed;

  String get label {
    return switch (this) {
      TaskStatus.todo => "ToDo",
      TaskStatus.inProgress => "In Progress",
      TaskStatus.completed => "Completed",
    };
  }

  Color get color {
    return switch (this) {
      TaskStatus.todo => Color.fromRGBO(155, 29, 219, 1.0),
      TaskStatus.inProgress => Colors.blue,
      TaskStatus.completed => Colors.green,
    };
  }
}

enum SubtaskMode {
  @JsonValue(1)
  shared,
  @JsonValue(2)
  individual,
}
