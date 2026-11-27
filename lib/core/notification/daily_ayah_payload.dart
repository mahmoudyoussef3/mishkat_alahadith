import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';

/// Where a tap on "آية اليوم" — its notification or its home screen widget —
/// opens the mushaf.
///
/// Carried as a string, `daily_ayah:<ayahId>:<page>:<surah>`, so the
/// notification and the native widget can hand it back as is, and the reader
/// opens without first looking the ayah up.
class DailyAyahPayload {
  static const String _prefix = 'daily_ayah';

  /// 1‥6236, in mushaf order.
  final int ayahId;

  /// The mushaf page the ayah is on, 1‥604.
  final int page;
  final int surahNumber;

  const DailyAyahPayload({
    required this.ayahId,
    required this.page,
    required this.surahNumber,
  });

  String encode() => '$_prefix:$ayahId:$page:$surahNumber';

  /// The payload [value] encodes, or null when it is anything else — such as
  /// the payload of another kind of notification.
  static DailyAyahPayload? tryParse(String? value) {
    final parts = value?.split(':');
    if (parts == null || parts.length != 4 || parts.first != _prefix) {
      return null;
    }
    final ayahId = int.tryParse(parts[1]);
    final page = int.tryParse(parts[2]);
    final surahNumber = int.tryParse(parts[3]);
    if (ayahId == null || page == null || surahNumber == null) return null;
    // It also arrives as an extra on the exported activity, which any app
    // can start, so it must name a real place in the mushaf.
    if (ayahId < 1 || ayahId > QuranMetrics.ayahCount) return null;
    if (!QuranMetrics.isValidPage(page)) return null;
    if (surahNumber < 1 || surahNumber > QuranMetrics.surahCount) return null;
    return DailyAyahPayload(
      ayahId: ayahId,
      page: page,
      surahNumber: surahNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DailyAyahPayload &&
      other.ayahId == ayahId &&
      other.page == page &&
      other.surahNumber == surahNumber;

  @override
  int get hashCode => Object.hash(ayahId, page, surahNumber);
}
