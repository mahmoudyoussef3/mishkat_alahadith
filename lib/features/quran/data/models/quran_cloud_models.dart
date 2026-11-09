/// The shapes AlQuran Cloud answers with, read defensively: a field of the
/// wrong type drops the entry it belongs to rather than the whole response.
library;

class QuranEditionModel {
  final String identifier;
  final String language;
  final String name;
  final String englishName;

  /// `text` or `audio`.
  final String format;

  /// `quran`, `versebyverse`, `translation`, `tafsir` or `transliteration`.
  final String type;

  /// `rtl`, `ltr`, or null for audio editions.
  final String? direction;

  const QuranEditionModel({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    this.direction,
  });

  /// Null when [json] is not an edition. Search results leave out `format`
  /// and `direction`, so only the identifier is required.
  static QuranEditionModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final identifier = json['identifier'];
    if (identifier is! String || identifier.isEmpty) return null;
    String text(String key) => switch (json[key]) {
      final String value => value,
      _ => '',
    };
    return QuranEditionModel(
      identifier: identifier,
      language: text('language'),
      name: text('name'),
      englishName: text('englishName'),
      format: text('format'),
      type: text('type'),
      direction:
          json['direction'] is String ? json['direction'] as String : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'language': language,
    'name': name,
    'englishName': englishName,
    'format': format,
    'type': type,
    'direction': direction,
  };
}

/// An ayah as the service sends it, in any of its editions.
class CloudAyahModel {
  /// 1‥6236, in mushaf order.
  final int number;
  final String text;

  /// Only on audio editions.
  final String? audio;
  final List<String> audioSecondary;

  /// Absent on the ayahs nested in a surah or page, whose parent names it.
  final QuranEditionModel? edition;

  const CloudAyahModel({
    required this.number,
    required this.text,
    this.audio,
    this.audioSecondary = const [],
    this.edition,
  });

  static CloudAyahModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final number = json['number'];
    if (number is! int) return null;
    final audio = json['audio'];
    final secondary = json['audioSecondary'];
    return CloudAyahModel(
      number: number,
      text: json['text'] is String ? json['text'] as String : '',
      audio: audio is String ? audio : null,
      audioSecondary: [
        if (secondary is List)
          for (final url in secondary)
            if (url is String) url,
      ],
      edition: QuranEditionModel.tryFromJson(json['edition']),
    );
  }

  /// The ayahs of a list, skipping any that cannot be read.
  static List<CloudAyahModel> listFromJson(Object? json) => [
    if (json is List)
      for (final entry in json)
        if (tryFromJson(entry) case final ayah?) ayah,
  ];
}

/// Ayahs that share one edition: a surah, page, juz or hizb quarter.
class CloudAyahGroupModel {
  final List<CloudAyahModel> ayahs;
  final QuranEditionModel? edition;

  const CloudAyahGroupModel({required this.ayahs, this.edition});

  static CloudAyahGroupModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    if (json['ayahs'] is! List) return null;
    return CloudAyahGroupModel(
      ayahs: CloudAyahModel.listFromJson(json['ayahs']),
      edition: QuranEditionModel.tryFromJson(json['edition']),
    );
  }
}

class CloudSearchModel {
  final List<CloudAyahModel> matches;

  /// Every match across all pages.
  final int total;

  const CloudSearchModel({required this.matches, required this.total});

  static const CloudSearchModel empty = CloudSearchModel(matches: [], total: 0);

  static CloudSearchModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final matches = CloudAyahModel.listFromJson(json['matches']);
    final total = json['total'];
    final count = json['count'];
    return CloudSearchModel(
      matches: matches,
      // `total` only comes with a paged request; `count` is then the page's.
      total: switch ((total, count)) {
        (final int total, _) => total,
        (_, final int count) => count,
        _ => matches.length,
      },
    );
  }
}
