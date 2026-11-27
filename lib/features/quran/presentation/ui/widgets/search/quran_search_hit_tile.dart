import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_search_results.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// One matching ayah, with every occurrence of the query washed in gold.
class QuranSearchHitTile extends StatelessWidget {
  final QuranSearchHit hit;
  final VoidCallback onTap;

  const QuranSearchHitTile({super.key, required this.hit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ayah = hit.ayah;
    return Material(
      color: ColorsManager.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppBadge.tag(
                        '${hit.surahName} · ${toArabicNumerals(ayah.number)}',
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'ص ${toArabicNumerals(ayah.page)}',
                    style: TextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text.rich(_highlighted(), textAlign: TextAlign.start),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _highlighted() {
    final mark = TextStyle(
      backgroundColor: ColorsManager.primaryGold.withValues(alpha: 0.28),
    );
    return styledRanges(
      text: hit.ayah.text,
      base: QuranTextStyles.mushafText(
        color: ColorsManager.primaryText,
        size: 20.sp,
      ),
      ranges: [
        for (final match in hit.matches)
          (start: match.start, end: match.end, style: mark),
      ],
    );
  }
}
