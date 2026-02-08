import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Horizontal day chips for picking a specific day in History mode.
class DaySelector extends StatelessWidget {
  final int selectedDay;
  final int start;
  final int end;
  final int todayDay;
  final ValueChanged<int> onSelect;

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.start,
    required this.end,
    required this.todayDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final days = List<int>.generate(end - start + 1, (i) => start + i);
    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.zero,
        itemCount: days.length,
        separatorBuilder: (_, __) => SizedBox(width: 6.w),
        itemBuilder: (_, idx) {
          final d = days[idx];
          final selected = d == selectedDay;
          final isToday = d == todayDay;
          return GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    selected
                        ? ColorsManager.primaryPurple
                        : ColorsManager.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color:
                      selected
                          ? ColorsManager.primaryPurple
                          : isToday
                          ? ColorsManager.primaryGold
                          : ColorsManager.mediumGray,
                  width: isToday && !selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                '$d',
                style: TextStyles.titleSmall.copyWith(
                  color:
                      selected
                          ? ColorsManager.white
                          : isToday
                          ? ColorsManager.primaryGold
                          : ColorsManager.primaryText,
                  fontWeight:
                      selected || isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
