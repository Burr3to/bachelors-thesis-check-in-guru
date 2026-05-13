import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

/// Represents the current status of a task.
enum TaskState {
  @JsonValue(0)
  todo,
  @JsonValue(1)
  inProgress,
  @JsonValue(2)
  completed,
  @JsonValue(3)
  missed;

  /// Returns a user-friendly string representation for the UI.
  String get label {
    return switch (this) {
      TaskState.todo => "ToDo",
      TaskState.inProgress => "In Progress",
      TaskState.completed => "Completed",
      TaskState.missed => "Missed",
    };
  }

  /// Returns the color associated with the state for visual indicators.
  Color get color {
    return switch (this) {
      TaskState.todo => const Color.fromRGBO(155, 29, 219, 1.0),
      TaskState.inProgress => Colors.blue,
      TaskState.completed => Colors.green,
      TaskState.missed => Colors.red,
    };
  }
}

/// Defines how subtasks are managed among participants.
enum SubtaskMode {
  /// All users contribute to the same subtask instances.
  @JsonValue(0)
  shared,
  /// Each user gets their own private set of subtask instances.
  @JsonValue(1)
  individual,
}

/// Defines the authentication requirements for accessing a task.
enum AuthMode {
  /// Open to anyone with the link.
  public,
  /// Requires a verified email/account.
  verified
}