import 'arabic_digits.dart';

/// The forms an Arabic noun takes after a number.
class ArabicNoun {
  /// With 1, or 0, 100, 101, 102 … ("حديث").
  final String singular;

  /// With exactly 2 ("حديثان").
  final String dual;

  /// With 3 to 10 ("أحاديث").
  final String plural;

  /// With 11 to 99 ("حديثاً").
  final String accusative;

  const ArabicNoun({
    required this.singular,
    required this.dual,
    required this.plural,
    required this.accusative,
  });

  static const hadith = ArabicNoun(
    singular: 'حديث',
    dual: 'حديثان',
    plural: 'أحاديث',
    accusative: 'حديثاً',
  );

  static const book = ArabicNoun(
    singular: 'كتاب',
    dual: 'كتابان',
    plural: 'كتب',
    accusative: 'كتاباً',
  );

  static const chapter = ArabicNoun(
    singular: 'باب',
    dual: 'بابان',
    plural: 'أبواب',
    accusative: 'باباً',
  );

  static const ayah = ArabicNoun(
    singular: 'آية',
    dual: 'آيتان',
    plural: 'آيات',
    accusative: 'آية',
  );

  static const surah = ArabicNoun(
    singular: 'سورة',
    dual: 'سورتان',
    plural: 'سور',
    accusative: 'سورة',
  );

  static const juz = ArabicNoun(
    singular: 'جزء',
    dual: 'جزءان',
    plural: 'أجزاء',
    accusative: 'جزءاً',
  );

  static const page = ArabicNoun(
    singular: 'صفحة',
    dual: 'صفحتان',
    plural: 'صفحات',
    accusative: 'صفحة',
  );

  /// A ruling, such as a rule of tajweed ("٢٦ حكماً").
  static const ruling = ArabicNoun(
    singular: 'حكم',
    dual: 'حكمان',
    plural: 'أحكام',
    accusative: 'حكماً',
  );

  /// A place in the text where something occurs ("١٢ موضعاً").
  static const occurrence = ArabicNoun(
    singular: 'موضع',
    dual: 'موضعان',
    plural: 'مواضع',
    accusative: 'موضعاً',
  );

  /// Genitive dual, for use after a preposition ("بعد دقيقتين").
  static const minute = ArabicNoun(
    singular: 'دقيقة',
    dual: 'دقيقتين',
    plural: 'دقائق',
    accusative: 'دقيقة',
  );

  /// Genitive dual, for use after a preposition ("بعد ساعتين").
  static const hour = ArabicNoun(
    singular: 'ساعة',
    dual: 'ساعتين',
    plural: 'ساعات',
    accusative: 'ساعة',
  );
}

/// [count] followed by [noun] in the grammatical form the number requires,
/// with Arabic-Indic digits: 1 → "حديث", 2 → "حديثان", 9 → "٩ أحاديث",
/// 20 → "٢٠ حديثاً", 7276 → "٧٢٧٦ حديثاً".
String arabicCount(int count, ArabicNoun noun) {
  if (count == 1) return noun.singular;
  if (count == 2) return noun.dual;

  final digits = toArabicDigits('$count');
  final lastTwo = count % 100;
  if (lastTwo >= 3 && lastTwo <= 10) return '$digits ${noun.plural}';
  if (lastTwo >= 11) return '$digits ${noun.accusative}';
  return '$digits ${noun.singular}';
}

/// A rounded-down hadith total for headlines: 41234 → "أكثر من ٤١ ألف حديث",
/// 950 → "٩٥٠ حديثاً".
String approximateHadithCount(int count) {
  final thousands = count ~/ 1000;
  if (thousands == 0) return arabicCount(count, ArabicNoun.hadith);

  final amount = switch (thousands) {
    1 => 'ألف',
    2 => 'ألفي',
    >= 3 && <= 10 => '${toArabicDigits('$thousands')} آلاف',
    _ => '${toArabicDigits('$thousands')} ألف',
  };
  return 'أكثر من $amount حديث';
}
