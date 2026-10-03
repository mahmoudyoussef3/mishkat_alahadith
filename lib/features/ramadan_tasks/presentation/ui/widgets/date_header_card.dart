import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

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
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.nights_stay_rounded,
              color: ColorsManager.purpleText,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hijriDate,
                  style: TextStyles.titleMedium.copyWith(
                    color: ColorsManager.purpleText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  gregorianDate,
                  style: TextStyles.bodySmall.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),

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
