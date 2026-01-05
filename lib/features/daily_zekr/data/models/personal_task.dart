import 'package:flutter/foundation.dart';

@immutable
class PersonalTask {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  const PersonalTask({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  PersonalTask copyWith({
    String? id,
    String? title,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return PersonalTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static PersonalTask fromJson(Map<String, Object?> json) {
    return PersonalTask(
      id: json['id'] as String,
      title: json['title'] as String,
      isDone: (json['isDone'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
