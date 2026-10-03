import 'ahadiths_model.dart';

class CachedAhadithData {
  final List<Hadith> ahadith;
  final int lastPage;
  final int totalCount;
  final DateTime cachedAt;

  CachedAhadithData({
    required this.ahadith,
    required this.lastPage,
    required this.totalCount,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
    'ahadith': ahadith.map((h) => h.toJson()).toList(),
    'lastPage': lastPage,
    'totalCount': totalCount,
    'cachedAt': cachedAt.millisecondsSinceEpoch,
  };

  factory CachedAhadithData.fromJson(Map<String, dynamic> json) {
    return CachedAhadithData(
      ahadith:
          (json['ahadith'] as List)
              .map((h) => Hadith.fromJson(h as Map<String, dynamic>))
              .toList(),
      lastPage: json['lastPage'] as int? ?? 1,
      totalCount: json['totalCount'] as int? ?? 0,
      cachedAt: DateTime.fromMillisecondsSinceEpoch(json['cachedAt'] as int),
    );
  }
}
