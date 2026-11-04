/// Which chapter to open, and optionally the zikr to open it at.
class AzkarReaderArgs {
  final int categoryId;
  final int? zikrId;

  const AzkarReaderArgs({required this.categoryId, this.zikrId});
}
