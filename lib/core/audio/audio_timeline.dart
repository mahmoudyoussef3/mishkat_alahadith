import 'package:audio_service/audio_service.dart';

/// The progress bars the system shows for a queue: one for each part — a
/// run of consecutive entries shown under the same title, as the ayahs of
/// a surah are — spanning all of the part's entries, so a surah played ayah
/// by ayah is shown as one recitation. An ayah repeated takes its place on
/// the bar as many times as it is queued.
class AudioTimeline {
  /// The file each entry streams.
  final List<String> _urls;

  /// For each entry, the first entry of its part and the one after its last.
  final List<(int, int)> _parts;

  final Duration? Function(String url) _lengthOf;

  AudioTimeline(
    List<MediaItem> entries,
    Duration? Function(String url) lengthOf,
  ) : _urls = [for (final entry in entries) entry.id],
      _parts = _partsOf(entries),
      _lengthOf = lengthOf;

  /// The files of [entry]'s part, whose lengths make up its bar.
  Iterable<String> urlsOfPart(int entry) {
    if (!_isEntry(entry)) return const [];
    final (first, end) = _parts[entry];
    return _urls.getRange(first, end);
  }

  /// How long the bar of [entry]'s part is; null until the length of every
  /// entry in it is known.
  Duration? lengthOfPart(int entry) {
    if (!_isEntry(entry)) return null;
    final (first, end) = _parts[entry];
    return _span(first, end);
  }

  /// Where [entry] starts on its part's bar; null while the bar is unknown.
  Duration? startOf(int entry) {
    if (lengthOfPart(entry) == null) return null;
    return _span(_parts[entry].$1, entry);
  }

  /// The entry of [entry]'s part that [position] on its bar falls in, and
  /// how far into that entry; null while the bar is unknown.
  (int, Duration)? locate(int entry, Duration position) {
    if (lengthOfPart(entry) == null) return null;
    final (first, end) = _parts[entry];
    var start = Duration.zero;
    for (var i = first; i < end; i++) {
      final length = _lengthOf(_urls[i])!;
      if (position < start + length || i == end - 1) {
        final into = position - start;
        return (
          i,
          into.isNegative ? Duration.zero : (into > length ? length : into),
        );
      }
      start += length;
    }
    return null;
  }

  bool _isEntry(int entry) => entry >= 0 && entry < _urls.length;

  /// The lengths of entries [first] up to [end] added up; null if one of
  /// them is unknown.
  Duration? _span(int first, int end) {
    var total = Duration.zero;
    for (var i = first; i < end; i++) {
      final length = _lengthOf(_urls[i]);
      if (length == null) return null;
      total += length;
    }
    return total;
  }

  static List<(int, int)> _partsOf(List<MediaItem> entries) {
    final parts = List<(int, int)>.filled(entries.length, (0, 0));
    var first = 0;
    for (var i = 1; i <= entries.length; i++) {
      if (i < entries.length && entries[i].title == entries[first].title) {
        continue;
      }
      parts.fillRange(first, i, (first, i));
      first = i;
    }
    return parts;
  }
}
