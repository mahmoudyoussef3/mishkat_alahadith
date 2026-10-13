import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_bookmark.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'quran_index_row.dart';

class QuranBookmarkTile extends StatelessWidget {
  final QuranBookmark bookmark;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const QuranBookmarkTile({
    super.key,
    required this.bookmark,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final ayahNumber = bookmark.ayahNumber;
    final isPage = bookmark.isPageBookmark;

    return QuranIndexRow(
      isFirst: isFirst,
      isLast: isLast,
      onTap: onTap,
      leading: QuranIndexWell(
        icon: isPage ? Icons.bookmark_rounded : Icons.format_quote_rounded,
        background: isPage ? palette.goldSoft : palette.primarySoft,
        foreground: isPage ? palette.goldInk : palette.purpleText,
      ),
      title:
          ayahNumber == null
              ? 'سورة ${bookmark.surahName}'
              : 'سورة ${bookmark.surahName} · '
                  'الآية ${toArabicNumerals(ayahNumber)}',
      subtitle: [
        isPage ? 'علامة صفحة' : 'علامة آية',
        'الصفحة ${toArabicNumerals(bookmark.page)}',
        formatShortDate(bookmark.createdAt),
      ].join(' · '),
      trailing: IconButton(
        tooltip: 'حذف العلامة',
        onPressed: onDelete,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.delete_outline_rounded,
          size: 22.r,
          color: palette.gray,
        ),
      ),
    );
  }
}
