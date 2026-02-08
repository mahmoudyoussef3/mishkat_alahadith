import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import '../../domain/entities/ramadan_task_entity.dart';
import '../cubit/ramadan_tasks_cubit.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/calendar_button.dart';
import '../widgets/day_selector.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/ramadan_calendar_sheet.dart';
import '../widgets/ramadan_progress.dart';
import '../widgets/ramadan_task_item.dart';
import '../widgets/section_header.dart';
import '../widgets/view_mode_tabs.dart';
import '../widgets/week_selector.dart';

class RamadanTasksPage extends StatelessWidget {
  const RamadanTasksPage({super.key});

    String _hijriDateString() {
    final hijri = HijriCalendar.now();
    HijriCalendar.setLocal('ar');
    return '${_toArabicNumerals(hijri.hDay)} ${hijri.getLongMonthName()} ${_toArabicNumerals(hijri.hYear)} هـ';
  }
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.primaryBackground,
        floatingActionButton: const _AddTaskFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: RefreshIndicator(
          color: ColorsManager.primaryPurple,
          onRefresh: () => context.read<RamadanTasksCubit>().init(),
          child: CustomScrollView(
            slivers: [
              
              BuildHeaderAppBar(
                title: 'مشكاة في رمضان',
                description: "أنشئ خطتك الخاصة لشهر رمضان",
                home: false,
                bottomNav: false,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              SliverPadding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                sliver: BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
                  builder: (context, state) {
                    if (state is RamadanTasksLoading) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorsManager.primaryPurple,
                          ),
                        ),
                      );
                    }
                    if (state is RamadanTasksError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: RamadanErrorView(message: state.message),
                      );
                    }
                    final s = state as RamadanTasksLoaded;
                    return _LoadedBody(state: s);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Page-level private helper widgets
// ══════════════════════════════════════════════════════════════

/// FAB that shows only when not in history mode.
class _AddTaskFab extends StatelessWidget {
  const _AddTaskFab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
      buildWhen: (prev, curr) {
        if (curr is! RamadanTasksLoaded) return true;
        if (prev is! RamadanTasksLoaded) return true;
        return prev.viewMode != curr.viewMode;
      },
      builder: (context, state) {
        if (state is RamadanTasksLoaded && state.viewMode != ViewMode.history) {
          return FloatingActionButton.extended(
            backgroundColor: ColorsManager.primaryPurple,
            foregroundColor: ColorsManager.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'إضافة مهمة',
              style: TextStyles.titleSmall.copyWith(color: ColorsManager.white),
            ),
            onPressed: () => showAddTaskSheet(context),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final RamadanTasksLoaded state;
  const _LoadedBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return SliverList(
      delegate: SliverChildListDelegate([
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
        SizedBox(height: 80.h),
      ]),
    );
  }
}
