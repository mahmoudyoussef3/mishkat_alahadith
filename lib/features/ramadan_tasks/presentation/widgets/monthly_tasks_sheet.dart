import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../domain/entities/ramadan_task_entity.dart';

/// Full-screen modal bottom sheet displaying all 30 Ramadan days
/// in a vertical scrollable list with tasks listed under each day.
class MonthlyTasksSheet extends StatelessWidget {
  final List<RamadanTaskEntity> allTasks;
  final int todayDay;

  const MonthlyTasksSheet({
    super.key,
    required this.allTasks,
    required this.todayDay,
  });

  /// Convenience method to open the sheet from any screen.
  static void show(
    BuildContext context, {
    required List<RamadanTaskEntity> allTasks,
    required int todayDay,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthlyTasksSheet(allTasks: allTasks, todayDay: todayDay),
    );
  }

  // ── Data helpers ─────────────────────────────────────────────

  List<RamadanTaskEntity> get _dailyTasks =>
      allTasks.where((t) => t.type == TaskType.daily).toList();

  List<RamadanTaskEntity> _todayOnlyForDay(int day) =>
      allTasks
          .where((t) => t.type == TaskType.todayOnly && t.createdForDay == day)
          .toList();

  /// All tasks that should appear under a given day.
  List<RamadanTaskEntity> _tasksForDay(int day) => [
    ..._dailyTasks,
    ..._todayOnlyForDay(day),
  ];

  int _completedCountForDay(int day) {
    final tasks = _tasksForDay(day);
    return tasks.where((t) {
      if (t.type == TaskType.daily) return t.completedDays.contains(day);
      return t.completedDays.contains(t.createdForDay);
    }).length;
  }

  double _completionRatio(int day) {
    final tasks = _tasksForDay(day);
    if (tasks.isEmpty) return 0;
    return _completedCountForDay(day) / tasks.length;
  }

  String _toArabicNumerals(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => digits[int.parse(d)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: ColorsManager.primaryBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                // ── Drag handle ──
                _DragHandle(),

                // ── Header ──
                _SheetHeader(
                  todayDay: todayDay,
                  totalDays: 30,
                  completedDays: _countFullyCompletedDays(),
                ),

                SizedBox(height: 8.h),

                // ── Day list ──
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsetsDirectional.only(
                      start: 16.w,
                      end: 16.w,
                      bottom: 32.h,
                    ),
                    itemCount: 30,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) {
                      final day = index + 1;
                      final tasks = _tasksForDay(day);
                      return _DayCard(
                        day: day,
                        todayDay: todayDay,
                        tasks: tasks,
                        completedCount: _completedCountForDay(day),
                        ratio: _completionRatio(day),
                        toArabicNumerals: _toArabicNumerals,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _countFullyCompletedDays() {
    int count = 0;
    for (int day = 1; day <= todayDay; day++) {
      final tasks = _tasksForDay(day);
      if (tasks.isEmpty) continue;
      if (_completedCountForDay(day) == tasks.length) count++;
    }
    return count;
  }
}

// ══════════════════════════════════════════════════════════════
// Private helper widgets
// ══════════════════════════════════════════════════════════════

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 12.h, bottom: 4.h),
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: ColorsManager.mediumGray,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final int todayDay;
  final int totalDays;
  final int completedDays;

  const _SheetHeader({
    required this.todayDay,
    required this.totalDays,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ColorsManager.primaryPurple,
                      ColorsManager.darkPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.view_list_rounded,
                  color: ColorsManager.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الخطة الشهرية',
                      style: TextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'مهامك لكل يوم من أيام رمضان',
                      style: TextStyles.bodySmall.copyWith(
                        color: ColorsManager.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Stats badge
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: ColorsManager.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: ColorsManager.success.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$completedDays / $totalDays',
                  style: TextStyles.titleSmall.copyWith(
                    color: ColorsManager.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Divider
          Container(
            height: 1,
            color: ColorsManager.mediumGray.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}

/// A card representing a single day (1–30) with its tasks listed vertically.
class _DayCard extends StatelessWidget {
  final int day;
  final int todayDay;
  final List<RamadanTaskEntity> tasks;
  final int completedCount;
  final double ratio;
  final String Function(int) toArabicNumerals;

  const _DayCard({
    required this.day,
    required this.todayDay,
    required this.tasks,
    required this.completedCount,
    required this.ratio,
    required this.toArabicNumerals,
  });

  bool get _isToday => day == todayDay;
  bool get _isFuture => day > todayDay;
  bool get _isFullyCompleted =>
      tasks.isNotEmpty && completedCount == tasks.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              _isToday
                  ? ColorsManager.primaryPurple.withOpacity(0.4)
                  : _isFullyCompleted
                  ? ColorsManager.success.withOpacity(0.3)
                  : ColorsManager.mediumGray.withOpacity(0.3),
          width: _isToday ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _isToday
                    ? ColorsManager.primaryPurple.withOpacity(0.08)
                    : ColorsManager.black.withOpacity(0.03),
            blurRadius: _isToday ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Day header bar ──
          _DayHeaderBar(
            day: day,
            isToday: _isToday,
            isFuture: _isFuture,
            isFullyCompleted: _isFullyCompleted,
            completedCount: completedCount,
            totalCount: tasks.length,
            ratio: ratio,
            toArabicNumerals: toArabicNumerals,
          ),

          // ── Tasks list ──
          if (tasks.isEmpty)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: 20.h,
                horizontal: 16.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 18.sp,
                    color: ColorsManager.mediumGray,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'لا توجد مهام',
                    style: TextStyles.bodyMedium.copyWith(
                      color: ColorsManager.mediumGray,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 12.w,
                end: 12.w,
                bottom: 12.h,
              ),
              child: Column(
                children: [
                  for (int i = 0; i < tasks.length; i++) ...[
                    _TaskRow(task: tasks[i], day: day, isFuture: _isFuture),
                    if (i < tasks.length - 1)
                      Divider(
                        height: 1,
                        color: ColorsManager.mediumGray.withOpacity(0.15),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Gradient header bar at the top of each day card.
class _DayHeaderBar extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isFuture;
  final bool isFullyCompleted;
  final int completedCount;
  final int totalCount;
  final double ratio;
  final String Function(int) toArabicNumerals;

  const _DayHeaderBar({
    required this.day,
    required this.isToday,
    required this.isFuture,
    required this.isFullyCompleted,
    required this.completedCount,
    required this.totalCount,
    required this.ratio,
    required this.toArabicNumerals,
  });

  @override
  Widget build(BuildContext context) {
    final Color headerColor =
        isToday
            ? ColorsManager.primaryPurple
            : isFullyCompleted
            ? ColorsManager.success
            : isFuture
            ? ColorsManager.mediumGray
            : ColorsManager.darkPurple.withOpacity(0.7);

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: headerColor.withOpacity(isToday ? 0.12 : 0.06),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
      ),
      child: Row(
        children: [
          // Day badge
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: headerColor.withOpacity(isToday ? 1.0 : 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              toArabicNumerals(day),
              style: TextStyles.titleMedium.copyWith(
                color: isToday ? ColorsManager.white : headerColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Day label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'اليوم ${toArabicNumerals(day)}',
                      style: TextStyles.titleMedium.copyWith(
                        color:
                            isFuture
                                ? ColorsManager.secondaryText
                                : ColorsManager.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isToday) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryPurple,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'اليوم',
                          style: TextStyles.bodySmall.copyWith(
                            color: ColorsManager.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (totalCount > 0) ...[
                  SizedBox(height: 4.h),
                  // Mini progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3.r),
                          child: LinearProgressIndicator(
                            value: ratio.clamp(0.0, 1.0),
                            minHeight: 4.h,
                            color:
                                isFullyCompleted
                                    ? ColorsManager.success
                                    : ColorsManager.primaryPurple,
                            backgroundColor: headerColor.withOpacity(0.12),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '$completedCount / $totalCount',
                        style: TextStyles.bodySmall.copyWith(
                          color: ColorsManager.secondaryText,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Completion icon
          if (isFullyCompleted && totalCount > 0)
            Icon(
              Icons.check_circle_rounded,
              color: ColorsManager.success,
              size: 24.sp,
            ),
        ],
      ),
    );
  }
}

/// A single task row inside a day card.
class _TaskRow extends StatelessWidget {
  final RamadanTaskEntity task;
  final int day;
  final bool isFuture;

  const _TaskRow({
    required this.task,
    required this.day,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final isDaily = task.type == TaskType.daily;
    final relevantDay = isDaily ? day : task.createdForDay;
    final isCompleted = task.completedDays.contains(relevantDay);

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 10.h, horizontal: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Checkbox ──
          Padding(
            padding: EdgeInsetsDirectional.only(top: 2.h),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: isCompleted ? ColorsManager.success : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color:
                      isCompleted
                          ? ColorsManager.success
                          : ColorsManager.mediumGray,
                  width: 1.5,
                ),
              ),
              child:
                  isCompleted
                      ? Icon(
                        Icons.check_rounded,
                        size: 14.sp,
                        color: ColorsManager.white,
                      )
                      : null,
            ),
          ),
          SizedBox(width: 12.w),

          // ── Task content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyles.titleSmall.copyWith(
                    color:
                        isCompleted
                            ? ColorsManager.secondaryText
                            : isFuture
                            ? ColorsManager.secondaryText.withOpacity(0.7)
                            : ColorsManager.primaryText,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    task.description,
                    style: TextStyles.bodySmall.copyWith(
                      color: ColorsManager.secondaryText.withOpacity(0.8),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // ── Type badge ──
          Container(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 6.w,
              vertical: 3.h,
            ),
            decoration: BoxDecoration(
              color:
                  isDaily
                      ? ColorsManager.primaryPurple.withOpacity(0.08)
                      : ColorsManager.primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text(
              isDaily ? 'يومية' : 'مخصصة',
              style: TextStyles.bodySmall.copyWith(
                fontSize: 10.sp,
                color:
                    isDaily
                        ? ColorsManager.primaryPurple
                        : ColorsManager.primaryGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
