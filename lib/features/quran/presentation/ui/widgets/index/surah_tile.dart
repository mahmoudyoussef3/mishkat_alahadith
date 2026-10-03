import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'index_tile_frame.dart';

class SurahTile extends StatelessWidget {
  final QuranSurah surah;
  final QuranSurfaceColors colors;
  final bool isCurrent;
  final VoidCallback onTap;

  const SurahTile({
    super.key,
    required this.surah,
    required this.colors,
    required this.onTap,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return IndexTileFrame(
      colors: colors,
      isCurrent: isCurrent,
      onTap: onTap,
      leading: IndexNumberBadge(
        label: toArabicNumerals(surah.number),
        colors: colors,
      ),
      title: Text(
        'سورة ${surah.nameArabic}',
        style: QuranTextStyles.surahName(colors.title),
      ),
      subtitle:
          '${ltrIsolate(surah.nameEnglish)} · ${toArabicNumerals(surah.ayahCount)} آية',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ص ${toArabicNumerals(surah.startPage)}',
            style: QuranTextStyles.tileTrailing(colors.accent),
          ),
          if (isCurrent)
            Text('تقرأ الآن', style: QuranTextStyles.tileMeta(colors.accent)),
        ],
      ),
    );
  }
}
