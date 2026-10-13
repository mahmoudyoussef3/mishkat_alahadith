/// Where the mushaf opens, and optionally which ayah it highlights there and
/// which surah is being opened.
class MushafReaderArgs {
  final int initialPage;
  final int? highlightAyahId;
  final int? surahNumber;

  const MushafReaderArgs({
    this.initialPage = 1,
    this.highlightAyahId,
    this.surahNumber,
  });
}
