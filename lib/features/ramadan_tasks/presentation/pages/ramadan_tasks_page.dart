import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import '../cubit/ramadan_tasks_cubit.dart';
import '../../domain/entities/ramadan_task_entity.dart';
import '../widgets/ramadan_task_item.dart';
import '../widgets/ramadan_progress.dart';

class RamadanTasksPage extends StatelessWidget {
  const RamadanTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.primaryBackground,
        floatingActionButton: BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
          buildWhen: (prev, curr) {
            if (curr is! RamadanTasksLoaded) return true;
            if (prev is! RamadanTasksLoaded) return true;
            return prev.viewMode != curr.viewMode;
          },
          builder: (context, state) {
            if (state is RamadanTasksLoaded &&
                state.viewMode != ViewMode.history) {
              return FloatingActionButton.extended(
                backgroundColor: ColorsManager.primaryPurple,
                foregroundColor: ColorsManager.white,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  'إضافة مهمة',
                  style: TextStyles.titleSmall.copyWith(
                    color: ColorsManager.white,
                  ),
                ),
                onPressed: () => _showAddTaskSheet(context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: SafeArea(
          child: RefreshIndicator(
            color: ColorsManager.primaryPurple,
            onRefresh: () => context.read<RamadanTasksCubit>().init(),
            child: CustomScrollView(
              slivers: [
                const BuildHeaderAppBar(
                  title: 'مهام رمضان',
                  description: 'تابع إنجازك اليومي والشهري بروح رمضانية',
                  home: false,
                  bottomNav: false,
                ),
                // ── Main content ──
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
                          child: _ErrorView(message: state.message),
                        );
                      }
                      final s = state as RamadanTasksLoaded;
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          // ── Progress card ──
                          RamadanProgress(
                            todayDay: s.displayDay,
                            dailyPercent: s.dailyPercent,
                            monthlyPercent: s.monthlyPercent,
                            weeklyPercent: s.weeklyPercent,
                            dailyCompleted: s.dailyCompleted,
                            dailyTotal: s.dailyTotal,
                            motivationalText:
                                s.viewMode == ViewMode.today
                                    ? s.motivationalText
                                    : null,
                          ),
                          SizedBox(height: 16.h),

                          // ── View mode tabs ──
                          _ViewTabs(
                            viewMode: s.viewMode,
                            onChange:
                                (m) => context
                                    .read<RamadanTasksCubit>()
                                    .setViewMode(m),
                          ),
                          SizedBox(height: 12.h),

                          // ── History selectors ──
                          if (s.viewMode == ViewMode.history) ...[
                            _WeekSelector(
                              selectedWeek: s.selectedWeek,
                              onSelected:
                                  (w) => context
                                      .read<RamadanTasksCubit>()
                                      .setSelectedWeek(w),
                            ),
                            SizedBox(height: 10.h),
                            _DaySelector(
                              selectedDay: s.selectedDay,
                              start: s.weekStart,
                              end: s.weekEnd,
                              todayDay: s.todayDay,
                              onSelect:
                                  (d) => context
                                      .read<RamadanTasksCubit>()
                                      .setSelectedDay(d),
                            ),
                            SizedBox(height: 12.h),
                          ],

                          // ── Section header ──
                          _SectionHeader(
                            title:
                                s.viewMode == ViewMode.history
                                    ? 'سجل اليوم ${s.selectedDay}'
                                    : 'قائمة المهام',
                            count: s.filteredTasks.length,
                          ),
                          SizedBox(height: 8.h),

                          // ── Task list ──
                          if (s.filteredTasks.isEmpty)
                            _EmptyState(viewMode: s.viewMode)
                          else
                            ...s.filteredTasks.map(
                              (t) => Padding(
                                padding: EdgeInsetsDirectional.only(
                                  bottom: 8.h,
                                ),
                                child: RamadanTaskItem(
                                  key: ValueKey('task_${t.id}_${s.displayDay}'),
                                  task: t,
                                  todayDay: s.displayDay,
                                  readOnly: s.isReadOnly,
                                  onToggleDaily:
                                      () => context
                                          .read<RamadanTasksCubit>()
                                          .toggleDaily(t.id),
                                  onToggleMonthly:
                                      (completed) => context
                                          .read<RamadanTasksCubit>()
                                          .setMonthly(t.id, completed),
                                  onDelete: () => _confirmDelete(context, t),
                                ),
                              ),
                            ),

                          // Bottom padding for FAB
                          SizedBox(height: 80.h),
                        ]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete confirmation ─────────────────────────────────────
  void _confirmDelete(BuildContext context, RamadanTaskEntity task) {
    showDialog(
      context: context,
      builder:
          (dialogCtx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text('حذف المهمة', style: TextStyles.headlineSmall),
              content: Text(
                'هل أنت متأكد من حذف "${task.title}"؟',
                style: TextStyles.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    'إلغاء',
                    style: TextStyles.titleSmall.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    context.read<RamadanTasksCubit>().deleteById(task.id);
                  },
                  child: Text(
                    'حذف',
                    style: TextStyles.titleSmall.copyWith(
                      color: ColorsManager.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ── Add task bottom sheet ────────────────────────────────────
  void _showAddTaskSheet(BuildContext parentContext) {
    final cubit = parentContext.read<RamadanTasksCubit>();
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: ColorsManager.secondaryBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsetsDirectional.only(
              start: 20.w,
              end: 20.w,
              top: 12.h,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20.h,
            ),
            child: StatefulBuilder(
              builder: (sbContext, setSheetState) {
                return _AddTaskSheetBody(
                  titleController: titleController,
                  onAdd: (title, type) {
                    if (title.trim().isNotEmpty) {
                      cubit.addNewTask(title: title, type: type);
                      Navigator.pop(sheetContext);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ══════════════════════════════════════════════════════════════

/// Bottom sheet body extracted to its own StatefulWidget so radio
/// buttons rebuild properly without hacks like `markNeedsBuild`.
class _AddTaskSheetBody extends StatefulWidget {
  final TextEditingController titleController;
  final void Function(String title, TaskType type) onAdd;

  const _AddTaskSheetBody({required this.titleController, required this.onAdd});

  @override
  State<_AddTaskSheetBody> createState() => _AddTaskSheetBodyState();
}

class _AddTaskSheetBodyState extends State<_AddTaskSheetBody> {
  TaskType _selectedType = TaskType.daily;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: ColorsManager.mediumGray,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 16.h),
        Text('إضافة مهمة جديدة', style: TextStyles.headlineSmall),
        SizedBox(height: 16.h),

        // Title field
        TextField(
          controller: widget.titleController,
          textDirection: TextDirection.rtl,
          style: TextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'مثال: قراءة جزء من القرآن',
            hintStyle: TextStyles.bodyMedium.copyWith(
              color: ColorsManager.secondaryText,
            ),
            filled: true,
            fillColor: ColorsManager.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: ColorsManager.primaryPurple,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Type selector — pill buttons instead of RadioListTile
        Text('نوع المهمة', style: TextStyles.titleMedium),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _TypePill(
                label: 'يومية',
                subtitle: 'تتكرر كل يوم',
                icon: Icons.replay_rounded,
                isSelected: _selectedType == TaskType.daily,
                onTap: () => setState(() => _selectedType = TaskType.daily),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _TypePill(
                label: 'شهرية',
                subtitle: 'مرة واحدة',
                icon: Icons.check_circle_outline_rounded,
                isSelected: _selectedType == TaskType.monthly,
                onTap: () => setState(() => _selectedType = TaskType.monthly),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // Add button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryPurple,
              foregroundColor: ColorsManager.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            onPressed:
                () => widget.onAdd(widget.titleController.text, _selectedType),
            child: Text(
              'إضافة',
              style: TextStyles.titleMedium.copyWith(
                color: ColorsManager.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pill-style type selector for the add-task sheet.
class _TypePill extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypePill({
    required this.label,
    required this.subtitle,
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
        curve: Curves.easeOutCubic,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorsManager.primaryPurple.withOpacity(0.1)
                  : ColorsManager.lightGray,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected
                    ? ColorsManager.primaryPurple
                    : ColorsManager.mediumGray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? ColorsManager.primaryPurple
                      : ColorsManager.secondaryText,
              size: 24.sp,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyles.titleSmall.copyWith(
                color:
                    isSelected
                        ? ColorsManager.primaryPurple
                        : ColorsManager.primaryText,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyles.bodySmall.copyWith(
                color: ColorsManager.secondaryText,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab bar for switching between Today / History / All views.
class _ViewTabs extends StatelessWidget {
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onChange;
  const _ViewTabs({required this.viewMode, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(4.w),
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _tab('اليوم', Icons.today_rounded, ViewMode.today),
          SizedBox(width: 4.w),
          _tab('السجل', Icons.history_rounded, ViewMode.history),
          SizedBox(width: 4.w),
          _tab('الكل', Icons.list_alt_rounded, ViewMode.all),
        ],
      ),
    );
  }

  Widget _tab(String label, IconData icon, ViewMode mode) {
    final selected = viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsetsDirectional.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? ColorsManager.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: ColorsManager.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color:
                    selected
                        ? ColorsManager.primaryPurple
                        : ColorsManager.secondaryText,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyles.titleSmall.copyWith(
                  color:
                      selected
                          ? ColorsManager.primaryPurple
                          : ColorsManager.secondaryText,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrollable week selector for History mode.
class _WeekSelector extends StatelessWidget {
  final int selectedWeek;
  final ValueChanged<int> onSelected;
  const _WeekSelector({required this.selectedWeek, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const labels = ['الأسبوع ١', 'الأسبوع ٢', 'الأسبوع ٣', 'الأسبوع ٤'];
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.zero,
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final week = i + 1;
          final selected = week == selectedWeek;
          return GestureDetector(
            onTap: () => onSelected(week),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    selected
                        ? ColorsManager.primaryPurple
                        : ColorsManager.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color:
                      selected
                          ? ColorsManager.primaryPurple
                          : ColorsManager.mediumGray,
                ),
                boxShadow:
                    selected
                        ? [
                          BoxShadow(
                            color: ColorsManager.primaryPurple.withOpacity(
                              0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                labels[i],
                style: TextStyles.titleSmall.copyWith(
                  color:
                      selected
                          ? ColorsManager.white
                          : ColorsManager.primaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Horizontal day chips for picking a specific day in History mode.
class _DaySelector extends StatelessWidget {
  final int selectedDay;
  final int start;
  final int end;
  final int todayDay;
  final ValueChanged<int> onSelect;

  const _DaySelector({
    required this.selectedDay,
    required this.start,
    required this.end,
    required this.todayDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final days = List<int>.generate(end - start + 1, (i) => start + i);
    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.zero,
        itemCount: days.length,
        separatorBuilder: (_, __) => SizedBox(width: 6.w),
        itemBuilder: (_, idx) {
          final d = days[idx];
          final selected = d == selectedDay;
          final isToday = d == todayDay;
          return GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    selected
                        ? ColorsManager.primaryPurple
                        : ColorsManager.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color:
                      selected
                          ? ColorsManager.primaryPurple
                          : isToday
                          ? ColorsManager.primaryGold
                          : ColorsManager.mediumGray,
                  width: isToday && !selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                '$d',
                style: TextStyles.titleSmall.copyWith(
                  color:
                      selected
                          ? ColorsManager.white
                          : isToday
                          ? ColorsManager.primaryGold
                          : ColorsManager.primaryText,
                  fontWeight:
                      selected || isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Section header with task count badge.
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: TextStyles.headlineSmall),
        const Spacer(),
        Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 10.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: ColorsManager.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$count',
            style: TextStyles.titleSmall.copyWith(
              color: ColorsManager.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }
}

/// Friendly empty state with illustration icon and message.
class _EmptyState extends StatelessWidget {
  final ViewMode viewMode;
  const _EmptyState({required this.viewMode});

  @override
  Widget build(BuildContext context) {
    final (icon, message) = switch (viewMode) {
      ViewMode.today => (
        Icons.task_alt_rounded,
        'لا توجد مهام لليوم.\nاضغط + لإضافة مهمة جديدة.',
      ),
      ViewMode.history => (
        Icons.history_rounded,
        'لا توجد مهام مسجّلة لهذا اليوم.',
      ),
      ViewMode.all => (
        Icons.playlist_add_rounded,
        'لم تُضف أي مهام بعد.\nاضغط + لتبدأ.',
      ),
    };

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36.sp,
                color: ColorsManager.primaryPurple.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state with retry button.
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.sp,
            color: ColorsManager.error,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyles.bodyMedium.copyWith(color: ColorsManager.error),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryPurple,
              foregroundColor: ColorsManager.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => context.read<RamadanTasksCubit>().init(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'إعادة المحاولة',
              style: TextStyles.titleSmall.copyWith(color: ColorsManager.white),
            ),
          ),
        ],
      ),
    );
  }
}
