import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_bookmark.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'index_tile_frame.dart';

class QuranBookmarkTile extends StatelessWidget {
  final QuranBookmark bookmark;
  final QuranSurfaceColors colors;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const QuranBookmarkTile({
    super.key,
    required this.bookmark,
    required this.colors,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ayahNumber = bookmark.ayahNumber;
    final title =
        ayahNumber == null
            ? 'سورة ${bookmark.surahName}'
            : 'سورة ${bookmark.surahName} · الآية ${toArabicNumerals(ayahNumber)}';
    final kind = bookmark.isPageBookmark ? 'علامة صفحة' : 'علامة آية';

    return IndexTileFrame(
      colors: colors,
      onTap: onTap,
      leading: SizedBox(
        width: 42.r,
        height: 42.r,
        child: Icon(
          bookmark.isPageBookmark
              ? Icons.bookmark_rounded
              : Icons.format_quote_rounded,
          color: colors.mushaf.gold,
          size: 26.sp,
        ),
      ),
      title: Text(title, style: QuranTextStyles.surahName(colors.title)),
      subtitle:
          '$kind · الصفحة ${toArabicNumerals(bookmark.page)} · '
          '${formatShortDate(bookmark.createdAt)}',
      trailing: IconButton(
        tooltip: 'حذف العلامة',
        onPressed: onDelete,
        icon: Icon(Icons.delete_outline_rounded, color: colors.subtitle),
      ),
    );
  }
}
