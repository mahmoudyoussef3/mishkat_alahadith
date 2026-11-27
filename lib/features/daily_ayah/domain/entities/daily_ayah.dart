import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';

/// The ayah featured on one calendar day.
class DailyAyah {
  /// Local midnight of the day it is featured on.
  final DateTime day;
  final QuranAyah ayah;
  final QuranSurah surah;

  const DailyAyah({required this.day, required this.ayah, required this.surah});
}

/// A [DailyAyah] to be announced at [fireAt].
typedef DailyAyahReminder = ({DateTime fireAt, DailyAyah dailyAyah});
