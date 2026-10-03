/// Where the mushaf opens, and optionally which ayah it highlights there.
class MushafReaderArgs {
  final int initialPage;
  final int? highlightAyahId;

  const MushafReaderArgs({this.initialPage = 1, this.highlightAyahId});
}
