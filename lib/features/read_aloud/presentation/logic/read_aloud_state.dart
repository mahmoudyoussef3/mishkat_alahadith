part of 'read_aloud_cubit.dart';

enum ReadAloudStatus { idle, preparing, playing, paused, completed }

/// A message for the reader, shown once: [id] tells a new notice from a
/// repeat of the same text.
class ReadAloudNotice {
  final int id;
  final String message;

  /// The screen it concerns, so only that screen shows it.
  final Object? owner;

  const ReadAloudNotice(this.id, this.message, {this.owner});

  @override
  bool operator ==(Object other) => other is ReadAloudNotice && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ReadAloudState {
  /// The screen that started the reading.
  final Object? owner;
  final SpeechTrack? track;

  /// The segment of [track] being read.
  final int index;
  final ReadAloudStatus status;

  /// How far into the current segment's spoken text the reading is.
  final int spokenOffset;

  /// The word being read, as a range of the current segment's source.
  final ({int start, int end})? word;

  /// A voice sample is playing; the reading, if any, is paused under it.
  final bool previewing;

  /// The hadith is being recorded to a file.
  final bool exporting;

  /// The reading finished with "next hadith" on: the screen should move on
  /// to the next hadith, which is then read too.
  final bool continueToNext;
  final ReadAloudNotice? notice;

  const ReadAloudState({
    this.owner,
    this.track,
    this.index = 0,
    this.status = ReadAloudStatus.idle,
    this.spokenOffset = 0,
    this.word,
    this.previewing = false,
    this.exporting = false,
    this.continueToNext = false,
    this.notice,
  });

  SpeechSegment? get segment {
    final track = this.track;
    if (track == null || index < 0 || index >= track.segments.length) {
      return null;
    }
    return track.segments[index];
  }

  bool ownedBy(Object? owner) => owner != null && identical(this.owner, owner);

  /// A reading is loaded, whether going, paused or just finished.
  bool get isActive => track != null && status != ReadAloudStatus.idle;

  /// Reading, or about to.
  bool get isPlaying =>
      status == ReadAloudStatus.playing || status == ReadAloudStatus.preparing;

  bool get canGoBack => isActive && (index > 0 || spokenOffset > 0);

  bool get canGoForward {
    final track = this.track;
    return track != null &&
        status != ReadAloudStatus.completed &&
        status != ReadAloudStatus.idle &&
        index < track.segments.length - 1;
  }

  /// Share of the reading done, 0 to 1.
  double get progress {
    final track = this.track;
    if (track == null) return 0;
    if (status == ReadAloudStatus.completed) return 1;
    return track.progressAt(index, spokenOffset);
  }

  ReadAloudState copyWith({
    int? index,
    ReadAloudStatus? status,
    int? spokenOffset,
    ({int start, int end})? word,
    bool clearWord = false,
    bool? previewing,
    bool? exporting,
    bool? continueToNext,
    ReadAloudNotice? notice,
  }) {
    return ReadAloudState(
      owner: owner,
      track: track,
      index: index ?? this.index,
      status: status ?? this.status,
      spokenOffset: spokenOffset ?? this.spokenOffset,
      word: clearWord ? null : word ?? this.word,
      previewing: previewing ?? this.previewing,
      exporting: exporting ?? this.exporting,
      continueToNext: continueToNext ?? this.continueToNext,
      notice: notice ?? this.notice,
    );
  }
}
