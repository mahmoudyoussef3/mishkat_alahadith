/// How many times each ayah is recited before the next.
enum AyahRepeat {
  once(1),
  twice(2),
  thrice(3),
  fiveTimes(5),

  /// The same ayah, over and over, until the reader moves on — for
  /// memorising.
  always(null);

  const AyahRepeat(this.times);

  /// Null for [always].
  final int? times;
}

enum RecitationSpeed {
  slower(0.75),
  normal(1.0),
  faster(1.25),
  fastest(1.5);

  const RecitationSpeed(this.factor);

  final double factor;
}

/// Which of a reciter's files is played.
enum RecitationQuality {
  /// The bitrate the reciter's edition recommends.
  high,

  /// The smallest file there is, for slow or metered connections.
  dataSaver,
}

class RecitationSettings {
  final String reciterId;

  /// The reciter's name as the service gave it when they were chosen, so
  /// the player can name them without a request.
  final String reciterName;
  final AyahRepeat repeat;
  final RecitationSpeed speed;
  final RecitationQuality quality;

  /// Whether the recitation carries on into the next surah, page, juz or
  /// quarter once the one asked for ends.
  final bool continuous;

  const RecitationSettings({
    this.reciterId = 'ar.alafasy',
    this.reciterName = 'مشاري العفاسي',
    this.repeat = AyahRepeat.once,
    this.speed = RecitationSpeed.normal,
    this.quality = RecitationQuality.high,
    this.continuous = true,
  });

  static const RecitationSettings defaults = RecitationSettings();

  /// An edition identifier the service could serve: letters, digits, dots
  /// and dashes only, so a damaged preference can never reshape a request.
  static bool isValidEditionId(String id) =>
      id.isNotEmpty && id.length <= 64 && _editionId.hasMatch(id);

  static final RegExp _editionId = RegExp(r'^[A-Za-z0-9.\-]+$');

  RecitationSettings copyWith({
    String? reciterId,
    String? reciterName,
    AyahRepeat? repeat,
    RecitationSpeed? speed,
    RecitationQuality? quality,
    bool? continuous,
  }) {
    return RecitationSettings(
      reciterId: reciterId ?? this.reciterId,
      reciterName: reciterName ?? this.reciterName,
      repeat: repeat ?? this.repeat,
      speed: speed ?? this.speed,
      quality: quality ?? this.quality,
      continuous: continuous ?? this.continuous,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RecitationSettings &&
      other.reciterId == reciterId &&
      other.reciterName == reciterName &&
      other.repeat == repeat &&
      other.speed == speed &&
      other.quality == quality &&
      other.continuous == continuous;

  @override
  int get hashCode =>
      Object.hash(reciterId, reciterName, repeat, speed, quality, continuous);
}

/// The tafsir and translation shown with each ayah.
class CommentarySettings {
  final String tafsirId;

  /// Null when no translation is shown.
  final String? translationId;

  const CommentarySettings({this.tafsirId = 'ar.muyassar', this.translationId});

  static const CommentarySettings defaults = CommentarySettings();

  /// The editions to fetch with an ayah, tafsir first.
  List<String> get editionIds => [
    tafsirId,
    if (translationId case final translation?) translation,
  ];

  CommentarySettings copyWith({
    String? tafsirId,
    String? Function()? translationId,
  }) {
    return CommentarySettings(
      tafsirId: tafsirId ?? this.tafsirId,
      translationId:
          translationId != null ? translationId() : this.translationId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CommentarySettings &&
      other.tafsirId == tafsirId &&
      other.translationId == translationId;

  @override
  int get hashCode => Object.hash(tafsirId, translationId);
}
