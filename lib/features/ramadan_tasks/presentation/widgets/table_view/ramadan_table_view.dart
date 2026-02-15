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

/// The main Ramadan table-view grid widget.
///
/// Features:
/// - Rows = Days (1–30), Columns = Tasks
/// - Sticky header row (task names visible while scrolling vertically)
/// - Sticky first column (day numbers visible while scrolling horizontally)
/// - Daily tasks appear across all 30 days
/// - TodayOnly tasks appear only on their specific day row
/// - Per-day progress indicator at end of each row
/// - Overall progress summary above the table
/// - Fully responsive and scrollable both axes
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
    // Sync horizontal scroll between header and body
    _horizontalController.addListener(_syncHorizontalScroll);
    // Sync vertical scroll between day column and body
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

  static const double _dayCellWidth = 52;
  static const double _taskCellWidth = 48;
  static const double _progressCellWidth = 52;
  static const double _headerHeight = 64;
  static const double _rowHeight = 40;

  String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }

  /// Determine the icon for a task based on title/type.
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
      return _EmptyTableState();
    }

    // Calculate available height: fill the remaining space
    // The table will be placed inside a SliverToBoxAdapter, so we
    // calculate a reasonable max height.
    final screenHeight = MediaQuery.of(context).size.height;
    final tableHeight = (screenHeight * 0.55).clamp(300.0, 600.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Overall progress ──
        TableOverallProgress(
          overallPercent: widget.overallPercent,
          todayDay: widget.todayDay,
        ),

        // ── Table with sticky headers ──
        Container(
          height: tableHeight,
          decoration: BoxDecoration(
            color: ColorsManager.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: ColorsManager.mediumGray.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryPurple.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ── Header row (sticky) ──
              _buildHeaderRow(tasks),
              Divider(
                height: 1,
                color: ColorsManager.mediumGray.withOpacity(0.3),
              ),
              // ── Body: day column (sticky) + scrollable grid ──
              Expanded(
                child: Row(
                  children: [
                    // Sticky day column
                    _buildDayColumn(),
                    // Vertical divider
                    Container(
                      width: 1,
                      color: ColorsManager.mediumGray.withOpacity(0.3),
                    ),
                    // Scrollable grid body
                    Expanded(child: _buildGridBody(tasks)),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // ── Legend ──
        _buildLegend(),
      ],
    );
  }

  /// Builds the sticky header row with task names/icons.
  Widget _buildHeaderRow(List<RamadanTaskEntity> tasks) {
    return SizedBox(
      height: _headerHeight.h,
      child: Row(
        children: [
          // Top-left corner cell (Day label)
          Container(
            width: _dayCellWidth.w,
            height: _headerHeight.h,
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withOpacity(0.08),
            ),
            alignment: Alignment.center,
            child: Text(
              'اليوم',
              style: TextStyles.bodySmall.copyWith(
                color: ColorsManager.primaryPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(width: 1, color: ColorsManager.mediumGray.withOpacity(0.3)),
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
                      width: _taskCellWidth.w,
                      height: _headerHeight.h,
                      icon: _taskIcon(task),
                    ),
                  ),
                  // Progress column header
                  Container(
                    width: _progressCellWidth.w,
                    height: _headerHeight.h,
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryPurple.withOpacity(0.06),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.pie_chart_rounded,
                      size: 16.sp,
                      color: ColorsManager.primaryPurple,
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

  /// Builds the sticky day number column.
  Widget _buildDayColumn() {
    return SizedBox(
      width: _dayCellWidth.w,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          controller: _dayColumnVerticalController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 30,
          itemExtent: _rowHeight.h,
          itemBuilder: (_, dayIndex) {
            final day = dayIndex + 1;
            final isToday = day == widget.todayDay;
            return Container(
              width: _dayCellWidth.w,
              height: _rowHeight.h,
              decoration: BoxDecoration(
                color:
                    isToday
                        ? ColorsManager.primaryGold.withOpacity(0.12)
                        : dayIndex.isEven
                        ? ColorsManager.white
                        : ColorsManager.lightGray.withOpacity(0.4),
                border: Border(
                  bottom: BorderSide(
                    color: ColorsManager.mediumGray.withOpacity(0.15),
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

  /// Builds the scrollable grid body (both horizontal and vertical).
  Widget _buildGridBody(List<RamadanTaskEntity> tasks) {
    return SingleChildScrollView(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: (tasks.length * _taskCellWidth + _progressCellWidth).w,
        child: ListView.builder(
          controller: _verticalController,
          itemCount: 30,
          itemExtent: _rowHeight.h,
          itemBuilder: (context, dayIndex) {
            final day = dayIndex + 1;
            final isToday = day == widget.todayDay;
            return _DayRow(
              key: ValueKey('day_row_$day'),
              day: day,
              isToday: isToday,
              isEven: dayIndex.isEven,
              tasks: tasks,
              taskCellWidth: _taskCellWidth.w,
              progressCellWidth: _progressCellWidth.w,
              rowHeight: _rowHeight.h,
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

/// A single row for a day in the table, containing checkbox cells and a progress indicator.
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

    // Progress cell at end
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
            color: ColorsManager.mediumGray.withOpacity(0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(children: cells),
    );
  }

  /// Returns true if the task should appear for the given day.
  bool _isTaskApplicableForDay(RamadanTaskEntity task, int day) {
    if (task.type == TaskType.daily) return true;
    // todayOnly: only show on the specific day it was created for
    return task.createdForDay == day;
  }
}

/// Wraps a single cell with consistent background decoration.
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
              : ColorsManager.lightGray.withOpacity(0.4),
      child: child,
    );
  }
}

/// Header cell for a single task column.
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
        color: ColorsManager.primaryPurple.withOpacity(0.06),
        border: Border(
          left: BorderSide(
            color: ColorsManager.mediumGray.withOpacity(0.15),
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
                      ? ColorsManager.primaryPurple.withOpacity(0.12)
                      : ColorsManager.primaryGold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 13.sp,
              color:
                  task.type == TaskType.daily
                      ? ColorsManager.primaryPurple
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
            /*
            task.title.length > 5
                ? '${task.title.substring(0, 5)}..'
                : task.title,
                */
          /*  style: TextStyles.labelSmall.copyWith(
              fontSize: 7.sp,
              color: ColorsManager.primaryText,
              fontWeight: FontWeight.w600,
            ),
            */
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A legend item (colored circle + label).
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

/// Shown when there are no tasks to display in the table.
class _EmptyTableState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(32.w),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ColorsManager.mediumGray.withOpacity(0.3),
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
    );
  }
}
