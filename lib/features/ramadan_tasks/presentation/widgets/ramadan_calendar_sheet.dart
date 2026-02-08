import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../domain/entities/ramadan_task_entity.dart';

class RamadanCalendarSheet extends StatefulWidget {
  final List<RamadanTaskEntity> allTasks;
  final int todayDay;

  const RamadanCalendarSheet({
    super.key,
    required this.allTasks,
    required this.todayDay,
  });

  static void show(
    BuildContext context, {
    required List<RamadanTaskEntity> allTasks,
    required int todayDay,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => RamadanCalendarSheet(allTasks: allTasks, todayDay: todayDay),
    );
  }

  @override
  State<RamadanCalendarSheet> createState() => _RamadanCalendarSheetState();
}

class _RamadanCalendarSheetState extends State<RamadanCalendarSheet> {
  int? _selectedDay;

  // ── Computed data ──

  List<RamadanTaskEntity> get _dailyTasks =>
      widget.allTasks.where((t) => t.type == TaskType.daily).toList();

  /// TodayOnly tasks that belong to a specific day.
  List<RamadanTaskEntity> _todayOnlyForDay(int day) =>
      widget.allTasks
          .where((t) => t.type == TaskType.todayOnly && t.createdForDay == day)
          .toList();

  /// All todayOnly tasks across the month.
  List<RamadanTaskEntity> get _allTodayOnly =>
      widget.allTasks.where((t) => t.type == TaskType.todayOnly).toList();

  int _dailyCompletedOnDay(int day) =>
      _dailyTasks.where((t) => t.completedDays.contains(day)).length;

  int _todayOnlyCompletedOnDay(int day) =>
      _todayOnlyForDay(day).where((t) => t.completedDays.contains(day)).length;

  /// Returns a 0.0–1.0 ratio of all tasks completed on [day].
  double _completionRatio(int day) {
    final todayOnlyForThisDay = _todayOnlyForDay(day);
    final total = _dailyTasks.length + todayOnlyForThisDay.length;
    if (total == 0) return 0;
    final completed = _dailyCompletedOnDay(day) + _todayOnlyCompletedOnDay(day);
    return completed / total;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: ColorsManager.secondaryBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                // ── Drag handle ──
                Padding(
                  padding: EdgeInsetsDirectional.only(top: 12.h, bottom: 8.h),
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: ColorsManager.mediumGray,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // ── Title ──
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: ColorsManager.primaryPurple,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text('تقويم رمضان', style: TextStyles.headlineSmall),
                      const Spacer(),
                      // Legend
                      _LegendDot(color: ColorsManager.success, label: 'مكتمل'),
                      SizedBox(width: 10.w),
                      _LegendDot(
                        color: ColorsManager.primaryGold,
                        label: 'جزئي',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Weekday header row ──
                SizedBox(height: 8.h),

                // ── Calendar grid ──
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                    children: [
                      _buildCalendarGrid(),
                      SizedBox(height: 12.h),

                      // ── Today-only tasks overview ──
                      if (_allTodayOnly.isNotEmpty) ...[
                        _buildTodayOnlySection(),
                        SizedBox(height: 12.h),
                      ],

                      // ── Day detail card (shown on tap) ──
                      if (_selectedDay != null) ...[
                        _buildDayDetail(_selectedDay!),
                        SizedBox(height: 16.h),
                      ],

                      // ── Stats summary ──
                      _buildStatsSummary(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Calendar Grid
  // ─────────────────────────────────────────────────────────────
  Widget _buildCalendarGrid() {
    // 30 days in a 7-column grid → 5 rows (last row has 2 cells).
    final rows = <Widget>[];
    for (int rowStart = 1; rowStart <= 30; rowStart += 7) {
      final rowEnd = (rowStart + 6).clamp(1, 30);
      final cells = <Widget>[];
      for (int day = rowStart; day <= rowEnd; day++) {
        cells.add(
          Expanded(
            child: _DayCell(
              day: day,
              ratio: _completionRatio(day),
              isToday: day == widget.todayDay,
              isFuture: day > widget.todayDay,
              isSelected: day == _selectedDay,
              onTap: () {
                setState(() {
                  _selectedDay = _selectedDay == day ? null : day;
                });
              },
            ),
          ),
        );
      }
      // Fill remaining cells in the last row with empty Expanded
      while (cells.length < 7) {
        cells.add(const Expanded(child: SizedBox()));
      }
      rows.add(
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: 6.h),
          child: Row(children: cells),
        ),
      );
    }
    return Column(children: rows);
  }

  // ─────────────────────────────────────────────────────────────
  // Today-Only Tasks Section
  // ─────────────────────────────────────────────────────────────
  Widget _buildTodayOnlySection() {
    final completed =
        _allTodayOnly
            .where((t) => t.completedDays.contains(t.createdForDay))
            .length;
    return Container(
      padding: EdgeInsetsDirectional.all(14.w),
      decoration: BoxDecoration(
        color: ColorsManager.primaryGold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: ColorsManager.primaryGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today_rounded,
                color: ColorsManager.primaryGold,
                size: 20.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                'مهام اليوم فقط',
                style: TextStyles.titleMedium.copyWith(
                  color: ColorsManager.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$completed / ${_allTodayOnly.length}',
                style: TextStyles.titleSmall.copyWith(
                  color: ColorsManager.primaryGold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ..._allTodayOnly.map((t) {
            final done = t.completedDays.contains(t.createdForDay);
            return Padding(
              padding: EdgeInsetsDirectional.only(bottom: 6.h),
              child: Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color:
                        done ? ColorsManager.success : ColorsManager.mediumGray,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      t.title,
                      style: TextStyles.bodyMedium.copyWith(
                        decoration: done ? TextDecoration.lineThrough : null,
                        color:
                            done
                                ? ColorsManager.secondaryText
                                : ColorsManager.primaryText,
                      ),
                    ),
                  ),
                  Text(
                    'اليوم ${t.createdForDay}',
                    style: TextStyles.bodySmall.copyWith(
                      color: ColorsManager.secondaryText,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Day Detail Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildDayDetail(int day) {
    final todayOnlyForDay = _todayOnlyForDay(day);
    final allTasksForDay = [..._dailyTasks, ...todayOnlyForDay];
    final completed = _dailyCompletedOnDay(day) + _todayOnlyCompletedOnDay(day);
    final total = allTasksForDay.length;
    final isFuture = day > widget.todayDay;

    return Container(
      padding: EdgeInsetsDirectional.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryPurple.withOpacity(0.08),
            ColorsManager.primaryPurple.withOpacity(0.03),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ColorsManager.primaryPurple.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryPurple,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyles.titleLarge.copyWith(
                    color: ColorsManager.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('اليوم $day من رمضان', style: TextStyles.titleMedium),
                    SizedBox(height: 2.h),
                    Text(
                      isFuture
                          ? 'لم يأتِ بعد'
                          : day == widget.todayDay
                          ? 'اليوم الحالي'
                          : '$completed من $total مهمة مكتملة',
                      style: TextStyles.bodySmall.copyWith(
                        color: ColorsManager.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isFuture && total > 0)
                _MiniProgressRing(ratio: total == 0 ? 0 : completed / total),
            ],
          ),
          if (!isFuture && allTasksForDay.isNotEmpty) ...[
            SizedBox(height: 12.h),
            // Per-task completion list
            ...allTasksForDay.map((t) {
              final relevantDay =
                  t.type == TaskType.daily ? day : t.createdForDay;
              final done = t.completedDays.contains(relevantDay);
              return Padding(
                padding: EdgeInsetsDirectional.only(bottom: 4.h),
                child: Row(
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color:
                          done
                              ? ColorsManager.success
                              : ColorsManager.mediumGray,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: TextStyles.bodySmall.copyWith(
                              decoration:
                                  done ? TextDecoration.lineThrough : null,
                              color:
                                  done
                                      ? ColorsManager.secondaryText
                                      : ColorsManager.primaryText,
                            ),
                          ),
                          if (t.description.isNotEmpty)
                            Padding(
                              padding: EdgeInsetsDirectional.only(top: 1.h),
                              child: Text(
                                t.description,
                                style: TextStyles.bodySmall.copyWith(
                                  fontSize: 10.sp,
                                  color: ColorsManager.secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Stats Summary
  // ─────────────────────────────────────────────────────────────
  Widget _buildStatsSummary() {
    // Count "perfect days" (all daily tasks completed)
    int perfectDays = 0;
    int totalCompletions = 0;
    for (int d = 1; d <= widget.todayDay; d++) {
      final completed = _dailyCompletedOnDay(d);
      totalCompletions += completed;
      if (_dailyTasks.isNotEmpty && completed == _dailyTasks.length) {
        perfectDays++;
      }
    }

    // Streak: consecutive perfect days ending at todayDay
    int streak = 0;
    for (int d = widget.todayDay; d >= 1; d--) {
      if (_dailyTasks.isNotEmpty &&
          _dailyCompletedOnDay(d) == _dailyTasks.length) {
        streak++;
      } else {
        break;
      }
    }

    return Container(
      padding: EdgeInsetsDirectional.all(14.w),
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.local_fire_department_rounded,
              iconColor: ColorsManager.error,
              label: 'التوالي',
              value: '$streak يوم',
            ),
          ),
          Container(width: 1, height: 40.h, color: ColorsManager.mediumGray),
          Expanded(
            child: _StatItem(
              icon: Icons.emoji_events_rounded,
              iconColor: ColorsManager.primaryGold,
              label: 'أيام مثالية',
              value: '$perfectDays',
            ),
          ),
          Container(width: 1, height: 40.h, color: ColorsManager.mediumGray),
          Expanded(
            child: _StatItem(
              icon: Icons.done_all_rounded,
              iconColor: ColorsManager.success,
              label: 'إنجازات',
              value: '$totalCompletions',
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ══════════════════════════════════════════════════════════════

/// A single day cell in the calendar grid.
class _DayCell extends StatelessWidget {
  final int day;
  final double ratio; // 0.0 – 1.0
  final bool isToday;
  final bool isFuture;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.ratio,
    required this.isToday,
    required this.isFuture,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine cell color based on completion
    Color bgColor;
    Color textColor;
    if (isFuture) {
      bgColor = ColorsManager.lightGray.withOpacity(0.5);
      textColor = ColorsManager.disabledText;
    } else if (ratio >= 1.0) {
      bgColor = ColorsManager.success;
      textColor = ColorsManager.white;
    } else if (ratio > 0) {
      bgColor = ColorsManager.primaryGold.withOpacity(0.3 + ratio * 0.4);
      textColor = ColorsManager.primaryText;
    } else {
      bgColor = ColorsManager.lightGray;
      textColor = ColorsManager.primaryText;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsetsDirectional.all(3.w),
        height: 44.w,
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryPurple : bgColor,
          borderRadius: BorderRadius.circular(10.r),
          border:
              isToday && !isSelected
                  ? Border.all(color: ColorsManager.primaryPurple, width: 2)
                  : null,
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: ColorsManager.primaryPurple.withOpacity(0.3),
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
              '$day',
              style: TextStyles.titleSmall.copyWith(
                color: isSelected ? ColorsManager.white : textColor,
                fontWeight:
                    isToday || isSelected ? FontWeight.bold : FontWeight.w500,
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
}

/// Small legend dot + label.
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
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: ColorsManager.secondaryText,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}

/// Mini circular progress ring used in the day detail card.
class _MiniProgressRing extends StatelessWidget {
  final double ratio;
  const _MiniProgressRing({required this.ratio});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 3.w,
                strokeCap: StrokeCap.round,
                backgroundColor: ColorsManager.mediumGray.withOpacity(0.3),
                color:
                    value >= 1.0
                        ? ColorsManager.success
                        : ColorsManager.primaryPurple,
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyles.bodySmall.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.primaryText,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Single stat item for the bottom summary.
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: ColorsManager.secondaryText,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
