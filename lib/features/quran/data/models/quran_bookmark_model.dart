class QuranBookmarkModel {
  final int page;
  final int? ayahId;
  final int? ayahNumber;
  final int surahNumber;
  final String surahName;
  final int createdAtMillis;

  const QuranBookmarkModel({
    required this.page,
    required this.surahNumber,
    required this.surahName,
    required this.createdAtMillis,
    this.ayahId,
    this.ayahNumber,
  });

  /// Null when a stored entry is missing a required field, so one damaged
  /// bookmark cannot take the whole list down with it.
  static QuranBookmarkModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final page = json['page'];
    final surahNumber = json['surahNumber'];
    final surahName = json['surahName'];
    final createdAt = json['createdAt'];
    if (page is! int ||
        surahNumber is! int ||
        surahName is! String ||
        createdAt is! int) {
      return null;
    }
    final ayahId = json['ayahId'];
    final ayahNumber = json['ayahNumber'];
    return QuranBookmarkModel(
      page: page,
      surahNumber: surahNumber,
      surahName: surahName,
      createdAtMillis: createdAt,
      ayahId: ayahId is int ? ayahId : null,
      ayahNumber: ayahNumber is int ? ayahNumber : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'surahNumber': surahNumber,
    'surahName': surahName,
    'createdAt': createdAtMillis,
    if (ayahId != null) 'ayahId': ayahId,
    if (ayahNumber != null) 'ayahNumber': ayahNumber,
  };
}
