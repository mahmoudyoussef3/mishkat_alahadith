import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../../domain/entities/ramadan_task_entity.dart';

/// A full monthly calendar widget that shows the 30 days of Ramadan
/// organized by 4 weeks, with color-coded completion heatmap.
///
/// Tapping a day cell calls [onDaySelected] to drill into that day's records.
class MonthlyCalendarView extends StatelessWidget {
  final List<RamadanTaskEntity> allTasks;
  final int todayDay;
  final int? selectedDay;
  final ValueChanged<int?> onDaySelected;

  const MonthlyCalendarView({
    super.key,
    required this.allTasks,
    required this.todayDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  // ── Task helpers ──

  List<RamadanTaskEntity> get _dailyTasks =>
      allTasks.where((t) => t.type == TaskType.daily).toList();

  List<RamadanTaskEntity> _todayOnlyForDay(int day) =>
      allTasks
          .where((t) => t.type == TaskType.todayOnly && t.createdForDay == day)
          .toList();

  double _completionRatio(int day) {
    final todayOnly = _todayOnlyForDay(day);
    final total = _dailyTasks.length + todayOnly.length;
    if (total == 0) return 0;
    final dailyDone =
        _dailyTasks.where((t) => t.completedDays.contains(day)).length;
    final todayOnlyDone =
        todayOnly.where((t) => t.completedDays.contains(day)).length;
    return (dailyDone + todayOnlyDone) / total;
  }

  int _completedCount(int day) {
    final todayOnly = _todayOnlyForDay(day);
    final dailyDone =
        _dailyTasks.where((t) => t.completedDays.contains(day)).length;
    final todayOnlyDone =
        todayOnly.where((t) => t.completedDays.contains(day)).length;
    return dailyDone + todayOnlyDone;
  }

  int _totalCount(int day) {
    return _dailyTasks.length + _todayOnlyForDay(day).length;
  }

  static const _weekLabels = ['الأسبوع ١', 'الأسبوع ٢', 'الأسبوع ٣', 'الأسبوع ٤'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Title ──
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 16.w, 10.h),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: ColorsManager.primaryPurple,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'تقويم الشهر',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColorsManager.primaryText,
                  ),
                ),
                const Spacer(),
                // Legend
                _LegendDot(color: ColorsManager.success, label: 'مكتمل'),
                SizedBox(width: 8.w),
                _LegendDot(color: ColorsManager.primaryGold, label: 'جزئي'),
                SizedBox(width: 8.w),
                _LegendDot(color: ColorsManager.lightGray, label: 'فارغ'),
              ],
            ),
          ),

          Divider(height: 1, color: ColorsManager.mediumGray.withOpacity(0.5)),

          // ── Weeks ──
          for (int week = 0; week < 4; week++) ...[
            _buildWeekSection(week),
            if (week < 3)
              Divider(
                height: 1,
                indent: 16.w,
                endIndent: 16.w,
                color: ColorsManager.mediumGray.withOpacity(0.3),
              ),
          ],

          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildWeekSection(int weekIndex) {
    final start = weekIndex * 7 + 1;
    final end = weekIndex == 3 ? 30 : (weekIndex + 1) * 7;

    // Compute week progress
    double weekTotal = 0;
    double weekCompleted = 0;
    for (int d = start; d <= end; d++) {
      if (d <= todayDay) {
        weekTotal += _totalCount(d);
        weekCompleted += _completedCount(d);
      }
    }
    final weekPercent = weekTotal > 0 ? weekCompleted / weekTotal : 0.0;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Week header ──
          Row(
            children: [
              Text(
                _weekLabels[weekIndex],
                style: TextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.primaryPurple,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: weekPercent.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 4.h,
                        backgroundColor:
                            ColorsManager.mediumGray.withOpacity(0.3),
                        color: weekPercent >= 1.0
                            ? ColorsManager.success
                            : ColorsManager.primaryPurple,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${(weekPercent * 100).toInt()}%',
                style: TextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.secondaryText,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // ── Day cells row ──
          Row(
            children: [
              for (int day = start; day <= end; day++)
                Expanded(child: _buildDayCell(day)),
              // Fill last row to 7 columns
              if (end == 30)
                for (int i = 0; i < 2; i++)
                  const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day) {
    final isFuture = day > todayDay;
    final ratio = isFuture ? 0.0 : _completionRatio(day);
    final isSelected = day == selectedDay;
    final isToday = day == todayDay;

    Color bgColor;
    Color textColor;
    if (isFuture) {
      bgColor = ColorsManager.lightGray.withOpacity(0.5);
      textColor = ColorsManager.disabledText;
    } else if (ratio >= 1.0) {
      bgColor = ColorsManager.success;
      textColor = ColorsManager.white;
    } else if (ratio > 0) {
      bgColor = ColorsManager.primaryGold.withOpacity(0.25 + ratio * 0.45);
      textColor = ColorsManager.primaryText;
    } else {
      bgColor = ColorsManager.lightGray;
      textColor = ColorsManager.primaryText;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onDaySelected(isSelected ? null : day);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsetsDirectional.all(2.5.w),
        height: 46.w,
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryPurple : bgColor,
          borderRadius: BorderRadius.circular(10.r),
          border: isToday && !isSelected
              ? Border.all(color: ColorsManager.primaryPurple, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorsManager.primaryPurple.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _toArabicNumerals(day),
              style: TextStyles.titleSmall.copyWith(
                color: isSelected ? ColorsManager.white : textColor,
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
            if (!isFuture && ratio > 0 && ratio < 1.0 && !isSelected)
              Container(
                margin: EdgeInsetsDirectional.only(top: 2.h),
                width: 4.w,
                height: 4.w,
                decoration: const BoxDecoration(
                  color: ColorsManager.primaryGold,
                  shape: BoxShape.circle,
                ),
              ),
            if (!isFuture && ratio >= 1.0 && !isSelected)
              Icon(
                Icons.check_rounded,
                size: 10.sp,
                color: ColorsManager.white,
              ),
          ],
        ),
      ),
    );
  }

  static String _toArabicNumerals(int number) {
    const arabicDigits = [
      '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
    ];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }
}

// ─────────────────────────────────────────────────────────────
// Legend dot
// ─────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: ColorsManager.secondaryText,
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}
