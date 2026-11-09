/// The surah whose tafsir is read, and the ayah the reading starts at.
class SurahTafsirArgs {
  final int surahNumber;
  final int startAyah;

  const SurahTafsirArgs({required this.surahNumber, this.startAyah = 1});
}
