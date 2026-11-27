/// Folds Arabic text in everyday spelling for matching what a reader types
/// against what is written, harakat and letter variants aside.
abstract final class ArabicTextFold {
  /// Marks are dropped and letter variants merged, but every letter is kept,
  /// so «الناس» and «النساء» stay apart while «الصَّبَاحِ» matches «الصباح».
  static String foldSpelling(String input) {
    final buffer = StringBuffer();
    var previousWasSpace = true;
    for (final unit in input.trim().codeUnits) {
      if (isMark(unit)) continue;
      if (isSpace(unit)) {
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

  /// Harakat, Quranic signs, tatweel and invisible marks: everything that
  /// sits on a letter rather than being one.
  static bool isMark(int unit) =>
      unit != 0x06E7 && // the small high yeh stands for a letter
      ((unit >= 0x0610 && unit <= 0x061A) || // honorific and small signs
          (unit >= 0x064B && unit <= 0x065F) || // harakat, tanween, shadda
          unit == 0x0670 || // superscript alef
          unit == 0x0640 || // tatweel
          (unit >= 0x06D6 && unit <= 0x06ED) || // Quranic annotation signs
          (unit >= 0x08D3 && unit <= 0x08FF) || // extended Quranic marks
          (unit >= 0x200B && unit <= 0x200F) || // zero-width marks
          (unit >= 0x2066 && unit <= 0x2069)); // directional isolates

  static bool isSpace(int unit) =>
      unit == 0x20 ||
      unit == 0x09 ||
      unit == 0x0A ||
      unit == 0x0D ||
      unit == 0xA0;
}
