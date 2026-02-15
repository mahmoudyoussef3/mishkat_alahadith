import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

import '../../../domain/entities/ramadan_task_entity.dart';
import '../../cubit/ramadan_tasks_cubit.dart';
import '../calendar_button.dart';
import '../day_selector.dart';
import '../delete_confirm_dialog.dart';
import '../empty_state.dart';
import '../monthly_tasks_sheet.dart';
import '../ramadan_calendar_sheet.dart';
import '../ramadan_progress.dart';
import '../ramadan_task_item.dart';
import '../section_header.dart';
import '../view_mode_tabs.dart';
import '../week_selector.dart';

/// Full-screen card/list view for Ramadan tasks.
///
/// This is the original card-based presentation extracted into a
/// standalone widget that fills all available space.
/// It renders inside its own scroll context to avoid
/// nested-scroll issues.
class RamadanCardView extends StatelessWidget {
  final RamadanTasksLoaded state;

  const RamadanCardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return ListView(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      children: [
        SizedBox(height: 4.h),

        // ── Progress card ──
        RamadanProgress(
          todayDay: s.displayDay,
          dailyPercent: s.dailyPercent,
          overallPercent: s.overallPercent,
          weeklyPercent: s.weeklyPercent,
          dailyCompleted: s.dailyCompleted,
          dailyTotal: s.dailyTotal,
          motivationalText:
              s.viewMode == ViewMode.today ? s.motivationalText : null,
        ),
        SizedBox(height: 16.h),

        // ── Monthly plan button ──
        _MonthlySheetButton(
          onTap:
              () => MonthlyTasksSheet.show(
                context,
                allTasks: s.allTasks,
                todayDay: s.todayDay,
              ),
        ),
        SizedBox(height: 12.h),

        // ── View mode tabs + calendar ──
        Row(
          children: [
            Expanded(
              child: ViewModeTabs(
                viewMode: s.viewMode,
                onChange:
                    (m) => context.read<RamadanTasksCubit>().setViewMode(m),
              ),
            ),
            SizedBox(width: 8.w),
            CalendarButton(
              onTap:
                  () => RamadanCalendarSheet.show(
                    context,
                    allTasks: s.allTasks,
                    todayDay: s.todayDay,
                  ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── History selectors ──
        if (s.viewMode == ViewMode.history) ...[
          WeekSelector(
            selectedWeek: s.selectedWeek,
            onSelected:
                (w) => context.read<RamadanTasksCubit>().setSelectedWeek(w),
          ),
          SizedBox(height: 10.h),
          DaySelector(
            selectedDay: s.selectedDay,
            start: s.weekStart,
            end: s.weekEnd,
            todayDay: s.todayDay,
            onSelect:
                (d) => context.read<RamadanTasksCubit>().setSelectedDay(d),
          ),
          SizedBox(height: 12.h),
        ],

        // ── Section header ──
        SectionHeader(
          title:
              s.viewMode == ViewMode.history
                  ? 'سجل اليوم ${s.selectedDay}'
                  : 'قائمة المهام',
          count: s.filteredTasks.length,
        ),
        SizedBox(height: 8.h),

        // ── Task list ──
        if (s.filteredTasks.isEmpty)
          RamadanEmptyState(viewMode: s.viewMode)
        else
          ...s.filteredTasks.map(
            (t) => Padding(
              padding: EdgeInsetsDirectional.only(bottom: 8.h),
              child: RamadanTaskItem(
                key: ValueKey('task_${t.id}_${s.displayDay}'),
                task: t,
                todayDay: s.displayDay,
                readOnly: s.isReadOnly,
                onToggle: () {
                  if (t.type == TaskType.daily) {
                    context.read<RamadanTasksCubit>().toggleDaily(t.id);
                  } else {
                    context.read<RamadanTasksCubit>().toggleTodayOnly(t.id);
                  }
                },
                onDelete: () => showDeleteConfirmDialog(context, t),
              ),
            ),
          ),

        // Bottom padding for FAB
        SizedBox(height: 88.h),
      ],
    );
  }
}

/// Button that opens the full monthly tasks sheet.
class _MonthlySheetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MonthlySheetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryPurple.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: ColorsManager.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.view_list_rounded,
                color: ColorsManager.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عرض الخطة الشهرية',
                    style: TextStyles.titleMedium.copyWith(
                      color: ColorsManager.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'تصفّح مهامك لكل يوم من ١ إلى ٣٠',
                    style: TextStyles.bodySmall.copyWith(
                      color: ColorsManager.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: ColorsManager.white.withOpacity(0.6),
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
