import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// One hadith in a grouped list: a bar in its grade's colour, two lines of
/// its text, and its topic, grade and source on one line.
class CompactHadithTile extends StatelessWidget {
  const CompactHadithTile({
    super.key,
    required this.text,
    this.category,
    this.grade,
    this.source,
    this.onTap,
  });

  final String text;
  final String? category;
  final HadithGrade? grade;
  final String? source;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final grade = this.grade;
    final accent =
        grade == null ? palette.mediumGray : palette.gradeAccent(grade);
    final meta = [
      if (category case final category?)
        TextSpan(text: category, style: TextStyle(color: palette.purpleText)),
      if (grade != null)
        TextSpan(text: grade.arabicLabel, style: TextStyle(color: accent)),
      if (source case final source?) TextSpan(text: source),
    ];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: 4.w,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withValues(
                          alpha: palette.isDark ? 0.8 : 0.7,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.readingMedium.copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.85,
                            color: palette.primaryText,
                          ),
                        ),
                        if (meta.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text.rich(
                            TextSpan(
                              children: [
                                for (final (index, part) in meta.indexed) ...[
                                  if (index > 0) const TextSpan(text: '  ·  '),
                                  part,
                                ],
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.caption.copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: palette.secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Icon(Icons.chevron_right_rounded, size: 20.r, color: palette.gray),
          ],
        ),
      ),
    );
  }
}
