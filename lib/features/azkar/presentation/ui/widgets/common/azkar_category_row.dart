import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';

import 'azkar_progress_badge.dart';

/// One chapter in a list: its number, title, how far today's count has got,
/// and a star to keep it among the favourites. [isFirst] and [isLast] round
/// the ink to the card the rows share.
class AzkarCategoryRow extends StatelessWidget {
  const AzkarCategoryRow({
    super.key,
    required this.category,
    required this.number,
    required this.progress,
    required this.isFavorite,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    this.onToggleFavorite,
  });

  final AzkarCategory category;
  final int number;
  final AzkarCategoryProgress progress;
  final bool isFavorite;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  /// Null hides the star.
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final radius = Radius.circular(20.r);
    final translatedTitle = category.translatedTitle;
    final onToggleFavorite = this.onToggleFavorite;

    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: palette.lightGray),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? radius : Radius.zero,
              bottom: isLast ? radius : Radius.zero,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 6.w, 12.h),
              child: Row(
                children: [
                  AzkarProgressBadge(
                    progress: progress,
                    label: toArabicDigits('$number'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: palette.primaryText,
                          ),
                        ),
                        if (translatedTitle != null)
                          Text(
                            translatedTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: TextStyles.caption.copyWith(
                              color: palette.secondaryText,
                            ),
                          ),
                        Text(
                          _status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                progress.isComplete
                                    ? palette.success
                                    : progress.isStarted
                                    ? palette.goldInk
                                    : palette.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onToggleFavorite != null)
                    IconButton(
                      tooltip:
                          isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isFavorite ? palette.primaryGold : palette.gray,
                        size: 24.r,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get _status {
    final size = arabicCount(category.azkar.length, ArabicNoun.zikr);
    if (progress.isComplete) return '$size · أتممته اليوم';
    if (progress.isStarted) {
      return 'أتممت ${toArabicDigits('${progress.completedAzkar}')} من '
          '${toArabicDigits('${progress.totalAzkar}')}';
    }
    return size;
  }
}
