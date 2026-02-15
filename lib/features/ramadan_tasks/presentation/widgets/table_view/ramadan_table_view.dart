import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

import '../../../domain/entities/ramadan_task_entity.dart';
import '../../cubit/ramadan_tasks_cubit.dart';
import 'table_checkbox_cell.dart';
import 'table_day_progress.dart';
import 'table_overall_progress.dart';

/// Full-screen Ramadan table-view grid widget.
///
/// Designed to fill all available vertical space when used
/// inside an [Expanded] or given unconstrained height.
///
/// Features:
/// - Rows = Days (1–30), Columns = Tasks
/// - Sticky header row (task names visible while scrolling vertically)
/// - Sticky first column (day numbers visible while scrolling horizontally)
/// - Daily tasks appear across all 30 days
/// - TodayOnly tasks appear only on their specific day row
/// - Per-day progress indicator at end of each row
/// - Overall progress summary above the table
/// - Responsive: adapts cell sizes on tablet via LayoutBuilder
class RamadanTableView extends StatefulWidget {
  final List<RamadanTaskEntity> allTasks;
  final int todayDay;
  final double overallPercent;

  const RamadanTableView({
    super.key,
    required this.allTasks,
    required this.todayDay,
    required this.overallPercent,
  });

  @override
  State<RamadanTableView> createState() => _RamadanTableViewState();
}

class _RamadanTableViewState extends State<RamadanTableView> {
  final _verticalController = ScrollController();
  final _horizontalController = ScrollController();
  final _headerHorizontalController = ScrollController();
  final _dayColumnVerticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _horizontalController.addListener(_syncHorizontalScroll);
    _verticalController.addListener(_syncVerticalScroll);
  }

  void _syncHorizontalScroll() {
    if (_headerHorizontalController.hasClients) {
      _headerHorizontalController.jumpTo(_horizontalController.offset);
    }
  }

  void _syncVerticalScroll() {
    if (_dayColumnVerticalController.hasClients) {
      _dayColumnVerticalController.jumpTo(_verticalController.offset);
    }
  }

  @override
  void dispose() {
    _verticalController.removeListener(_syncVerticalScroll);
    _horizontalController.removeListener(_syncHorizontalScroll);
    _verticalController.dispose();
    _horizontalController.dispose();
    _headerHorizontalController.dispose();
    _dayColumnVerticalController.dispose();
    super.dispose();
  }

  String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }

  IconData _taskIcon(RamadanTaskEntity task) {
    final title = task.title.toLowerCase();
    if (title.contains('صلاة') || title.contains('صلا')) {
      return Icons.mosque_rounded;
    }
    if (title.contains('قرآن') ||
        title.contains('قران') ||
        title.contains('تلاوة')) {
      return Icons.menu_book_rounded;
    }
    if (title.contains('ذكر') ||
        title.contains('أذكار') ||
        title.contains('تسبيح')) {
      return Icons.auto_awesome_rounded;
    }
    if (title.contains('صيام') ||
        title.contains('إفطار') ||
        title.contains('سحور')) {
      return Icons.restaurant_rounded;
    }
    if (title.contains('صدقة') ||
        title.contains('زكاة') ||
        title.contains('تبرع')) {
      return Icons.volunteer_activism_rounded;
    }
    if (title.contains('دعاء') || title.contains('دعوة')) {
      return Icons.front_hand_rounded;
    }
    if (title.contains('علم') ||
        title.contains('درس') ||
        title.contains('حلقة')) {
      return Icons.school_rounded;
    }
    if (task.type == TaskType.todayOnly) {
      return Icons.event_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.allTasks;
    if (tasks.isEmpty) {
      return const _EmptyTableState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive cell sizing: wider on tablet
        final isTablet = constraints.maxWidth >= 700;
        final dayCellW = isTablet ? 64.0 : 52.0;
        final taskCellW = isTablet ? 60.0 : 48.0;
        final progressCellW = isTablet ? 60.0 : 52.0;
        final headerH = isTablet ? 72.0 : 64.0;
        final rowH = isTablet ? 48.0 : 40.0;

        return Column(
          children: [
            // ── Overall progress ──
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              child: TableOverallProgress(
                overallPercent: widget.overallPercent,
                todayDay: widget.todayDay,
              ),
            ),

            // ── Table fills remaining space ──
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorsManager.cardBackground,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: ColorsManager.mediumGray.withOpacity(0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D7C66).withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // ── Sticky header row ──
                      _buildHeaderRow(
                        tasks,
                        dayCellW: dayCellW,
                        taskCellW: taskCellW,
                        progressCellW: progressCellW,
                        headerH: headerH,
                      ),
                      Divider(
                        height: 1,
                        color: ColorsManager.mediumGray.withOpacity(0.25),
                      ),
                      // ── Body: sticky day column + scrollable grid ──
                      Expanded(
                        child: Row(
                          children: [
                            _buildDayColumn(dayCellW: dayCellW, rowH: rowH),
                            Container(
                              width: 1,
                              color: ColorsManager.mediumGray.withOpacity(0.25),
                            ),
                            Expanded(
                              child: _buildGridBody(
                                tasks,
                                taskCellW: taskCellW,
                                progressCellW: progressCellW,
                                rowH: rowH,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // ── Legend ──
            _buildLegend(),

            SizedBox(height: 88.h),
          ],
        );
      },
    );
  }

  Widget _buildHeaderRow(
    List<RamadanTaskEntity> tasks, {
    required double dayCellW,
    required double taskCellW,
    required double progressCellW,
    required double headerH,
  }) {
    return SizedBox(
      height: headerH,
      child: Row(
        children: [
          // Top-left corner cell
          Container(
            width: dayCellW,
            height: headerH,
            decoration: BoxDecoration(
              color: const Color(0xFF0D7C66).withOpacity(0.08),
            ),
            alignment: Alignment.center,
            child: Text(
              'اليوم',
              style: TextStyles.bodySmall.copyWith(
                color: const Color(0xFF0D7C66),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 1,
            color: ColorsManager.mediumGray.withOpacity(0.25),
          ),
          // Scrollable task headers
          Expanded(
            child: SingleChildScrollView(
              controller: _headerHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  ...tasks.map(
                    (task) => _TaskHeaderCell(
                      task: task,
                      width: taskCellW,
                      height: headerH,
                      icon: _taskIcon(task),
                    ),
                  ),
                  // Progress column header
                  Container(
                    width: progressCellW,
                    height: headerH,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D7C66).withOpacity(0.06),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.pie_chart_rounded,
                      size: 16.sp,
                      color: const Color(0xFF0D7C66),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn({required double dayCellW, required double rowH}) {
    return SizedBox(
      width: dayCellW,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          controller: _dayColumnVerticalController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 30,
          itemExtent: rowH,
          itemBuilder: (_, dayIndex) {
            final day = dayIndex + 1;
            final isToday = day == widget.todayDay;
            return Container(
              width: dayCellW,
              height: rowH,
              decoration: BoxDecoration(
                color:
                    isToday
                        ? ColorsManager.primaryGold.withOpacity(0.12)
                        : dayIndex.isEven
                        ? ColorsManager.white
                        : ColorsManager.lightGray.withOpacity(0.35),
                border: Border(
                  bottom: BorderSide(
                    color: ColorsManager.mediumGray.withOpacity(0.12),
                    width: 0.5,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _toArabicNumerals(day),
                style: TextStyles.bodySmall.copyWith(
                  color:
                      isToday
                          ? ColorsManager.primaryGold
                          : ColorsManager.primaryText,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridBody(
    List<RamadanTaskEntity> tasks, {
    required double taskCellW,
    required double progressCellW,
    required double rowH,
  }) {
    return SingleChildScrollView(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: tasks.length * taskCellW + progressCellW,
        child: ListView.builder(
          controller: _verticalController,
          itemCount: 30,
          itemExtent: rowH,
          itemBuilder: (context, dayIndex) {
            final day = dayIndex + 1;
            final isToday = day == widget.todayDay;
            return _DayRow(
              key: ValueKey('day_row_$day'),
              day: day,
              isToday: isToday,
              isEven: dayIndex.isEven,
              tasks: tasks,
              taskCellWidth: taskCellW,
              progressCellWidth: progressCellW,
              rowHeight: rowH,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: ColorsManager.success, label: 'مكتمل'),
        SizedBox(width: 16.w),
        _LegendItem(color: ColorsManager.mediumGray, label: 'غير مكتمل'),
        SizedBox(width: 16.w),
        _LegendItem(color: ColorsManager.primaryGold, label: 'اليوم'),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Private helper widgets
// ────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isEven;
  final List<RamadanTaskEntity> tasks;
  final double taskCellWidth;
  final double progressCellWidth;
  final double rowHeight;

  const _DayRow({
    super.key,
    required this.day,
    required this.isToday,
    required this.isEven,
    required this.tasks,
    required this.taskCellWidth,
    required this.progressCellWidth,
    required this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    int completedCount = 0;
    int applicableCount = 0;

    final cells = <Widget>[];
    for (final task in tasks) {
      final isApplicable = _isTaskApplicableForDay(task, day);
      if (isApplicable) {
        applicableCount++;
        final isCompleted = task.completedDays.contains(day);
        if (isCompleted) completedCount++;
        cells.add(
          _CellWrapper(
            key: ValueKey('cell_${task.id}_$day'),
            width: taskCellWidth,
            height: rowHeight,
            isToday: isToday,
            isEven: isEven,
            child: TableCheckboxCell(
              isCompleted: isCompleted,
              enabled: true,
              onToggle: () {
                final cubit = context.read<RamadanTasksCubit>();
                if (task.type == TaskType.daily) {
                  cubit.toggleDaily(task.id);
                } else {
                  cubit.toggleTodayOnly(task.id);
                }
              },
            ),
          ),
        );
      } else {
        cells.add(
          _CellWrapper(
            key: ValueKey('empty_${task.id}_$day'),
            width: taskCellWidth,
            height: rowHeight,
            isToday: isToday,
            isEven: isEven,
            child: const TableEmptyCell(),
          ),
        );
      }
    }

    cells.add(
      _CellWrapper(
        width: progressCellWidth,
        height: rowHeight,
        isToday: isToday,
        isEven: isEven,
        child: TableDayProgress(
          completed: completedCount,
          total: applicableCount,
        ),
      ),
    );

    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorsManager.mediumGray.withOpacity(0.12),
            width: 0.5,
          ),
        ),
      ),
      child: Row(children: cells),
    );
  }

  bool _isTaskApplicableForDay(RamadanTaskEntity task, int day) {
    if (task.type == TaskType.daily) return true;
    return task.createdForDay == day;
  }
}

class _CellWrapper extends StatelessWidget {
  final double width;
  final double height;
  final bool isToday;
  final bool isEven;
  final Widget child;

  const _CellWrapper({
    super.key,
    required this.width,
    required this.height,
    required this.isToday,
    required this.isEven,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color:
          isToday
              ? ColorsManager.primaryGold.withOpacity(0.06)
              : isEven
              ? ColorsManager.white
              : ColorsManager.lightGray.withOpacity(0.35),
      child: child,
    );
  }
}

class _TaskHeaderCell extends StatelessWidget {
  final RamadanTaskEntity task;
  final double width;
  final double height;
  final IconData icon;

  const _TaskHeaderCell({
    required this.task,
    required this.width,
    required this.height,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D7C66).withOpacity(0.05),
        border: Border(
          left: BorderSide(
            color: ColorsManager.mediumGray.withOpacity(0.12),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 2.w, vertical: 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color:
                  task.type == TaskType.daily
                      ? const Color(0xFF0D7C66).withOpacity(0.12)
                      : ColorsManager.primaryGold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 13.sp,
              color:
                  task.type == TaskType.daily
                      ? const Color(0xFF0D7C66)
                      : ColorsManager.primaryGold,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            task.title,
            style: TextStyles.labelSmall.copyWith(
              fontSize: 7.sp,
              color: ColorsManager.primaryText,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyles.labelSmall.copyWith(
            color: ColorsManager.secondaryText,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}

class _EmptyTableState extends StatelessWidget {
  const _EmptyTableState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsetsDirectional.all(32.w),
        padding: EdgeInsetsDirectional.all(32.w),
        decoration: BoxDecoration(
          color: ColorsManager.cardBackground,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: ColorsManager.mediumGray.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_on_rounded,
              size: 48.sp,
              color: ColorsManager.mediumGray,
            ),
            SizedBox(height: 12.h),
            Text(
              'لا توجد مهام بعد',
              style: TextStyles.titleMedium.copyWith(
                color: ColorsManager.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'أضف مهامك لترى الجدول الشهري',
              style: TextStyles.bodySmall.copyWith(color: ColorsManager.gray),
            ),
          ],
        ),
      ),
    );
  }
}
