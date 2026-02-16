import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import '../../../domain/entities/ramadan_task_entity.dart';
import '../../cubit/ramadan_tasks_cubit.dart';
import 'fullscreen_table_overlay.dart';
import 'grid_cells/grid_checkbox_cell.dart';
import 'grid_cells/grid_corner_cell.dart';
import 'grid_cells/grid_day_cell.dart';
import 'grid_cells/grid_header_cell.dart';
import 'grid_cells/grid_progress_cell.dart';
import 'table_utils.dart';

const int _kDays = 30;

const Color _headerBg = ColorsManager.primaryPurple;
const Color _headerBorderBottom = Color(0xFF6435CC);
const Color _oddRowBg = Color(0xFFF8F5FF);
const Color _evenRowBg = ColorsManager.white;
const Color _todayRowBg = Color(0xFFFFF8E1);
const Color _todayBorder = ColorsManager.primaryGold;
const Color _gridLine = Color(0xFFEEEEEE);
const Color _pinnedColLine = Color(0xFFE0E0E0);

class RamadanTableView extends StatefulWidget {
  final List<RamadanTaskEntity> allTasks;
  final int todayDay;
  final double overallPercent;
  final bool isFullscreen;

  const RamadanTableView({
    super.key,
    required this.allTasks,
    required this.todayDay,
    required this.overallPercent,
    this.isFullscreen = false,
  });

  @override
  State<RamadanTableView> createState() => _RamadanTableViewState();
}

class _RamadanTableViewState extends State<RamadanTableView> {
  final ScrollController _vCtrl = ScrollController();
  bool _scrolled = false;

  static const double _minDayCellW = 58;
  static const double _minTaskCellW = 54;
  static const double _minProgressCellW = 66;

  double get _rowHeight => 50.w.clamp(40, 62).toDouble();
  double get _headerHeight => 58.w.clamp(48, 70).toDouble();

  double _dayCellW = 58;
  double _taskCellW = 54;
  double _progressCellW = 66;

  @override
  void dispose() {
    _vCtrl.dispose();
    super.dispose();
  }

  void _autoScrollToToday() {
    if (_scrolled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_vCtrl.hasClients) return;
      _scrolled = true;
      _animateToToday();
    });
  }

  void _animateToToday() {
    if (!_vCtrl.hasClients) return;
    final vp = _vCtrl.position.viewportDimension;
    final target =
        (widget.todayDay - 1) * _rowHeight +
        _headerHeight -
        vp / 2 +
        _rowHeight / 2;
    _vCtrl.animateTo(
      target.clamp(0.0, _vCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.allTasks;
    if (tasks.isEmpty) return const _EmptyState();

    final colCount = tasks.length + 2;
    const rowCount = _kDays + 1;

    _autoScrollToToday();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // ── Action bar (only in normal mode) ──
          if (!widget.isFullscreen)
            _TableActionBar(
              onExpand: () => FullscreenTableOverlay.show(context),
            ),
          // ── Table ──
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableW = constraints.maxWidth - 16.w;
                final fixedW = _minDayCellW.w + _minProgressCellW.w;
                final taskCount = tasks.length;
                final minTotalTaskW = taskCount * _minTaskCellW.w;
                final minTotalW = fixedW + minTotalTaskW;

                if (minTotalW < availableW && taskCount > 0) {
                  final extra = availableW - fixedW;
                  _taskCellW = extra / taskCount;
                  _dayCellW = _minDayCellW.w;
                  _progressCellW = _minProgressCellW.w;
                } else {
                  _dayCellW = _minDayCellW.w;
                  _taskCellW = _minTaskCellW.w;
                  _progressCellW = _minProgressCellW.w;
                }

                final hPad = 8.w;
                final vPad = 4.h;
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: hPad,
                    end: hPad,
                    top: widget.isFullscreen ? 0 : vPad,
                    bottom: vPad,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorsManager.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: ColorsManager.primaryPurple.withValues(
                            alpha: 0.10,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Stack(
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: TableView.builder(
                              columnCount: colCount,
                              rowCount: rowCount,
                              pinnedColumnCount: 1,
                              pinnedRowCount: 1,
                              verticalDetails: ScrollableDetails.vertical(
                                controller: _vCtrl,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                              ),

                              horizontalDetails: const ScrollableDetails(
                                direction: AxisDirection.left,
                                physics: BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                              ),
                              columnBuilder:
                                  (int c) => _colSpan(c, tasks.length),
                              rowBuilder: _rowSpan,
                              cellBuilder:
                                  (BuildContext ctx, TableVicinity v) =>
                                      _cell(ctx, v, tasks),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Column spans ────────────────────────────────────────────

  TableSpan _colSpan(int c, int taskCount) {
    final double w;
    if (c == 0) {
      w = _dayCellW;
    } else if (c <= taskCount) {
      w = _taskCellW;
    } else {
      w = _progressCellW;
    }

    return TableSpan(
      extent: FixedTableSpanExtent(w),
      backgroundDecoration:
          c == 0
              ? const TableSpanDecoration(
                border: TableSpanBorder(
                  trailing: BorderSide(color: _pinnedColLine, width: 1),
                ),
              )
              : null,
    );
  }

  TableSpan _rowSpan(int r) {
    if (r == 0) {
      return TableSpan(
        extent: FixedTableSpanExtent(_headerHeight),
        backgroundDecoration: const TableSpanDecoration(
          color: _headerBg,
          border: TableSpanBorder(
            trailing: BorderSide(color: _headerBorderBottom, width: 1),
          ),
        ),
      );
    }

    final isToday = r == widget.todayDay;
    final isOdd = (r - 1).isOdd;

    final Color bg;
    if (isToday) {
      bg = _todayRowBg;
    } else if (isOdd) {
      bg = _oddRowBg;
    } else {
      bg = _evenRowBg;
    }

    return TableSpan(
      extent: FixedTableSpanExtent(_rowHeight),
      backgroundDecoration: TableSpanDecoration(
        color: bg,
        border:
            isToday
                ? const TableSpanBorder(
                  leading: BorderSide(color: _todayBorder, width: 2),
                  trailing: BorderSide(color: _todayBorder, width: 2),
                )
                : const TableSpanBorder(
                  trailing: BorderSide(color: _gridLine, width: 0.5),
                ),
      ),
    );
  }

  TableViewCell _cell(
    BuildContext context,
    TableVicinity v,
    List<RamadanTaskEntity> tasks,
  ) {
    final r = v.row;
    final c = v.column;

    if (r == 0) {
      if (c == 0) return const TableViewCell(child: GridCornerCell());
      if (c <= tasks.length) {
        final t = tasks[c - 1];
        return TableViewCell(
          child: GridHeaderCell(
            title: t.title,
            icon: taskIconForTitle(t),
            taskType: t.type,
            task: t,
          ),
        );
      }
      return TableViewCell(
        child: Center(
          child: Icon(
            Icons.pie_chart_rounded,
            size: 18.sp,
            color: ColorsManager.white.withValues(alpha: 0.85),
          ),
        ),
      );
    }

    final day = r;

    if (c == 0) {
      return TableViewCell(
        child: GridDayCell(day: day, isToday: day == widget.todayDay),
      );
    }

    if (c <= tasks.length) {
      final task = tasks[c - 1];
      final ok = task.type == TaskType.daily || task.createdForDay == day;
      final done = ok && task.completedDays.contains(day);
      final isFuture = day > widget.todayDay;
      return TableViewCell(
        child: GridCheckboxCell(
          isApplicable: ok,
          isCompleted: done,
          onToggle:
              ok && !isFuture
                  ? () {
                    final cubit = context.read<RamadanTasksCubit>();
                    task.type == TaskType.daily
                        ? cubit.toggleDaily(task.id, day: day)
                        : cubit.toggleTodayOnly(task.id, day: day);
                  }
                  : null,
        ),
      );
    }

    int done = 0, total = 0;
    for (final t in tasks) {
      if (t.type == TaskType.daily || t.createdForDay == day) {
        total++;
        if (t.completedDays.contains(day)) done++;
      }
    }
    return TableViewCell(
      child: GridProgressCell(completed: done, total: total),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.grid_on_rounded,
              size: 36.sp,
              color: ColorsManager.primaryPurple.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد مهام بعد',
            style: TextStyles.titleMedium.copyWith(
              color: ColorsManager.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'أضف عباداتك لترى الجدول',
            style: TextStyles.bodySmall.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Action bar with expand & rotate icons (shown in normal mode)
// ────────────────────────────────────────────────────────────────

class _TableActionBar extends StatelessWidget {
  final VoidCallback onExpand;

  const _TableActionBar({required this.onExpand});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, bottom: 4.h),
      child: Row(
        children: [
          // Expand fullscreen
          _ActionChip(
            icon: Icons.open_in_full_rounded,
            label: 'عرض كامل',
            onTap: onExpand,
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.primaryPurple.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 10.w,
            vertical: 6.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: ColorsManager.primaryPurple),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyles.labelSmall.copyWith(
                  color: ColorsManager.primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
