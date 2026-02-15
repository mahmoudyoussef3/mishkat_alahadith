import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

import '../../../domain/entities/ramadan_task_entity.dart';
import '../../cubit/ramadan_tasks_cubit.dart';
import 'table_checkbox_cell.dart';
import 'table_day_progress.dart';

/// Density mode for table layout
enum TableDensity {
  compact,
  comfortable,
  spacious;

  String get label {
    switch (this) {
      case TableDensity.compact:
        return 'مضغوط';
      case TableDensity.comfortable:
        return 'مريح';
      case TableDensity.spacious:
        return 'واسع';
    }
  }
}

/// Density configuration
class DensityConfig {
  final double rowHeight;
  final double headerHeight;
  final double fontSize;
  final double iconSize;
  final double cellPadding;

  const DensityConfig({
    required this.rowHeight,
    required this.headerHeight,
    required this.fontSize,
    required this.iconSize,
    required this.cellPadding,
  });

  factory DensityConfig.forDensity(TableDensity density, bool isTablet) {
    switch (density) {
      case TableDensity.compact:
        return DensityConfig(
          rowHeight: isTablet ? 36.0 : 32.0,
          headerHeight: isTablet ? 56.0 : 50.0,
          fontSize: isTablet ? 11.0 : 10.0,
          iconSize: isTablet ? 16.0 : 14.0,
          cellPadding: 2.0,
        );
      case TableDensity.comfortable:
        return DensityConfig(
          rowHeight: isTablet ? 48.0 : 40.0,
          headerHeight: isTablet ? 72.0 : 64.0,
          fontSize: isTablet ? 12.0 : 11.0,
          iconSize: isTablet ? 18.0 : 16.0,
          cellPadding: 4.0,
        );
      case TableDensity.spacious:
        return DensityConfig(
          rowHeight: isTablet ? 60.0 : 52.0,
          headerHeight: isTablet ? 88.0 : 76.0,
          fontSize: isTablet ? 13.0 : 12.0,
          iconSize: isTablet ? 20.0 : 18.0,
          cellPadding: 6.0,
        );
    }
  }
}

/// Full-screen Ramadan table-view grid widget.
///
/// Premium Excel-like productivity experience with:
/// - Clean, minimal design
/// - Smooth scroll physics
/// - Density modes (Compact / Comfortable / Spacious)
/// - Professional visual hierarchy
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

  bool _hasScrolledToToday = false;
  TableDensity _density = TableDensity.comfortable;
  bool _isToolbarCollapsed = false;

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

  void _scrollToToday(double rowHeight) {
    if (_hasScrolledToToday) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_verticalController.hasClients) return;

      final targetOffset = (widget.todayDay - 1) * rowHeight;
      final maxScroll = _verticalController.position.maxScrollExtent;
      final clampedOffset = targetOffset.clamp(0.0, maxScroll);

      _verticalController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );

      _hasScrolledToToday = true;
    });
  }

  void _scrollToTodayManual(double rowHeight) {
    if (!_verticalController.hasClients) return;

    final targetOffset = (widget.todayDay - 1) * rowHeight;
    final maxScroll = _verticalController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _verticalController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _changeDensity(TableDensity newDensity) {
    setState(() {
      _density = newDensity;
      _hasScrolledToToday = false;
    });
  }

  void _toggleToolbar() {
    setState(() {
      _isToolbarCollapsed = !_isToolbarCollapsed;
    });
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
        final isTablet = constraints.maxWidth >= 700;
        final config = DensityConfig.forDensity(_density, isTablet);

        final dayCellW = isTablet ? 64.0 : 52.0;
        final taskCellW = isTablet ? 60.0 : 48.0;
        final progressCellW = isTablet ? 68.0 : 58.0;

        _scrollToToday(config.rowHeight);

        return Column(
          children: [
            // ── Docked Toolbar ──
            _buildDockedToolbar(config, isTablet),

            SizedBox(height: 8.h),

            // ── Table Container ──
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorsManager.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: ColorsManager.mediumGray.withOpacity(0.12),
                      width: 0.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // ── Sticky Header ──
                      _buildHeaderRow(
                        tasks,
                        dayCellW: dayCellW,
                        taskCellW: taskCellW,
                        progressCellW: progressCellW,
                        config: config,
                      ),

                      Container(
                        height: 0.5,
                        color: ColorsManager.mediumGray.withOpacity(0.15),
                      ),

                      // ── Grid Body with Fade Shadows ──
                      Expanded(
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                _buildDayColumn(
                                  dayCellW: dayCellW,
                                  config: config,
                                ),
                                Container(
                                  width: 0.3,
                                  color: ColorsManager.mediumGray.withOpacity(
                                    0.1,
                                  ),
                                ),
                                Expanded(
                                  child: _buildGridBody(
                                    tasks,
                                    taskCellW: taskCellW,
                                    progressCellW: progressCellW,
                                    config: config,
                                  ),
                                ),
                              ],
                            ),
                            // Fade shadow on right edge
                            PositionedDirectional(
                              end: 0,
                              top: 0,
                              bottom: 0,
                              child: IgnorePointer(
                                child: Container(
                                  width: 16.w,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: AlignmentDirectional.centerEnd,
                                      end: AlignmentDirectional.centerStart,
                                      colors: [
                                        ColorsManager.white.withOpacity(0.8),
                                        ColorsManager.white.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
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

  Widget _buildDockedToolbar(DensityConfig config, bool isTablet) {
    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 8.w),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: ColorsManager.mediumGray.withOpacity(0.12),
          width: 0.5,
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            Row(
              children: [
                // Density Selector
                if (!_isToolbarCollapsed) ...[
                  Expanded(
                    child: _DensitySegmentedControl(
                      currentDensity: _density,
                      onDensityChanged: _changeDensity,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],

                // Scroll to Today Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _scrollToTodayManual(config.rowHeight),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.today_rounded,
                            size: 16.sp,
                            color: ColorsManager.primaryGold,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'اليوم',
                            style: TextStyles.labelSmall.copyWith(
                              color: ColorsManager.primaryGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                // Collapse Toggle
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleToolbar,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        _isToolbarCollapsed
                            ? Icons.expand_more_rounded
                            : Icons.expand_less_rounded,
                        size: 18.sp,
                        color: ColorsManager.secondaryText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(
    List<RamadanTaskEntity> tasks, {
    required double dayCellW,
    required double taskCellW,
    required double progressCellW,
    required DensityConfig config,
  }) {
    return Container(
      height: config.headerHeight,
      decoration: BoxDecoration(
        color: ColorsManager.primaryPurple.withOpacity(0.04),
      ),
      child: Row(
        children: [
          // Top-left corner cell
          Container(
            width: dayCellW,
            height: config.headerHeight,
            alignment: Alignment.center,
            child: Text(
              'اليوم',
              style: TextStyles.bodySmall.copyWith(
                fontSize: config.fontSize.sp,
                color: ColorsManager.primaryPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 0.3,
            color: ColorsManager.mediumGray.withOpacity(0.1),
          ),
          // Scrollable task headers
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: true),
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
                        height: config.headerHeight,
                        icon: _taskIcon(task),
                        config: config,
                      ),
                    ),
                    // Progress column header
                    Container(
                      width: progressCellW,
                      height: config.headerHeight,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.analytics_outlined,
                        size: config.iconSize.sp,
                        color: ColorsManager.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn({
    required double dayCellW,
    required DensityConfig config,
  }) {
    return RepaintBoundary(
      child: SizedBox(
        width: dayCellW,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.builder(
            controller: _dayColumnVerticalController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 30,
            itemExtent: config.rowHeight,
            itemBuilder: (_, dayIndex) {
              final day = dayIndex + 1;
              final isToday = day == widget.todayDay;
              return _DayCell(
                day: day,
                isToday: isToday,
                isEven: dayIndex.isEven,
                config: config,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGridBody(
    List<RamadanTaskEntity> tasks, {
    required double taskCellW,
    required double progressCellW,
    required DensityConfig config,
  }) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: tasks.length * taskCellW + progressCellW,
          child: ListView.builder(
            controller: _verticalController,
            physics: const BouncingScrollPhysics(),
            itemCount: 30,
            itemExtent: config.rowHeight,
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
                config: config,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 10.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: ColorsManager.success, label: 'مكتمل'),
          SizedBox(width: 16.w),
          _LegendItem(color: ColorsManager.mediumGray, label: 'غير مكتمل'),
          SizedBox(width: 16.w),
          _LegendItem(color: ColorsManager.primaryGold, label: 'اليوم'),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Density Segmented Control
// ────────────────────────────────────────────────────────────────

class _DensitySegmentedControl extends StatelessWidget {
  final TableDensity currentDensity;
  final ValueChanged<TableDensity> onDensityChanged;

  const _DensitySegmentedControl({
    required this.currentDensity,
    required this.onDensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          TableDensity.values.map((density) {
            final isSelected = density == currentDensity;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: density != TableDensity.values.last ? 4.w : 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onDensityChanged(density),
                    borderRadius: BorderRadius.circular(8.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? ColorsManager.primaryPurple.withOpacity(0.1)
                                : ColorsManager.lightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? ColorsManager.primaryPurple.withOpacity(0.3)
                                  : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        density.label,
                        textAlign: TextAlign.center,
                        style: TextStyles.labelSmall.copyWith(
                          color:
                              isSelected
                                  ? ColorsManager.primaryPurple
                                  : ColorsManager.secondaryText,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Day Cell with Badge
// ────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isEven;
  final DensityConfig config;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isEven,
    required this.config,
  });

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
    return Container(
      decoration: BoxDecoration(
        color:
            isToday
                ? ColorsManager.primaryGold.withOpacity(0.08)
                : isEven
                ? ColorsManager.white
                : ColorsManager.lightGray.withOpacity(0.25),
        border: Border(
          bottom: BorderSide(
            color: ColorsManager.mediumGray.withOpacity(0.06),
            width: 0.3,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Accent bar for today
          if (isToday)
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorsManager.primaryGold,
                      ColorsManager.primaryGold.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),

          // Day number
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _toArabicNumerals(day),
                  style: TextStyles.bodySmall.copyWith(
                    fontSize: config.fontSize.sp,
                    color:
                        isToday
                            ? ColorsManager.primaryGold
                            : ColorsManager.primaryText,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (isToday) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'اليوم',
                      style: TextStyles.labelSmall.copyWith(
                        fontSize: 8.sp,
                        color: ColorsManager.primaryGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ────────────────────────────────────────────────────────────────
// Private helper widgets
// ────────────────────────────────────────────────────────────────

// ────────────────────────────────────────────────────────────────
// Day Row
// ────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isEven;
  final List<RamadanTaskEntity> tasks;
  final double taskCellWidth;
  final double progressCellWidth;
  final DensityConfig config;

  const _DayRow({
    super.key,
    required this.day,
    required this.isToday,
    required this.isEven,
    required this.tasks,
    required this.taskCellWidth,
    required this.progressCellWidth,
    required this.config,
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
            height: config.rowHeight,
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
            height: config.rowHeight,
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
        height: config.rowHeight,
        isToday: isToday,
        isEven: isEven,
        child: TableDayProgress(
          completed: completedCount,
          total: applicableCount,
        ),
      ),
    );

    return RepaintBoundary(
      child: Container(
        height: config.rowHeight,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ColorsManager.mediumGray.withOpacity(0.06),
              width: 0.3,
            ),
          ),
        ),
        child: Row(children: cells),
      ),
    );
  }

  bool _isTaskApplicableForDay(RamadanTaskEntity task, int day) {
    if (task.type == TaskType.daily) return true;
    return task.createdForDay == day;
  }
}

// ────────────────────────────────────────────────────────────────
// Cell Wrapper
// ────────────────────────────────────────────────────────────────

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
              ? ColorsManager.primaryGold.withOpacity(0.04)
              : isEven
              ? ColorsManager.white
              : ColorsManager.lightGray.withOpacity(0.25),
      child: child,
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Task Header Cell with Tooltip
// ────────────────────────────────────────────────────────────────

class _TaskHeaderCell extends StatefulWidget {
  final RamadanTaskEntity task;
  final double width;
  final double height;
  final IconData icon;
  final DensityConfig config;

  const _TaskHeaderCell({
    required this.task,
    required this.width,
    required this.height,
    required this.icon,
    required this.config,
  });

  @override
  State<_TaskHeaderCell> createState() => _TaskHeaderCellState();
}

class _TaskHeaderCellState extends State<_TaskHeaderCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.task.title,
        waitDuration: const Duration(milliseconds: 500),
        child: GestureDetector(
          onLongPress: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.task.title),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color:
                  _isHovered
                      ? ColorsManager.primaryPurple.withOpacity(0.08)
                      : ColorsManager.primaryPurple.withOpacity(0.03),
              border: BorderDirectional(
                start: BorderSide(
                  color: ColorsManager.mediumGray.withOpacity(0.08),
                  width: 0.3,
                ),
              ),
            ),
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: widget.config.cellPadding.w,
              vertical: widget.config.cellPadding.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: widget.config.iconSize * 1.6.w,
                  height: widget.config.iconSize * 1.6.w,
                  decoration: BoxDecoration(
                    color:
                        widget.task.type == TaskType.daily
                            ? ColorsManager.primaryPurple.withOpacity(0.1)
                            : ColorsManager.primaryGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: widget.config.iconSize.sp,
                    color:
                        widget.task.type == TaskType.daily
                            ? ColorsManager.primaryPurple
                            : ColorsManager.primaryGold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.task.title,
                  style: TextStyles.labelSmall.copyWith(
                    fontSize: (widget.config.fontSize - 1).sp,
                    color: ColorsManager.primaryText,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Legend Item
// ────────────────────────────────────────────────────────────────

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
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.8),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyles.labelSmall.copyWith(
            color: ColorsManager.secondaryText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Empty Table State
// ────────────────────────────────────────────────────────────────

class _EmptyTableState extends StatelessWidget {
  const _EmptyTableState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsetsDirectional.all(32.w),
        padding: EdgeInsetsDirectional.all(32.w),
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: ColorsManager.mediumGray.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_on_rounded,
              size: 56.sp,
              color: ColorsManager.mediumGray.withOpacity(0.6),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد مهام بعد',
              style: TextStyles.titleMedium.copyWith(
                color: ColorsManager.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
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
