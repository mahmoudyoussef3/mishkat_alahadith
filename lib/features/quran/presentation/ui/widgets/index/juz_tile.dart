import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_juz.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'quran_index_row.dart';

class JuzTile extends StatelessWidget {
  final QuranJuz juz;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  /// Recites the juz; no listen button without it.
  final VoidCallback? onListen;

  const JuzTile({
    super.key,
    required this.juz,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
    this.isCurrent = false,
    this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    return QuranIndexRow(
      isFirst: isFirst,
      isLast: isLast,
      onTap: onTap,
      leading: QuranIndexWell(
        label: toArabicNumerals(juz.number),
        highlighted: isCurrent,
      ),
      title: juzTitle(juz.number),
      subtitle: [
        'من سورة ${juz.startSurahName}',
        'الآية ${toArabicNumerals(juz.startAyahNumber)}',
        if (isCurrent) 'تقرأ الآن',
      ].join(' · '),
      trailing: QuranRowTrailing(
        pageLabel: 'ص ${toArabicNumerals(juz.startPage)}',
        onListen: onListen,
        listenLabel: 'الاستماع إلى ${juzTitle(juz.number)}',
      ),
    );
  }
}
