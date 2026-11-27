import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_hizb_quarter.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'quran_index_row.dart';

/// One quarter of a hizb: «ربع الحزب ٣», where it begins, and its page.
class HizbQuarterTile extends StatelessWidget {
  final QuranHizbQuarter quarter;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  /// Recites the quarter; no listen button without it.
  final VoidCallback? onListen;

  const HizbQuarterTile({
    super.key,
    required this.quarter,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
    this.isCurrent = false,
    this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    final title = hizbQuarterTitle(quarter.number);
    return QuranIndexRow(
      isFirst: isFirst,
      isLast: isLast,
      onTap: onTap,
      leading: QuranIndexWell(
        label: hizbQuarterMark(quarter),
        highlighted: isCurrent,
      ),
      title: title,
      subtitle: [
        'سورة ${quarter.surahName}',
        'الآية ${toArabicNumerals(quarter.ayahNumber)}',
        if (isCurrent) 'تقرأ الآن',
      ].join(' · '),
      trailing: QuranRowTrailing(
        pageLabel: 'ص ${toArabicNumerals(quarter.page)}',
        onListen: onListen,
        listenLabel: 'الاستماع إلى $title',
      ),
    );
  }
}
