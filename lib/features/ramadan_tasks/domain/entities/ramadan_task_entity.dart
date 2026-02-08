// Lightweight entity without external dependencies

/// TaskType defines whether a task is Daily (repeatable per day) or Monthly (one-time during Ramadan).
enum TaskType { daily, monthly }

/// RamadanTaskEntity represents a user-defined task tracked across Ramadan.
///
/// - id: Unique identifier
/// - title: Display title
/// - type: Daily or Monthly
/// - completedDays: Set of day numbers (1..30) when the task was completed
class RamadanTaskEntity {
  final String id;
  final String title;
  final TaskType type;
  final Set<int> completedDays;

  const RamadanTaskEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.completedDays,
  });

  RamadanTaskEntity copyWith({
    String? id,
    String? title,
    TaskType? type,
    Set<int>? completedDays,
  }) {
    return RamadanTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
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
        other.type == type &&
        _setEquals(other.completedDays, completedDays);
  }

  @override
  int get hashCode => Object.hash(id, title, type, completedDays.length);
}

bool _setEquals(Set<int> a, Set<int> b) {
  if (a.length != b.length) return false;
  for (final v in a) {
    if (!b.contains(v)) return false;
  }
  return true;
}
