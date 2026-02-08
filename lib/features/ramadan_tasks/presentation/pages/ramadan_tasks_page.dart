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
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<RamadanTasksCubit>().init(),
            child: CustomScrollView(
              slivers: [
                const BuildHeaderAppBar(
                  title: 'مشكاة في رمضان',
                  description: 'تابع إنجازك اليومي والشهري بروح رمضانية',
                  home: false,
                  bottomNav: false,
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
                    child: BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
                      builder: (context, state) {
                        if (state is RamadanTasksLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is RamadanTasksError) {
                          return Text(
                            state.message,
                            style: TextStyles.bodyMedium.copyWith(
                              color: ColorsManager.error,
                            ),
                          );
                        }
                        final s = state as RamadanTasksLoaded;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RamadanProgress(
                              todayDay: s.todayDay,
                              dailyPercent: s.dailyPercent,
                              monthlyPercent: s.monthlyPercent,
                              weeklyPercent: s.weeklyPercent,
                              motivationalText: s.motivationalText,
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorsManager.primaryPurple,
                                      foregroundColor: ColorsManager.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                    ),
                                    onPressed: () => _showAddTaskSheet(context),
                                    icon: const Icon(Icons.add_task),
                                    label: Text(
                                      'إضافة مهمة',
                                      style: TextStyles.buttonText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'قائمة المهام',
                              style: TextStyles.headlineMedium,
                            ),
                            SizedBox(height: 8.h),
                            ...s.tasks.map(
                              (t) => RamadanTaskItem(
                                task: t,
                                todayDay: s.todayDay,
                                onToggleDaily:
                                    () => context
                                        .read<RamadanTasksCubit>()
                                        .toggleDaily(t.id),
                                onToggleMonthly:
                                    (completed) => context
                                        .read<RamadanTasksCubit>()
                                        .setMonthly(t.id, completed),
                                onDelete:
                                    () => context
                                        .read<RamadanTasksCubit>()
                                        .deleteById(t.id),
                              ),
                            ),
                            if (s.tasks.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 24.h),
                                child: Text(
                                  'لا توجد مهام بعد. أضف مهامك لبدء المتابعة.',
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: ColorsManager.secondaryText,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    TaskType selectedType = TaskType.daily;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: 16.w,
                end: 16.w,
                top: 16.h,
                bottom: 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إضافة مهمة جديدة', style: TextStyles.headlineMedium),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: titleController,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      hintText: 'عنوان المهمة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text('نوع المهمة', style: TextStyles.titleMedium),
                  RadioListTile<TaskType>(
                    value: TaskType.daily,
                    groupValue: selectedType,
                    title: const Text('يومية'),
                    onChanged: (v) {
                      selectedType = v ?? TaskType.daily;
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  RadioListTile<TaskType>(
                    value: TaskType.monthly,
                    groupValue: selectedType,
                    title: const Text('شهرية (مرة واحدة)'),
                    onChanged: (v) {
                      selectedType = v ?? TaskType.monthly;
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryGold,
                      ),
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isNotEmpty) {
                          context.read<RamadanTasksCubit>().addNewTask(
                            title: title,
                            type: selectedType,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'إضافة',
                        style: TextStyles.buttonText.copyWith(
                          color: ColorsManager.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
