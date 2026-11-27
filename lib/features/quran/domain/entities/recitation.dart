import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';

import 'quran_metrics.dart';

/// The divisions of the mushaf the service can recite in one request.
enum RecitationScopeKind {
  surah(QuranMetrics.surahCount),
  page(QuranMetrics.pageCount),
  juz(QuranMetrics.juzCount),
  hizbQuarter(QuranMetrics.hizbQuarterCount);

  const RecitationScopeKind(this.count);

  /// How many of them the mushaf has, numbered from 1.
  final int count;
}

/// One surah, page, juz or quarter of a hizb, to be recited whole.
class RecitationScope {
  final RecitationScopeKind kind;
  final int number;

  const RecitationScope(this.kind, this.number);

  const RecitationScope.surah(this.number) : kind = RecitationScopeKind.surah;

  const RecitationScope.page(this.number) : kind = RecitationScopeKind.page;

  const RecitationScope.juz(this.number) : kind = RecitationScopeKind.juz;

  const RecitationScope.hizbQuarter(this.number)
    : kind = RecitationScopeKind.hizbQuarter;

  bool get isValid => number >= 1 && number <= kind.count;

  /// The one after it, for a recitation that carries on; null after the last.
  RecitationScope? get next =>
      number < kind.count ? RecitationScope(kind, number + 1) : null;

  @override
  bool operator ==(Object other) =>
      other is RecitationScope && other.kind == kind && other.number == number;

  @override
  int get hashCode => Object.hash(kind, number);

  @override
  String toString() => 'RecitationScope(${kind.name} $number)';
}

/// What the reader asked to hear.
sealed class RecitationRequest {
  const RecitationRequest();
}

/// The surah [ayahId] is in, from that ayah on.
final class RecitationFromAyah extends RecitationRequest {
  final int ayahId;

  const RecitationFromAyah(this.ayahId);

  @override
  bool operator ==(Object other) =>
      other is RecitationFromAyah && other.ayahId == ayahId;

  @override
  int get hashCode => ayahId.hashCode;
}

/// A whole [scope], from its first ayah or from [startAyahId] when that is
/// in it.
final class RecitationOfScope extends RecitationRequest {
  final RecitationScope scope;
  final int? startAyahId;

  const RecitationOfScope(this.scope, {this.startAyahId});

  @override
  bool operator ==(Object other) =>
      other is RecitationOfScope &&
      other.scope == scope &&
      other.startAyahId == startAyahId;

  @override
  int get hashCode => Object.hash(scope, startAyahId);
}

/// Where one ayah's recitation can be fetched from, best source first.
class RecitationAudio {
  /// 1‥6236, in mushaf order.
  final int ayahId;

  /// The edition's recommended bitrate.
  final String url;

  /// The same recitation at lower bitrates, as the service lists them.
  final List<String> lowBitrateUrls;

  const RecitationAudio({
    required this.ayahId,
    required this.url,
    this.lowBitrateUrls = const [],
  });
}

/// One ayah of a recitation, placed in the mushaf so the reader can follow.
class RecitationTrack {
  final int ayahId;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final int page;
  final String url;

  const RecitationTrack({
    required this.ayahId,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.page,
    required this.url,
  });

  /// «سورة البقرة»: the surah as the system's controls outside the app name
  /// what plays, its ayahs shown as one.
  String get surahTitle => 'سورة $surahName';

  /// «سورة البقرة · الآية ٢٥٥»: the ayah as the player in the app names it.
  String get title => '$surahTitle · الآية ${toArabicDigits('$ayahNumber')}';

  @override
  bool operator ==(Object other) =>
      other is RecitationTrack && other.ayahId == ayahId && other.url == url;

  @override
  int get hashCode => Object.hash(ayahId, url);
}

/// A [scope] as recited by one reciter, ayah by ayah.
class RecitationPlaylist {
  final RecitationScope scope;
  final String reciterId;

  /// Never empty, in mushaf order.
  final List<RecitationTrack> tracks;

  const RecitationPlaylist({
    required this.scope,
    required this.reciterId,
    required this.tracks,
  });

  /// The position of [ayahId] in [tracks], or -1.
  int indexOfAyah(int ayahId) => tracks.indexWhere((t) => t.ayahId == ayahId);
}

/// Where a recitation was left off — the part it recited and the ayah it
/// was on — kept so it can be picked up again after the app was closed.
class RecitationResumePoint {
  final RecitationScope scope;
  final RecitationTrack track;

  const RecitationResumePoint({required this.scope, required this.track});

  /// The recitation again, from the ayah it was on.
  RecitationRequest get request =>
      RecitationOfScope(scope, startAyahId: track.ayahId);

  @override
  bool operator ==(Object other) =>
      other is RecitationResumePoint &&
      other.scope == scope &&
      other.track == track;

  @override
  int get hashCode => Object.hash(scope, track);
}

/// Elapsed time and duration for the ayah currently loaded.
typedef RecitationProgress =
    ({String url, Duration position, Duration duration});

/// What the player is doing.
enum RecitationStatus { idle, loading, playing, paused, completed }

/// A control the listener used outside the app: on the notification, the
/// lock screen, headphones, a watch or a car.
enum RecitationCommand { play, pause, next, previous, stop }

/// The player's status and the track it is on.
class RecitationPlayback {
  final RecitationStatus status;

  /// The track of the playlist being played, null while there is none.
  final int? trackIndex;

  const RecitationPlayback({required this.status, this.trackIndex});

  @override
  bool operator ==(Object other) =>
      other is RecitationPlayback &&
      other.status == status &&
      other.trackIndex == trackIndex;

  @override
  int get hashCode => Object.hash(status, trackIndex);

  @override
  String toString() => 'RecitationPlayback(${status.name}, $trackIndex)';
}
