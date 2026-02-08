
enum TaskType { daily, monthly }


class RamadanTaskEntity {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final Set<int> completedDays;

  const RamadanTaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    required this.completedDays,
  });

  RamadanTaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    Set<int>? completedDays,
  }) {
    return RamadanTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      completedDays: completedDays ?? this.completedDays,
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
        _setEquals(other.completedDays, completedDays);
  }

  @override
  int get hashCode {
    final sorted = completedDays.toList()..sort();
    return Object.hash(id, title, description, type, Object.hashAll(sorted));
  }
}

bool _setEquals(Set<int> a, Set<int> b) {
  if (a.length != b.length) return false;
  for (final v in a) {
    if (!b.contains(v)) return false;
  }
  return true;
}
