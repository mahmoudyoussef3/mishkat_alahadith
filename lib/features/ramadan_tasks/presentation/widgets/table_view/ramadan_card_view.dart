import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/ramadan_task_entity.dart';
import '../../cubit/ramadan_tasks_cubit.dart';
import '../day_selector.dart';
import '../delete_confirm_dialog.dart';
import '../empty_state.dart';
import '../ramadan_task_item.dart';
import '../section_header.dart';
import '../week_selector.dart';

class RamadanCardView extends StatelessWidget {
  final RamadanTasksLoaded state;

  const RamadanCardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return ListView(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      children: [
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
