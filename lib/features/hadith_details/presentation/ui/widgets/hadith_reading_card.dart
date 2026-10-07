import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/dashed_divider.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_text.dart';

/// One button in the row under a hadith (copy, share, card).
class HadithCardAction {
  const HadithCardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// The hadith being read, at full length: number and grade, the chain of
/// narrators in a quiet tone, the words in large Amiri, and actions.
///
/// Under a read-aloud host, the word being read aloud is highlighted.
class HadithReadingCard extends StatelessWidget {
  const HadithReadingCard({
    super.key,
    required this.text,
    this.number,
    this.grade,
    this.gradeLabel,
    this.headerAction,
    this.footer,
    this.actions = const [],
  });

  final String text;
  final String? number;
  final HadithGrade? grade;

  /// Shown instead of [grade] when the grade carries more detail
  /// ("حسن · قاله النووي").
  final String? gradeLabel;

  /// Shown at the end of the badge row, such as the listen button.
  final Widget? headerAction;

  /// Extra line under the text, such as where the hadith is recorded.
  final Widget? footer;
  final List<HadithCardAction> actions;

  @override
  Widget build(BuildContext context) {
    final parts = HadithTextParts.split(text);
    final number = this.number;
    final grade = this.grade;
    final gradeLabel = this.gradeLabel;
    final headerAction = this.headerAction;
    final isnad = parts.isnad;
    final hasBadges =
        (number != null && number.isNotEmpty) ||
        grade != null ||
        gradeLabel != null;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasBadges || headerAction != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (number != null && number.isNotEmpty)
                        Container(
                          height: 26.r,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: ColorsManager.primaryText,
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          // widthFactor 1 keeps the badge as wide as its label.
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              toArabicDigits('حديث $number'),
                              style: TextStyles.chipLabel.copyWith(
                                fontWeight: FontWeight.w800,
                                color: ColorsManager.secondaryBackground,
                              ),
                            ),
                          ),
                        ),
                      if (gradeLabel != null)
                        AppBadge(
                          label: gradeLabel,
                          icon: Icons.verified_rounded,
                          background: _gradeColors(grade).$1,
                          foreground: _gradeColors(grade).$2,
                        )
                      else if (grade != null)
                        GradeBadge(grade: grade, withIcon: true),
                    ],
                  ),
                ),
                if (headerAction != null) ...[
                  SizedBox(width: 8.w),
                  headerAction,
                ],
              ],
            ),
            SizedBox(height: 12.h),
          ],
          SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isnad != null) ...[
                  ReadAloudText(
                    isnad,
                    part: SpeechPart.isnad,
                    style: TextStyles.readingMedium.copyWith(
                      fontSize: 15.sp,
                      height: 1.9,
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
                ReadAloudText(
                  parts.matn,
                  part: SpeechPart.matn,
                  style: TextStyles.readingLarge.copyWith(
                    fontSize: 23.sp,
                    height: 2.0,
                    fontWeight:
                        isnad != null ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (footer != null) ...[SizedBox(height: 12.h), footer!],
          if (actions.isNotEmpty) ...[
            SizedBox(height: 14.h),
            const DashedDivider(),
            SizedBox(height: 12.h),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) SizedBox(width: 8.w),
                  Expanded(child: _ActionButton(action: actions[i])),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  static (Color, Color) _gradeColors(HadithGrade? grade) => switch (grade) {
    HadithGrade.sahih => (ColorsManager.successSoft, ColorsManager.success),
    HadithGrade.daif => (ColorsManager.errorSoft, ColorsManager.error),
    _ => (ColorsManager.goldSoft, ColorsManager.hadithGood),
  };
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final HadithCardAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.secondaryBackground,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 40.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 18.r, color: ColorsManager.primaryText),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.labelLarge.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
