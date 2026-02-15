import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../../domain/entities/ramadan_task_entity.dart';

/// Display modes for day records.
enum DayRecordsMode { card, table }

/// Shows the task records for a selected day.
///
/// Has two display modes:
/// - **Card** — each task in its own decorated card with status badge
/// - **Table** — compact table with task/status columns
class DayRecordsView extends StatelessWidget {
  final int day;
  final int todayDay;
  final List<RamadanTaskEntity> allTasks;
  final DayRecordsMode mode;
  final ValueChanged<DayRecordsMode> onModeChanged;

  const DayRecordsView({
    super.key,
    required this.day,
    required this.todayDay,
    required this.allTasks,
    required this.mode,
    required this.onModeChanged,
  });

  // ── Task helpers ──

  List<RamadanTaskEntity> get _dailyTasks =>
      allTasks.where((t) => t.type == TaskType.daily).toList();

  List<RamadanTaskEntity> _todayOnlyForDay(int d) =>
      allTasks
          .where((t) => t.type == TaskType.todayOnly && t.createdForDay == d)
          .toList();

  List<RamadanTaskEntity> get _tasksForDay => [
        ..._dailyTasks,
        ..._todayOnlyForDay(day),
      ];

  bool _isCompleted(RamadanTaskEntity task) {
    return task.completedDays.contains(day);
  }

  int get _completedCount =>
      _tasksForDay.where((t) => _isCompleted(t)).length;

  bool get _isFuture => day > todayDay;

  @override
  Widget build(BuildContext context) {
    final tasks = _tasksForDay;
    final total = tasks.length;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          _buildHeader(total),

          Divider(height: 1, color: ColorsManager.mediumGray.withOpacity(0.5)),

          // ── Content ──
          if (_isFuture)
            _buildFutureState()
          else if (tasks.isEmpty)
            _buildEmptyState()
          else
            mode == DayRecordsMode.card
                ? _buildCardList(tasks)
                : _buildTable(tasks),
        ],
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 12.w, 10.h),
      child: Row(
        children: [
          // Day badge
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              _toArabicNumerals(day),
              style: TextStyles.titleMedium.copyWith(
                color: ColorsManager.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اليوم ${_toArabicNumerals(day)} من رمضان',
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColorsManager.primaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _isFuture
                      ? 'لم يأتِ بعد'
                      : day == todayDay
                          ? '${_toArabicNumerals(_completedCount)} من ${_toArabicNumerals(total)} · اليوم الحالي'
                          : '${_toArabicNumerals(_completedCount)} من ${_toArabicNumerals(total)} مهمة مكتملة',
                  style: TextStyles.bodySmall.copyWith(
                    color: ColorsManager.secondaryText,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),

          // Mode toggle
          _MiniModeToggle(
            mode: mode,
            onChanged: onModeChanged,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Card mode
  // ─────────────────────────────────────────────────────────────

  Widget _buildCardList(List<RamadanTaskEntity> tasks) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        children: tasks.map((task) {
          final done = _isCompleted(task);
          return Padding(
            padding: EdgeInsetsDirectional.only(bottom: 8.h),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsetsDirectional.all(12.w),
              decoration: BoxDecoration(
                color: done
                    ? ColorsManager.success.withOpacity(0.06)
                    : ColorsManager.lightGray,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: done
                      ? ColorsManager.success.withOpacity(0.2)
                      : ColorsManager.mediumGray.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  // Status icon
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(done),
                      color: done
                          ? ColorsManager.success
                          : ColorsManager.mediumGray,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // Task info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: done
                                ? ColorsManager.secondaryText
                                : ColorsManager.primaryText,
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (task.description.isNotEmpty)
                          Padding(
                            padding: EdgeInsetsDirectional.only(top: 2.h),
                            child: Text(
                              task.description,
                              style: TextStyles.bodySmall.copyWith(
                                color: ColorsManager.secondaryText,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Type badge
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: task.type == TaskType.daily
                          ? ColorsManager.primaryPurple.withOpacity(0.1)
                          : ColorsManager.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      task.type == TaskType.daily ? 'يومية' : 'مرة واحدة',
                      style: TextStyles.bodySmall.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: task.type == TaskType.daily
                            ? ColorsManager.primaryPurple
                            : ColorsManager.primaryGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Table mode
  // ─────────────────────────────────────────────────────────────

  Widget _buildTable(List<RamadanTaskEntity> tasks) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: ColorsManager.mediumGray.withOpacity(0.5),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header row
            Container(
              color: ColorsManager.primaryPurple.withOpacity(0.07),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28.w,
                    child: Text(
                      '#',
                      style: TextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.primaryPurple,
                        fontSize: 11.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'المهمة',
                      style: TextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.primaryPurple,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56.w,
                    child: Text(
                      'النوع',
                      style: TextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.primaryPurple,
                        fontSize: 11.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 44.w,
                    child: Text(
                      'الحالة',
                      style: TextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.primaryPurple,
                        fontSize: 11.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Data rows
            ...tasks.asMap().entries.map((entry) {
              final idx = entry.key;
              final task = entry.value;
              final done = _isCompleted(task);
              final isEven = idx % 2 == 0;
              return Container(
                color: isEven
                    ? Colors.transparent
                    : ColorsManager.lightGray.withOpacity(0.4),
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28.w,
                      child: Text(
                        _toArabicNumerals(idx + 1),
                        style: TextStyles.bodySmall.copyWith(
                          color: ColorsManager.secondaryText,
                          fontSize: 11.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyles.bodySmall.copyWith(
                          color: done
                              ? ColorsManager.secondaryText
                              : ColorsManager.primaryText,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 56.w,
                      child: Text(
                        task.type == TaskType.daily ? 'يومية' : 'مرة واحدة',
                        style: TextStyles.bodySmall.copyWith(
                          color: task.type == TaskType.daily
                              ? ColorsManager.primaryPurple
                              : ColorsManager.primaryGold,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 44.w,
                      child: Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.cancel_outlined,
                        color: done
                            ? ColorsManager.success
                            : ColorsManager.mediumGray,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Empty & future states
  // ─────────────────────────────────────────────────────────────

  Widget _buildFutureState() {
    return Padding(
      padding: EdgeInsetsDirectional.all(24.w),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 36.sp,
              color: ColorsManager.disabledText,
            ),
            SizedBox(height: 8.h),
            Text(
              'هذا اليوم لم يأتِ بعد',
              style: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsetsDirectional.all(24.w),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 36.sp,
              color: ColorsManager.disabledText,
            ),
            SizedBox(height: 8.h),
            Text(
              'لا توجد مهام لهذا اليوم',
              style: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
              ),
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
// Mini Card/Table toggle
// ─────────────────────────────────────────────────────────────

class _MiniModeToggle extends StatelessWidget {
  final DayRecordsMode mode;
  final ValueChanged<DayRecordsMode> onChanged;

  const _MiniModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(2.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniChip(
            icon: Icons.view_agenda_rounded,
            isSelected: mode == DayRecordsMode.card,
            onTap: () => onChanged(DayRecordsMode.card),
          ),
          _MiniChip(
            icon: Icons.table_rows_rounded,
            isSelected: mode == DayRecordsMode.table,
            onTap: () => onChanged(DayRecordsMode.table),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MiniChip({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryPurple
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: isSelected
              ? ColorsManager.white
              : ColorsManager.secondaryText,
        ),
      ),
    );
  }
}
