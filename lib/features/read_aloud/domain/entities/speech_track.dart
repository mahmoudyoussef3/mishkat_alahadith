/// Which part of a hadith page a stretch of speech reads.
enum SpeechPart {
  /// Spoken titles: the hadith number, «الشرح»… Nothing on screen.
  heading,

  /// The chain of narrators.
  isnad,

  /// The words of the hadith.
  matn,

  /// Where it is recorded: «رواه البخاري».
  source,
  explanation,
  lesson,
  wordMeaning,
}

/// One utterance: text for the engine, and where each of its characters
/// came from on screen, so the word being read can be highlighted.
class SpeechSegment {
  final SpeechPart part;

  /// Index of the lesson or word meaning; 0 for the other parts.
  final int item;

  /// The on-screen text this segment reads from; null when it has none to
  /// highlight in (headings, lessons and word meanings are highlighted
  /// whole).
  final String? source;
  final String spoken;
  final List<int> _sourceStarts;
  final List<int> _sourceEnds;

  SpeechSegment({
    required this.part,
    this.item = 0,
    this.source,
    required this.spoken,
    List<int>? sourceStarts,
    List<int>? sourceEnds,
  }) : _sourceStarts = sourceStarts ?? const [],
       _sourceEnds = sourceEnds ?? const [],
       assert(
         source == null ||
             (sourceStarts?.length == spoken.length &&
                 sourceEnds?.length == spoken.length),
         'A segment with a source maps every spoken character onto it.',
       );

  /// Maps `spoken[start, end)` onto [source]; null when there is nothing to
  /// highlight.
  ({int start, int end})? sourceRange(int start, int end) {
    if (source == null || start < 0 || end > spoken.length || start >= end) {
      return null;
    }
    return (start: _sourceStarts[start], end: _sourceEnds[end - 1]);
  }

  /// True when this segment reads [part] and [item] of a page showing
  /// [text]. Pass no [text] for parts highlighted whole.
  bool reads(SpeechPart part, {int item = 0, String? text}) =>
      this.part == part &&
      this.item == item &&
      (text == null || identical(text, source) || text == source);
}

/// Everything read for one hadith, in order.
class SpeechTrack {
  /// Same key, same reading: a play on it resumes rather than restarts.
  final String key;

  /// Shown in the player, e.g. «صحيح البخاري · حديث ٩».
  final String title;
  final List<SpeechSegment> segments;
  final List<int> _starts;
  final int length;

  SpeechTrack._(this.key, this.title, this.segments, this._starts, this.length);

  factory SpeechTrack({
    required String key,
    required String title,
    required List<SpeechSegment> segments,
  }) {
    final starts = <int>[];
    var total = 0;
    for (final segment in segments) {
      starts.add(total);
      total += segment.spoken.length;
    }
    return SpeechTrack._(
      key,
      title,
      List.unmodifiable(segments),
      starts,
      total,
    );
  }

  bool get isEmpty => segments.isEmpty;

  /// Share of the reading done at character [offset] of segment [index].
  double progressAt(int index, int offset) {
    if (length == 0 || index < 0) return 0;
    if (index >= segments.length) return 1;
    return ((_starts[index] + offset) / length).clamp(0, 1).toDouble();
  }
}
