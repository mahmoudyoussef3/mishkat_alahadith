import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Displays a small overall progress summary above the table grid.
/// Shows a gradient bar with percentage and completed/total counts.
class TableOverallProgress extends StatelessWidget {
  final double overallPercent;
  final int todayDay;

  const TableOverallProgress({
    super.key,
    required this.overallPercent,
    required this.todayDay,
  });

  String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final percent = overallPercent.clamp(0.0, 1.0);
    return Container(
      margin: EdgeInsetsDirectional.only(bottom: 12.h),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryPurple.withOpacity(0.08),
            ColorsManager.darkPurple.withOpacity(0.04),
          ],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: ColorsManager.primaryPurple.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 18.sp,
                color: ColorsManager.primaryPurple,
              ),
              SizedBox(width: 8.w),
              Text(
                'التقدم الكلي',
                style: TextStyles.titleSmall.copyWith(
                  color: ColorsManager.primaryPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'اليوم ${_toArabicNumerals(todayDay)} من ٣٠',
                style: TextStyles.bodySmall.copyWith(
                  color: ColorsManager.secondaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: SizedBox(
                      height: 8.h,
                      child: Stack(
                        children: [
                          // Background
                          Container(
                            decoration: BoxDecoration(
                              color: ColorsManager.primaryPurple.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          // Fill
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    ColorsManager.primaryPurple,
                                    ColorsManager.darkPurple,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(value * 100).toInt()}%',
                        style: TextStyles.bodySmall.copyWith(
                          color: ColorsManager.primaryPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
