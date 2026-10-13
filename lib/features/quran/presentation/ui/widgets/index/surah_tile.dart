import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'quran_index_row.dart';

class SurahTile extends StatelessWidget {
  final QuranSurah surah;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const SurahTile({
    super.key,
    required this.surah,
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
        label: toArabicNumerals(surah.number),
        highlighted: isCurrent,
      ),
      title: surah.nameArabic,
      subtitle: [
        ltrIsolate(surah.nameEnglish),
        arabicCount(surah.ayahCount, ArabicNoun.ayah),
        if (isCurrent) 'تقرأ الآن',
      ].join(' · '),
      trailing: QuranPageLabel('ص ${toArabicNumerals(surah.startPage)}'),
    );
  }
}
