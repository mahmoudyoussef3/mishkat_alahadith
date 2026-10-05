/// Text prepared for a speech engine, remembering where each character came
/// from in the text on screen.
class SpokenText {
  final String text;
  final List<int> sourceStarts;
  final List<int> sourceEnds;

  const SpokenText(this.text, this.sourceStarts, this.sourceEnds);

  bool get isEmpty => text.isEmpty;
}

/// Turns hadith text as displayed into text an Arabic voice reads well.
///
/// Engines spell out or stumble over what is only typography: «» and
/// brackets, tatweel, direction marks, and honorific ligatures such as ﷺ
/// that most voices skip. Those are dropped or written out, and every
/// spoken character keeps the source range it stands for, so the engine's
/// word positions can be shown on the original text. Harakat are kept:
/// they guide the voice's pronunciation.
abstract final class SpokenArabic {
  /// Ligatures read as the words they abbreviate.
  static const Map<int, String> _ligatures = {
    0xFDFA: 'صلى الله عليه وسلم', // ﷺ
    0xFDFB: 'جل جلاله', // ﷻ
    0xFDF2: 'الله', // ﷲ
    0xFDFD: 'بسم الله الرحمن الرحيم', // ﷽
  };

  /// Bracketed abbreviations of honorifics.
  static const Map<String, String> _abbreviations = {
    '(ص)': 'صلى الله عليه وسلم',
    '(رض)': 'رضي الله عنه',
  };

  /// Marks that only shape the text and separate nothing.
  static bool _isDropped(int unit) =>
      unit == 0x0640 || // tatweel
      unit == 0x061C || // Arabic letter mark
      unit == 0xFEFF ||
      (unit >= 0x200B && unit <= 0x200F) ||
      (unit >= 0x202A && unit <= 0x202E) ||
      (unit >= 0x2066 && unit <= 0x2069);

  /// Quotes, brackets and markup: not read, but they separate words.
  static final Set<int> _separators = '«»"“”„‹›()[]{}﴾﴿<>*#_~|`'.codeUnits.toSet();

  static bool _isLineBreak(int unit) =>
      unit == 0x0A || unit == 0x0D || unit == 0x2028 || unit == 0x2029;

  static bool _isSpace(int unit) =>
      unit == 0x20 ||
      unit == 0x09 ||
      unit == 0xA0 ||
      unit == 0x3000 ||
      (unit >= 0x2000 && unit <= 0x200A) ||
      _isLineBreak(unit);

  static bool _endsSentence(int unit) =>
      unit == 0x2E || // .
      unit == 0x21 || // !
      unit == 0x3F || // ?
      unit == 0x061F || // ؟
      unit == 0x2026 || // …
      unit == 0x061B || // ؛
      _isLineBreak(unit);

  static bool _endsClause(int unit) =>
      unit == 0x060C || // ،
      unit == 0x2C || // ,
      unit == 0x3B || // ;
      unit == 0x3A; // :

  /// The speakable form of `source[start, end)`, with runs of spaces
  /// collapsed and the ends trimmed. A line break is kept as one, since
  /// engines pause on it.
  static SpokenText from(String source, {int start = 0, int? end}) {
    final stop = end ?? source.length;
    final out = StringBuffer();
    final starts = <int>[];
    final ends = <int>[];
    var breakAt = -1;
    var lineBreak = false;

    void markBreak(int at, {bool line = false}) {
      if (breakAt < 0) breakAt = at;
      lineBreak = lineBreak || line;
    }

    void put(String text, int from, int to) {
      if (breakAt >= 0 && out.isNotEmpty) {
        out.write(lineBreak ? '\n' : ' ');
        starts.add(breakAt);
        ends.add(breakAt + 1);
      }
      breakAt = -1;
      lineBreak = false;
      out.write(text);
      for (var k = 0; k < text.length; k++) {
        starts.add(from);
        ends.add(to);
      }
    }

    var i = start;
    scan:
    while (i < stop) {
      for (final MapEntry(key: pattern, value: words) in _abbreviations.entries) {
        if (i + pattern.length <= stop && source.startsWith(pattern, i)) {
          markBreak(i);
          put(words, i, i + pattern.length);
          markBreak(i + pattern.length - 1);
          i += pattern.length;
          continue scan;
        }
      }

      final unit = source.codeUnitAt(i);
      final ligature = _ligatures[unit];
      if (_isDropped(unit)) {
        // Nothing to say.
      } else if (_isSpace(unit)) {
        markBreak(i, line: _isLineBreak(unit));
      } else if (_separators.contains(unit)) {
        markBreak(i);
      } else if (ligature != null) {
        markBreak(i);
        put(ligature, i, i + 1);
        markBreak(i);
      } else {
        put(source[i], i, i + 1);
      }
      i++;
    }
    return SpokenText(out.toString(), starts, ends);
  }

  /// Splits [source] into ranges of at most [maxLength] characters, cutting
  /// after a sentence where possible, then after a clause, then between
  /// words. Engines cap one utterance, and shorter parts can be skipped.
  static List<({int start, int end})> chunks(
    String source, {
    int maxLength = 600,
  }) {
    assert(maxLength > 0);
    final ranges = <({int start, int end})>[];
    final minLength = maxLength ~/ 3;
    var start = _skipSpaces(source, 0);
    while (start < source.length) {
      var end = source.length;
      if (end - start > maxLength) {
        final limit = start + maxLength;
        final earliest = start + minLength;
        end =
            _lastCut(source, earliest, limit, _endsSentence) ??
            _lastCut(source, earliest, limit, _endsClause) ??
            _lastCut(source, earliest, limit, _isSpace) ??
            limit;
      }
      ranges.add((start: start, end: end));
      start = _skipSpaces(source, end);
    }
    return ranges;
  }

  /// Index just after the last character in `[earliest, limit)` matching
  /// [test], or null.
  static int? _lastCut(
    String source,
    int earliest,
    int limit,
    bool Function(int unit) test,
  ) {
    for (var i = limit - 1; i >= earliest; i--) {
      if (test(source.codeUnitAt(i))) return i + 1;
    }
    return null;
  }

  static int _skipSpaces(String source, int from) {
    var i = from;
    while (i < source.length && _isSpace(source.codeUnitAt(i))) {
      i++;
    }
    return i;
  }
}
