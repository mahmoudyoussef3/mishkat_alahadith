import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/dashed_divider.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_text.dart';
import 'package:shimmer/shimmer.dart';

/// A hadith in a chapter: its number and grade, the chain of narrators in
/// a quiet tone above the words of the hadith, and its sub-heading.
class ChapterHadithTile extends StatelessWidget {
  const ChapterHadithTile({
    super.key,
    required this.number,
    required this.parts,
    required this.onTap,
    required this.onShare,
    this.grade,
    this.heading,
    this.showIsnad = true,
  });

  final String? number;
  final HadithTextParts parts;
  final HadithGrade? grade;

  /// The sub-chapter ("باب") the hadith sits under, when known.
  final String? heading;

  /// False hides the chain of narrators ("المتن فقط").
  final bool showIsnad;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final number = this.number;
    final grade = this.grade;
    final isnad = parts.isnad;
    final heading = this.heading?.trim();
    final hasIsnad = isnad != null && showIsnad;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Material(
        color: ColorsManager.cardBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
          side: BorderSide(color: ColorsManager.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 10.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (number != null && number.isNotEmpty) ...[
                      _NumberChip(number: number),
                      SizedBox(width: 6.w),
                    ],
                    if (grade != null) GradeBadge(grade: grade),
                    const Spacer(),
                    IconButton(
                      tooltip: 'مشاركة',
                      onPressed: onShare,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.share_rounded,
                        size: 21.r,
                        color: ColorsManager.gray,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 4.h),
                      if (hasIsnad) ...[
                        HadithText(
                          isnad,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.readingMedium.copyWith(
                            fontSize: 14.sp,
                            height: 1.85,
                            color: ColorsManager.secondaryText,
                          ),
                        ),
                        SizedBox(height: 6.h),
                      ],
                      HadithText(
                        parts.matn,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.hadithPreview.copyWith(
                          height: 1.95,
                          fontWeight:
                              isnad != null ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      const DashedDivider(),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              heading ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.caption,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text('اقرأ مع الشرح', style: TextStyles.actionLabel),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.r,
                            color: ColorsManager.purpleText,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberChip extends StatelessWidget {
  const _NumberChip({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 30.r),
      height: 26.r,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorsManager.primaryText,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Text(
        toArabicDigits(number),
        style: TextStyles.chipLabel.copyWith(
          fontWeight: FontWeight.w800,
          color: ColorsManager.secondaryBackground,
        ),
      ),
    );
  }
}

/// Placeholder for [ChapterHadithTile] while a chapter loads.
class ChapterHadithTileShimmer extends StatelessWidget {
  const ChapterHadithTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final block = ColorsManager.shimmerBase;
    Widget line(double widthFactor, double height) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: block,
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 6.h),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Shimmer.fromColors(
        baseColor: ColorsManager.shimmerBase,
        highlightColor: ColorsManager.shimmerHighlight,
        child: Column(
          children: [
            line(0.3, 22.h),
            line(0.9, 12.h),
            line(1, 18.h),
            line(1, 18.h),
            line(0.6, 18.h),
          ],
        ),
      ),
    );
  }
}
