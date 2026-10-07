import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Small pill label: categories, grades, hadith numbers.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.fontWeight = FontWeight.w700,
  });

  /// Brand-tinted badge for a category or topic.
  factory AppBadge.tag(String label, {Key? key}) => AppBadge(
    key: key,
    label: label,
    background: ColorsManager.primarySoft,
    foreground: ColorsManager.purpleText,
    fontWeight: FontWeight.w600,
  );

  /// High-contrast badge for a hadith number.
  factory AppBadge.ink(String label, {Key? key}) => AppBadge(
    key: key,
    label: label,
    background: ColorsManager.primaryText,
    foreground: ColorsManager.secondaryBackground,
  );

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15.r, color: foreground),
            SizedBox(width: 4.w),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.chipLabel.copyWith(
                color: foreground,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hadith grade in its semantic colour: green authentic, gold good, red weak.
class GradeBadge extends StatelessWidget {
  const GradeBadge({super.key, required this.grade, this.withIcon = false});

  final HadithGrade grade;

  /// Adds a seal before the label, for the hadith being read.
  final bool withIcon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (grade) {
      HadithGrade.sahih => (ColorsManager.successSoft, ColorsManager.success),
      HadithGrade.hasan => (ColorsManager.goldSoft, ColorsManager.hadithGood),
      HadithGrade.daif => (ColorsManager.errorSoft, ColorsManager.error),
    };
    return AppBadge(
      label: grade.arabicLabel,
      icon: withIcon ? Icons.verified_rounded : null,
      background: background,
      foreground: foreground,
    );
  }
}
