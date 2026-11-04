/// A chapter as the Islamic-Pro-azkar-API data files spell it:
/// `{"id", "category", "audio": "/audio/x.mp3", "filename", "array": […]}`.
class AzkarCategoryModel {
  final int id;
  final String title;
  final String? audioFile;
  final List<ZikrModel> azkar;

  const AzkarCategoryModel({
    required this.id,
    required this.title,
    required this.azkar,
    this.audioFile,
  });

  /// Null when a required field is missing, so one damaged chapter cannot
  /// take the whole book down with it. Damaged azkar are skipped likewise.
  static AzkarCategoryModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final id = json['id'];
    final title = json['category'];
    final array = json['array'];
    if (id is! int || title is! String || title.trim().isEmpty) return null;
    if (array is! List) return null;
    return AzkarCategoryModel(
      id: id,
      title: title.trim(),
      audioFile: audioFileOf(json['audio']),
      azkar: [
        for (final entry in array)
          if (ZikrModel.tryFromJson(entry) case final zikr?) zikr,
      ],
    );
  }
}

/// One zikr: `{"id", "text", "transliteration", "count", "audio", …}`.
class ZikrModel {
  final int id;
  final String text;
  final String? transliteration;
  final int count;
  final String? audioFile;

  const ZikrModel({
    required this.id,
    required this.text,
    required this.count,
    this.transliteration,
    this.audioFile,
  });

  /// Null when the id or text is missing. A missing or nonsensical count is
  /// read as once.
  static ZikrModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final id = json['id'];
    final text = json['text'];
    if (id is! int || text is! String || text.trim().isEmpty) return null;
    final count = json['count'];
    final transliteration = json['transliteration'];
    return ZikrModel(
      id: id,
      text: text.trim(),
      count: count is int && count > 0 ? count : 1,
      transliteration:
          transliteration is String && transliteration.trim().isNotEmpty
              ? transliteration.trim()
              : null,
      audioFile: audioFileOf(json['audio']),
    );
  }
}

/// «/audio/75.mp3» → «75.mp3»; null for a missing or empty path.
String? audioFileOf(Object? path) {
  if (path is! String) return null;
  final name = path.split('/').last.trim();
  return name.isEmpty ? null : name;
}
