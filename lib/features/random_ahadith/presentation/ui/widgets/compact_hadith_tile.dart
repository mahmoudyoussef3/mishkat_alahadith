import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/dashed_divider.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_text.dart';

/// One hadith in a list of previews: its topic and grade as badges, up to
/// three lines of its text, and its source beside a way into its
/// explanation.
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
    final category = this.category;
    final grade = this.grade;

    return Material(
      color: palette.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (category != null || grade != null) ...[
                Row(
                  children: [
                    Expanded(
                      child:
                          category == null
                              ? const SizedBox.shrink()
                              : Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: AppBadge.tag(category),
                              ),
                    ),
                    if (grade != null) ...[
                      SizedBox(width: 8.w),
                      GradeBadge(grade: grade),
                    ],
                  ],
                ),
                SizedBox(height: 10.h),
              ],
              HadithText(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.readingMedium.copyWith(
                  fontSize: 16.sp,
                  height: 1.95,
                  color: palette.primaryText,
                ),
              ),
              SizedBox(height: 10.h),
              const DashedDivider(),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      source ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: palette.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'اقرأ مع الشرح',
                    style: TextStyles.actionLabel.copyWith(
                      color: palette.purpleText,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.r,
                    color: palette.purpleText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
