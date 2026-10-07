import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/dashed_divider.dart';

/// Hadith preview card used by every hadith list: topic and grade badges,
/// up to four lines of the text in Amiri, and the source with a read cue.
class ChapterAhadithCard extends StatelessWidget {
  const ChapterAhadithCard({
    super.key,
    required this.number,
    required this.text,
    this.narrator,
    this.grade,
    this.reference,
    this.bookName,
    this.hadithCategory,
  });

  final String number;
  final String text;
  final String? narrator;

  /// A grade ("صحيح") or, on some lists, the hadith's position.
  final String? grade;
  final String? reference;
  final String? bookName;
  final String? hadithCategory;

  @override
  Widget build(BuildContext context) {
    final parsedGrade = HadithGrade.tryParse(grade);
    final position = parsedGrade == null ? _nonEmpty(grade) : null;
    final category = _nonEmpty(hadithCategory);
    final source = _source();
    final hasBadges =
        category != null || parsedGrade != null || position != null;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 20.w),
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasBadges) ...[
            Row(
              children: [
                if (category != null) Flexible(child: AppBadge.tag(category)),
                if (parsedGrade != null) ...[
                  SizedBox(width: 6.w),
                  GradeBadge(grade: parsedGrade),
                ],
                if (position != null) ...[
                  SizedBox(width: 6.w),
                  AppBadge(
                    label: position,
                    background: ColorsManager.lightGray,
                    foreground: ColorsManager.secondaryText,
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
          ],
          if (text.isNotEmpty)
            Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.hadithPreview,
            ),
          SizedBox(height: 10.h),
          const DashedDivider(),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.caption,
                ),
              ),
              SizedBox(width: 10.w),
              Text('اقرأ', style: TextStyles.actionLabel),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.r,
                color: ColorsManager.purpleText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _source() {
    final parts = [bookName, reference].map(_nonEmpty).nonNulls;
    if (parts.isNotEmpty) return parts.join(' · ');
    return _nonEmpty(narrator) ?? '';
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
