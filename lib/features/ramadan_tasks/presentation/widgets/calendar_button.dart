import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Rounded icon button that opens the calendar sheet.
class CalendarButton extends StatelessWidget {
  final VoidCallback onTap;

  const CalendarButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: ColorsManager.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: ColorsManager.primaryPurple.withOpacity(0.2),
          ),
        ),
        child: Icon(
          Icons.calendar_month_rounded,
          color: ColorsManager.primaryPurple,
          size: 22.sp,
        ),
      ),
    );
  }
}
