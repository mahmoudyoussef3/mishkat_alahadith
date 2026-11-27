/// Where a recitation was left off, as kept on the device.
class RecitationResumeModel {
  /// A `RecitationScopeKind` by name.
  final String scopeKind;
  final int scopeNumber;
  final int ayahId;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final int page;
  final String url;

  const RecitationResumeModel({
    required this.scopeKind,
    required this.scopeNumber,
    required this.ayahId,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.page,
    required this.url,
  });

  /// Null when the stored entry is missing a field: there is then nothing
  /// to pick up.
  static RecitationResumeModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    if (json case {
      'scopeKind': final String scopeKind,
      'scopeNumber': final int scopeNumber,
      'ayahId': final int ayahId,
      'surahNumber': final int surahNumber,
      'surahName': final String surahName,
      'ayahNumber': final int ayahNumber,
      'page': final int page,
      'url': final String url,
    }) {
      return RecitationResumeModel(
        scopeKind: scopeKind,
        scopeNumber: scopeNumber,
        ayahId: ayahId,
        surahNumber: surahNumber,
        surahName: surahName,
        ayahNumber: ayahNumber,
        page: page,
        url: url,
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'scopeKind': scopeKind,
    'scopeNumber': scopeNumber,
    'ayahId': ayahId,
    'surahNumber': surahNumber,
    'surahName': surahName,
    'ayahNumber': ayahNumber,
    'page': page,
    'url': url,
  };
}
