/// A hadith's chain of narrators (isnad) and its text (matn).
class HadithTextParts {
  /// Null when the text has no recognisable chain before the quoted words.
  final String? isnad;
  final String matn;

  const HadithTextParts({this.isnad, required this.matn});

  /// A chain shorter than this is a lead-in ("قال:"), not an isnad.
  static const _minIsnadLength = 24;

  static const _rlm = '‏';

  /// Splits [text] where the quoted words begin: at the first «, or at the
  /// first straight quote, which is how the Sunnah.com texts mark them.
  /// Straight quotes become «» and direction marks are dropped. When no
  /// quote follows a chain, the whole text is the matn.
  factory HadithTextParts.split(String text) {
    final clean = text.trim();
    final guillemet = clean.indexOf('«');
    final straight = clean.indexOf('"');
    final open = switch ((guillemet, straight)) {
      (-1, final s) => s,
      (final g, -1) => g,
      (final g, final s) => g < s ? g : s,
    };

    if (open < _minIsnadLength) {
      return HadithTextParts(matn: _typeset(clean));
    }
    final isnad = _typeset(clean.substring(0, open));
    final matn = _typeset(clean.substring(open));
    if (matn.length < 2) return HadithTextParts(matn: _typeset(clean));
    return HadithTextParts(isnad: isnad, matn: matn);
  }

  /// The full text with typographic quotes, for places that show it whole.
  static String typeset(String text) => _typeset(text.trim());

  /// Turns paired straight quotes into «», removes direction marks and
  /// collapses the spaces they leave behind.
  static String _typeset(String text) {
    final buffer = StringBuffer();
    var opening = true;
    // Code units suffice: every character handled here is in the BMP.
    for (final char in text.split('')) {
      if (char == _rlm) continue;
      if (char == '"') {
        buffer.write(opening ? '«' : '»');
        opening = !opening;
      } else {
        buffer.write(char);
      }
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('« ', '«')
        .replaceAll(' »', '»')
        .trim();
  }
}
