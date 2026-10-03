import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Displays both Hijri and Gregorian dates in a decorative card
/// at the top of the Ramadan tasks screen.
class DateHeaderCard extends StatelessWidget {
  final String hijriDate;
  final String gregorianDate;

  const DateHeaderCard({
    super.key,
    required this.hijriDate,
    required this.gregorianDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: ColorsManager.primaryPurple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ColorsManager.primaryPurple.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          // ── Crescent icon ──
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.nights_stay_rounded,
              color: ColorsManager.primaryPurple,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),

          // ── Date texts ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hijri date (primary)
                Text(
                  hijriDate,
                  style: TextStyles.titleMedium.copyWith(
                    color: ColorsManager.primaryPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                // Gregorian date (secondary)
                Text(
                  gregorianDate,
                  style: TextStyles.bodySmall.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // ── Calendar icon decoration ──
          Icon(
            Icons.calendar_today_rounded,
            color: ColorsManager.primaryPurple.withOpacity(0.3),
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
