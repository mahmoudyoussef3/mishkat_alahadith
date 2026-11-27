import 'quran_ayah.dart';
import 'quran_edition.dart';
import 'quran_surah.dart';

/// One ayah's passage in a tafsir or translation.
class EditionText {
  final QuranEdition edition;
  final String text;

  const EditionText({required this.edition, required this.text});
}

/// A passage of an edition, and the ayah it belongs to.
class AyahEditionText {
  /// 1‥6236, in mushaf order.
  final int ayahId;
  final EditionText text;

  const AyahEditionText({required this.ayahId, required this.text});
}

/// The tafsir and translation of one ayah.
class AyahCommentary {
  final int ayahId;

  /// Null when the service had no passage for the tafsir asked for.
  final EditionText? tafsir;

  /// Null when no translation was asked for, or none came back.
  final EditionText? translation;

  const AyahCommentary({required this.ayahId, this.tafsir, this.translation});

  bool get isEmpty => tafsir == null && translation == null;
}

/// An ayah of the bundled mushaf with its commentary from the service.
class CommentedAyah {
  final QuranAyah ayah;
  final QuranSurah surah;
  final AyahCommentary commentary;

  const CommentedAyah({
    required this.ayah,
    required this.surah,
    required this.commentary,
  });
}

/// A stretch of a surah's ayahs with their commentary, for reading the
/// tafsir of a surah a page at a time.
class SurahCommentaryPage {
  final QuranSurah surah;
  final List<CommentedAyah> ayahs;

  /// Where the page starts in the surah, from 0.
  final int offset;

  /// Where the page after it starts: past every ayah this one asked for,
  /// including any that had nothing to show — so pages never overlap, and
  /// an ayah without a passage is never asked for again.
  final int nextOffset;

  const SurahCommentaryPage({
    required this.surah,
    required this.ayahs,
    required this.offset,
    required this.nextOffset,
  });

  bool get hasMore => nextOffset < surah.ayahCount;
}
