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

/// Card-based list view for tasks - optimized for scrolling performance
class RamadanCardView extends StatelessWidget {
  final RamadanTasksLoaded state;

  const RamadanCardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    return ListView.builder(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 0, 16.w, 88.h),
      itemCount: _calculateItemCount(s),
      itemBuilder: (context, index) => _buildItemAtIndex(context, s, index),
    );
  }

  int _calculateItemCount(RamadanTasksLoaded s) {
    int count = 0;

    // History selectors
    if (s.viewMode == ViewMode.history) {
      count += 3; // WeekSelector + spacing + DaySelector + spacing
    }

    // Section header + spacing
    count += 2;

    // Tasks or empty state
    if (s.filteredTasks.isEmpty) {
      count += 1;
    } else {
      count += s.filteredTasks.length;
    }

    return count;
  }

  Widget _buildItemAtIndex(
    BuildContext context,
    RamadanTasksLoaded s,
    int index,
  ) {
    int currentIndex = index;

    // History selectors
    if (s.viewMode == ViewMode.history) {
      if (currentIndex == 0) {
        return WeekSelector(
          selectedWeek: s.selectedWeek,
          onSelected:
              (w) => context.read<RamadanTasksCubit>().setSelectedWeek(w),
        );
      }
      if (currentIndex == 1) return SizedBox(height: 10.h);
      if (currentIndex == 2) {
        return DaySelector(
          selectedDay: s.selectedDay,
          start: s.weekStart,
          end: s.weekEnd,
          todayDay: s.todayDay,
          onSelect: (d) => context.read<RamadanTasksCubit>().setSelectedDay(d),
        );
      }
      if (currentIndex == 3) return SizedBox(height: 12.h);
      currentIndex -= 4;
    }

    // Section header
    if (currentIndex == 0) {
      return SectionHeader(
        title:
            s.viewMode == ViewMode.history
                ? 'سجل اليوم ${s.selectedDay}'
                : 'قائمة المهام',
        count: s.filteredTasks.length,
      );
    }
    if (currentIndex == 1) return SizedBox(height: 8.h);
    currentIndex -= 2;

    // Tasks or empty state
    if (s.filteredTasks.isEmpty) {
      if (currentIndex == 0) {
        return RamadanEmptyState(viewMode: s.viewMode);
      }
    } else {
      if (currentIndex < s.filteredTasks.length) {
        final task = s.filteredTasks[currentIndex];
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: 8.h),
          child: RamadanTaskItem(
            key: ValueKey('task_${task.id}_${s.displayDay}'),
            task: task,
            todayDay: s.displayDay,
            readOnly: s.isReadOnly,
            onToggle: () {
              if (task.type == TaskType.daily) {
                context.read<RamadanTasksCubit>().toggleDaily(task.id);
              } else {
                context.read<RamadanTasksCubit>().toggleTodayOnly(task.id);
              }
            },
            onDelete: () => showDeleteConfirmDialog(context, task),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}
