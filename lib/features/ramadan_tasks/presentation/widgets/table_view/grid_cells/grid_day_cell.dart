import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../table_utils.dart';

/// Day-number cell for the sticky pinned column (right side in RTL).
///
/// Displays the Ramadan day in Eastern Arabic numerals.
/// Today is highlighted with a prominent gold pill background.
class GridDayCell extends StatelessWidget {
  final int day;
  final bool isToday;

  const GridDayCell({super.key, required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    if (isToday) {
      return Center(
        child: Container(
          width: 42.w,
          padding: EdgeInsetsDirectional.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ColorsManager.primaryGold, Color(0xFFFFCA28)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryGold.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                toArabicNumerals(day),
                style: TextStyles.bodySmall.copyWith(
                  fontSize: 14.sp,
                  color: ColorsManager.white,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              Text(
                'اليوم',
                style: TextStyles.labelSmall.copyWith(
                  fontSize: 9.sp,
                  color: ColorsManager.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Text(
        toArabicNumerals(day),
        style: TextStyles.bodySmall.copyWith(
          fontSize: 14.sp,
          color: ColorsManager.primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
