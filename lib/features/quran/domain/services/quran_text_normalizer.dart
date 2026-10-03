/// Text folded for searching, remembering where each character came from.
class NormalizedQuranText {
  final String value;
  final List<int> _sourceStarts;
  final List<int> _sourceEnds;

  const NormalizedQuranText._(this.value, this._sourceStarts, this._sourceEnds);

  /// Maps `[start, end)` of [value] back onto the source text, widened over
  /// the letters and marks folding dropped at either edge — so a highlight
  /// covers «ٱلرَّحۡمَٰنِ» whole, wasla alef and kasra included.
  ({int start, int end}) sourceRange(int start, int end) => (
    start: _sourceStarts[start],
    end: _sourceEnds[end - 1],
  );
}

/// Folds Quranic text and typed queries down to a shared consonant skeleton.
///
/// The Uthmanic script spells many words differently from how they are typed:
/// «ٱلصَّلَوٰةَ» for «الصلاة», «ٱلۡكِتَٰبُ» for «الكتاب», «يَٰٓأَيُّهَا» for
/// «يا أيها», «ءَامَنُوٓاْ» for «آمنوا». Comparing letters one for one finds
/// none of them, so both sides are reduced to what they agree on:
///
/// * harakat, Quranic annotation signs and tatweel are dropped;
/// * every alef — bare, wasla, hamza-seated or the superscript one — and the
///   standalone hamza are dropped, since that is exactly where the two
///   spellings differ;
/// * a waw carrying a superscript alef («صلوٰة») is read as the alef it is;
/// * the small high yeh («إِبۡرَٰهِـۧمَ») is read as the yeh it stands for;
/// * yeh, waw and heh variants are merged (ى ئ → ي, ؤ → و, ة → ه);
/// * vocative «يا» and «ها» are joined to the word after them, as the mushaf
///   writes «يَٰٓأَيُّهَا» and «هَٰٓأَنتُمۡ» as one word.
///
/// The cost is that words differing only by an alef («قال», «قل») fold alike.
/// For finding a half-remembered verse, recall matters more than precision.
abstract final class QuranTextNormalizer {
  static String normalize(String input) => normalizeWithMap(input).value;

  /// A lighter fold for text already in everyday spelling, such as surah
  /// names: marks are dropped and letter variants merged, but every letter
  /// is kept, so «الناس» and «النساء» stay apart.
  static String foldSpelling(String input) {
    final buffer = StringBuffer();
    var previousWasSpace = true;
    for (final unit in input.trim().codeUnits) {
      if (_isMark(unit)) continue;
      if (_isSpace(unit)) {
        if (!previousWasSpace) buffer.writeCharCode(0x20);
        previousWasSpace = true;
        continue;
      }
      previousWasSpace = false;
      buffer.writeCharCode(switch (unit) {
        0x0671 || 0x0622 || 0x0623 || 0x0625 || 0x0672 || 0x0673 => 0x0627,
        0x0649 || 0x0626 || 0x06CC => 0x064A,
        0x0629 => 0x0647,
        0x0624 => 0x0648,
        0x06A9 => 0x0643,
        _ => unit,
      });
    }
    return buffer.toString().trimRight();
  }

  static NormalizedQuranText normalizeWithMap(String input) {
    final buffer = StringBuffer();
    final starts = <int>[];
    final ends = <int>[];

    // Source index where the dropped run before the next kept letter began.
    int? pendingStart;
    var previousWasSpace = true;
    var wordLength = 0;
    var lastLetter = 0;

    for (var i = 0; i < input.length; i++) {
      final unit = input.codeUnitAt(i);

      if (_isSpace(unit)) {
        // «يا» and «ها» fold to one letter with a dropped alef after it.
        final isVocative =
            wordLength == 1 &&
            pendingStart != null &&
            (lastLetter == 0x064A || lastLetter == 0x0647);
        pendingStart = null;
        // Collapse runs of spaces, and keep a vocative on the next word.
        if (previousWasSpace || isVocative) continue;
        previousWasSpace = true;
        wordLength = 0;
        buffer.writeCharCode(0x20);
        starts.add(i);
        ends.add(i + 1);
        continue;
      }

      // A mark belongs to the letter before it.
      if (_isMark(unit)) {
        if (ends.isNotEmpty && !previousWasSpace) ends[ends.length - 1] = i + 1;
        continue;
      }

      // A dropped letter belongs to the letter after it.
      final folded = _fold(input, i, unit);
      if (folded == null) {
        pendingStart ??= i;
        continue;
      }

      buffer.writeCharCode(folded);
      starts.add(pendingStart ?? i);
      ends.add(i + 1);
      pendingStart = null;
      previousWasSpace = false;
      wordLength++;
      lastLetter = folded;
    }

    var value = buffer.toString();
    if (value.endsWith(' ')) {
      value = value.substring(0, value.length - 1);
      starts.removeLast();
      ends.removeLast();
    }
    return NormalizedQuranText._(value, starts, ends);
  }

  /// The skeleton letter for the letter at [i], or null to drop it.
  static int? _fold(String input, int i, int unit) {
    return switch (unit) {
      // ا ٱ آ أ إ ٲ ٳ and the standalone hamza ء
      0x0627 ||
      0x0671 ||
      0x0622 ||
      0x0623 ||
      0x0625 ||
      0x0672 ||
      0x0673 => null,
      0x0621 => null,
      // و carrying a superscript alef is read as alef: «صلوٰة» → «صلاة»
      0x0648 when _carriesSuperscriptAlef(input, i) => null,
      // ى ئ ی and the small high yeh ۧ → ي
      0x0649 || 0x0626 || 0x06CC || 0x06E7 => 0x064A,
      // ة → ه
      0x0629 => 0x0647,
      // ؤ → و
      0x0624 => 0x0648,
      // ک → ك
      0x06A9 => 0x0643,
      _ => unit,
    };
  }

  /// Whether a superscript alef sits on the letter at [i], past its harakat.
  static bool _carriesSuperscriptAlef(String input, int i) {
    for (var k = i + 1; k < input.length; k++) {
      final next = input.codeUnitAt(k);
      if (next == 0x0670) return true;
      if (!_isMark(next)) return false;
    }
    return false;
  }

  static bool _isMark(int unit) =>
      unit != 0x06E7 && // the small high yeh is a letter; see _fold
      ((unit >= 0x0610 && unit <= 0x061A) || // honorific and small signs
          (unit >= 0x064B && unit <= 0x065F) || // harakat, tanween, shadda
          unit == 0x0670 || // superscript alef
          unit == 0x0640 || // tatweel
          (unit >= 0x06D6 && unit <= 0x06ED) || // Quranic annotation signs
          (unit >= 0x08D3 && unit <= 0x08FF) || // extended Quranic marks
          (unit >= 0x200B && unit <= 0x200F) || // zero-width marks
          (unit >= 0x2066 && unit <= 0x2069)); // directional isolates

  static bool _isSpace(int unit) =>
      unit == 0x20 ||
      unit == 0x09 ||
      unit == 0x0A ||
      unit == 0x0D ||
      unit == 0xA0;
}
