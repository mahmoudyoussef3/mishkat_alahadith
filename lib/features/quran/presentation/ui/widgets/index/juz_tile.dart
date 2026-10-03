import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_juz.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'index_tile_frame.dart';

class JuzTile extends StatelessWidget {
  final QuranJuz juz;
  final QuranSurfaceColors colors;
  final bool isCurrent;
  final VoidCallback onTap;

  const JuzTile({
    super.key,
    required this.juz,
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
        label: toArabicNumerals(juz.number),
        colors: colors,
      ),
      title: Text(
        juzTitle(juz.number),
        style: QuranTextStyles.surahName(colors.title),
      ),
      subtitle:
          'يبدأ من سورة ${juz.startSurahName} · الآية '
          '${toArabicNumerals(juz.startAyahNumber)}',
      trailing: Text(
        'ص ${toArabicNumerals(juz.startPage)}',
        style: QuranTextStyles.tileTrailing(colors.accent),
      ),
    );
  }
}
