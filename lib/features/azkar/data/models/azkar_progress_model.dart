/// The day's counts as stored:
/// `{"day": "2026-11-05", "counts": {"27": {"1": 1, "2": 3}}}`.
class AzkarProgressModel {
  /// The day, as `yyyy-MM-dd`.
  final String day;

  /// Chapter id → zikr id → times said.
  final Map<int, Map<int, int>> counts;

  const AzkarProgressModel({required this.day, required this.counts});

  /// Null when the day is missing; unreadable counts are skipped.
  static AzkarProgressModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final day = json['day'];
    if (day is! String || day.isEmpty) return null;
    final rawCounts = json['counts'];
    final counts = <int, Map<int, int>>{};
    if (rawCounts is Map<String, dynamic>) {
      for (final MapEntry(key: categoryKey, value: rawCategory)
          in rawCounts.entries) {
        final categoryId = int.tryParse(categoryKey);
        if (categoryId == null || rawCategory is! Map<String, dynamic>) {
          continue;
        }
        final category = <int, int>{
          for (final MapEntry(key: zikrKey, value: count)
              in rawCategory.entries)
            if (int.tryParse(zikrKey) case final zikrId?)
              if (count is int && count > 0) zikrId: count,
        };
        if (category.isNotEmpty) counts[categoryId] = category;
      }
    }
    return AzkarProgressModel(day: day, counts: counts);
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'counts': {
      for (final MapEntry(key: categoryId, value: category) in counts.entries)
        '$categoryId': {
          for (final MapEntry(key: zikrId, value: count) in category.entries)
            '$zikrId': count,
        },
    },
  };
}
