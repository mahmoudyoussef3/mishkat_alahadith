import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';

/// Where the mushaf opens, and optionally which ayah it highlights there,
/// which surah is being opened, and what to start reciting.
class MushafReaderArgs {
  final int initialPage;
  final int? highlightAyahId;
  final int? surahNumber;

  /// Started as soon as the mushaf opens.
  final RecitationRequest? recitation;

  const MushafReaderArgs({
    this.initialPage = 1,
    this.highlightAyahId,
    this.surahNumber,
    this.recitation,
  });
}
