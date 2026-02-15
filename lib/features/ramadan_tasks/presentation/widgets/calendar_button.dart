import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Rounded icon button that opens the calendar sheet.
class CalendarButton extends StatelessWidget {
  final VoidCallback onTap;

  const CalendarButton({super.key, required this.onTap});
  String _hijriDateString() {
    final hijri = HijriCalendar.now();
    HijriCalendar.setLocal('ar');
    return '${_toArabicNumerals(hijri.hDay)} ${hijri.getLongMonthName()} ${_toArabicNumerals(hijri.hYear)} هـ';
  }

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
        child:
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
          'اليوم ${_hijriDateString()}',
          style: TextStyles.titleLarge.copyWith(
            color: ColorsManager.primaryGreen,
          ),
        ),
              Icon(
                Icons.calendar_month_rounded,
                color: ColorsManager.primaryPurple,
                size: 22.sp,
              ),
            ],
          ),
       
      ),
    );
  }
}
