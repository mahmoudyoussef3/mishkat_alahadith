/// Authenticity grade of a hadith, read from the free-form grade text the
/// API returns in Arabic or English ("صحيح", "Sahih", "حسن صحيح", "Da'if").
enum HadithGrade {
  sahih('صحيح'),
  hasan('حسن'),
  daif('ضعيف');

  const HadithGrade(this.arabicLabel);

  final String arabicLabel;

  /// The grade [raw] names, or null when it is empty or not a grade (some
  /// screens pass a hadith's position in this field).
  ///
  /// Weak grades are checked first so "ضعيف" wins over any other word in
  /// the text, and "sahih" before "hasan" so Tirmidhi's "حسن صحيح" reads as
  /// authentic.
  static HadithGrade? tryParse(String? raw) {
    final text = raw?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return null;
    if (_containsAny(text, const [
      'ضعيف',
      'موضوع',
      'منكر',
      'daif',
      "da'if",
      'da`if',
      'weak',
      'fabricated',
    ])) {
      return HadithGrade.daif;
    }
    if (_containsAny(text, const ['صحيح', 'sahih', 'saheeh', 'authentic'])) {
      return HadithGrade.sahih;
    }
    if (_containsAny(text, const ['حسن', 'hasan', 'good'])) {
      return HadithGrade.hasan;
    }
    return null;
  }

  static bool _containsAny(String text, List<String> words) =>
      words.any(text.contains);
}
