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

  const JuzTile({
    super.key,
    required this.juz,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
    this.isCurrent = false,
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
      trailing: QuranPageLabel('ص ${toArabicNumerals(juz.startPage)}'),
    );
  }
}
