enum TaskType { daily, todayOnly }

class RamadanTaskEntity {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final Set<int> completedDays;

  /// For [TaskType.todayOnly] tasks: which Ramadan day (1..30) this task
  /// was created for. Ignored for [TaskType.daily] tasks.
  final int createdForDay;

  const RamadanTaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    required this.completedDays,
    this.createdForDay = 0,
  });

  RamadanTaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    Set<int>? completedDays,
    int? createdForDay,
  }) {
    return RamadanTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      completedDays: completedDays ?? this.completedDays,
      createdForDay: createdForDay ?? this.createdForDay,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RamadanTaskEntity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.createdForDay == createdForDay &&
        _setEquals(other.completedDays, completedDays);
  }

  @override
  int get hashCode {
    final sorted = completedDays.toList()..sort();
    return Object.hash(
      id,
      title,
      description,
      type,
      createdForDay,
      Object.hashAll(sorted),
    );
  }
}

bool _setEquals(Set<int> a, Set<int> b) {
  if (a.length != b.length) return false;
  for (final v in a) {
    if (!b.contains(v)) return false;
  }
  return true;
}
