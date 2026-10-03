import 'quran_surah.dart';

class QuranPageInfo {
  final int page;
  final int juz;

  /// Every surah with at least one ayah on the page, in reading order.
  final List<QuranSurah> surahs;

  final int firstAyahId;
  final int lastAyahId;

  const QuranPageInfo({
    required this.page,
    required this.juz,
    required this.surahs,
    required this.firstAyahId,
    required this.lastAyahId,
  });

  QuranSurah get openingSurah => surahs.first;
}
