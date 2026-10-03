import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Horizontal scrollable week selector (الأسبوع ١ – ٤) for History mode.
class WeekSelector extends StatelessWidget {
  final int selectedWeek;
  final ValueChanged<int> onSelected;

  const WeekSelector({
    super.key,
    required this.selectedWeek,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['الأسبوع ١', 'الأسبوع ٢', 'الأسبوع ٣', 'الأسبوع ٤'];
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.zero,
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final week = i + 1;
          final selected = week == selectedWeek;
          return GestureDetector(
            onTap: () => onSelected(week),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
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
                          : ColorsManager.mediumGray,
                ),
                boxShadow:
                    selected
                        ? [
                          BoxShadow(
                            color: ColorsManager.primaryPurple.withOpacity(
                              0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                labels[i],
                style: TextStyles.titleSmall.copyWith(
                  color:
                      selected
                          ? ColorsManager.white
                          : ColorsManager.primaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
