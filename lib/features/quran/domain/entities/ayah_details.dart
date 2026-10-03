import 'quran_ayah.dart';
import 'quran_surah.dart';
import 'tajweed_info.dart';

class AyahDetails {
  final QuranAyah ayah;
  final QuranSurah surah;
  final List<TajweedSegment> tajweed;

  const AyahDetails({
    required this.ayah,
    required this.surah,
    required this.tajweed,
  });

  /// The rules in this ayah, each once, in the order they first occur.
  List<String> get ruleKeys {
    final seen = <String>{};
    return [
      for (final segment in tajweed)
        if (seen.add(segment.ruleKey)) segment.ruleKey,
    ];
  }
}
