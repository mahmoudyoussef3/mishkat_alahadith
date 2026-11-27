import 'package:mishkat_almasabih/core/helpers/arabic_text_fold.dart';

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
  static String foldSpelling(String input) =>
      ArabicTextFold.foldSpelling(input);

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

      if (ArabicTextFold.isSpace(unit)) {
        // «يا» and «ها» fold to one letter with a dropped alef after it.
        final isVocative =
            wordLength == 1 &&
            pendingStart != null &&
            (lastLetter == 0x064A || lastLetter == 0x0647);
        // Letters dropped at a word's end have no letter after them to
        // belong to, so they go with the one before: «الدنيا» is marked
        // whole, its final alef included.
        if (pendingStart != null && !previousWasSpace && ends.isNotEmpty) {
          ends[ends.length - 1] = i;
        }
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
      if (ArabicTextFold.isMark(unit)) {
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

    // The same for letters dropped at the end of the text.
    if (pendingStart != null && !previousWasSpace && ends.isNotEmpty) {
      ends[ends.length - 1] = input.length;
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
      if (!ArabicTextFold.isMark(next)) return false;
    }
    return false;
  }
}
