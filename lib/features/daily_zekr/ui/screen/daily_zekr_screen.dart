import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/theming/daily_zekr_decorations.dart';
import 'package:mishkat_almasabih/core/theming/daily_zekr_styles.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/models/personal_task.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/models/zekr_item.dart';
import 'package:mishkat_almasabih/features/daily_zekr/logic/cubit/personal_tasks_cubit.dart';
import 'package:mishkat_almasabih/features/daily_zekr/logic/cubit/daily_zekr_cubit.dart';
import 'package:mishkat_almasabih/features/daily_zekr/ui/widgets/zekr_card.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';

class DailyZekrScreen extends StatelessWidget {
  const DailyZekrScreen({super.key});

  // Uses same default Cairo settings as PrayerTimesScreen.
  PrayerCalculator _buildPrayerCalculator() {
    return PrayerCalculator(
      latitude: 30.0444,
      longitude: 31.2357,
      timezone: 2.0,
      asrMethod: AsrMethod.hanafi,
    );
  }

  ({bool enabled, String? footerText, IconData? footerIcon}) _availabilityFor(
    ZekrSection section,
    DateTime now,
  ) {
    if (section != ZekrSection.morningAdhkar &&
        section != ZekrSection.eveningAdhkar) {
      return (enabled: true, footerText: null, footerIcon: null);
    }

    final calculator = _buildPrayerCalculator();
    final dayStart = DateTime(now.year, now.month, now.day);
    final today = calculator.calculate(dayStart);
    final yesterday = calculator.calculate(
      dayStart.subtract(const Duration(days: 1)),
    );
    final tomorrow = calculator.calculate(
      dayStart.add(const Duration(days: 1)),
    );

    late final DateTime windowStart;
    late final DateTime windowEnd;

    if (section == ZekrSection.morningAdhkar) {
      windowStart = today.fajr;
      windowEnd = today.dhuhr;
    } else {
      // Evening adhkar: from Asr until next Fajr.
      final isAfterMidnightBeforeFajr = now.isBefore(today.fajr);
      if (isAfterMidnightBeforeFajr) {
        windowStart = yesterday.asr;
        windowEnd = today.fajr;
      } else {
        windowStart = today.asr;
        windowEnd = tomorrow.fajr;
      }
    }

    final enabled = now.isAfter(windowStart) && now.isBefore(windowEnd);

    if (enabled) {
      return (enabled: true, footerText: null, footerIcon: null);
    }
    return (
      enabled: false,
      footerText: 'غير متاح الآن',
      footerIcon: Icons.lock_clock_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        bottomNavigationBar: _buildAddTaskButton(context),
        body: SafeArea(
          top: false,
          bottom: true,

          child: CustomScrollView(
            slivers: [
              const BuildHeaderAppBar(
                title: 'الذكر اليومي',
                description: 'نُذَكِّرُكَ بلطف: الأذكار والورد وحديث اليوم',
                pinned: true,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverToBoxAdapter(child: _buildInfoCard()),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
                  child: Text(
                    'اختر ما أنجزته اليوم:',
                    style: DailyZekrTextStyles.sectionHeaderTitle,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 14.h)),
              SliverToBoxAdapter(
                child: BlocBuilder<DailyZekrCubit, DailyZekrState>(
                  builder: (context, state) {
                    if (state is DailyZekrLoading ||
                        state is DailyZekrInitial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state is DailyZekrError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            state.message,
                            style: TextStyles.bodyLarge,
                          ),
                        ),
                      );
                    }
                    final items = (state as DailyZekrLoaded).items;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 600;
                        final content =
                            isWide
                                ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsetsDirectional.only(
                                    start: 16.w,
                                    end: 16.w,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12.w,
                                        mainAxisSpacing: 12.h,
                                        childAspectRatio: 3.6,
                                      ),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    IconData icon;
                                    switch (item.section) {
                                      case ZekrSection.hadithDaily:
                                        icon = Icons.menu_book_rounded;
                                      case ZekrSection.morningAdhkar:
                                        icon = Icons.wb_sunny_rounded;
                                      case ZekrSection.eveningAdhkar:
                                        icon = Icons.nightlight_round;
                                      case ZekrSection.dailyWard:
                                        icon = Icons.menu_book_sharp;
                                    }
                                    return ZekrCard(
                                      title: item.section.title,
                                      description: item.section.description,
                                      checked: item.checked,
                                      leadingIcon: icon,
                                      enabled:
                                          _availabilityFor(
                                            item.section,
                                            now,
                                          ).enabled,
                                      footerText:
                                          _availabilityFor(
                                            item.section,
                                            now,
                                          ).footerText,
                                      footerIcon:
                                          _availabilityFor(
                                            item.section,
                                            now,
                                          ).footerIcon,
                                      onTap:
                                          _availabilityFor(
                                                item.section,
                                                now,
                                              ).enabled
                                              ? () => context
                                                  .read<DailyZekrCubit>()
                                                  .toggle(item.section)
                                              : null,
                                      onChanged:
                                          _availabilityFor(
                                                item.section,
                                                now,
                                              ).enabled
                                              ? (_) => context
                                                  .read<DailyZekrCubit>()
                                                  .toggle(item.section)
                                              : null,
                                    );
                                  },
                                )
                                : Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    start: 16.w,
                                    end: 16.w,
                                  ),
                                  child: Column(
                                    children: [
                                      ...items.map(
                                        (item) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 12.h,
                                          ),
                                          child: ZekrCard(
                                            title: item.section.title,
                                            description:
                                                item.section.description,
                                            checked: item.checked,
                                            leadingIcon: () {
                                              switch (item.section) {
                                                case ZekrSection.hadithDaily:
                                                  return Icons
                                                      .menu_book_rounded;
                                                case ZekrSection.morningAdhkar:
                                                  return Icons.wb_sunny_rounded;
                                                case ZekrSection.eveningAdhkar:
                                                  return Icons.nightlight_round;
                                                case ZekrSection.dailyWard:
                                                  return Icons
                                                      .auto_awesome_rounded;
                                              }
                                            }(),
                                            enabled:
                                                _availabilityFor(
                                                  item.section,
                                                  now,
                                                ).enabled,
                                            footerText:
                                                _availabilityFor(
                                                  item.section,
                                                  now,
                                                ).footerText,
                                            footerIcon:
                                                _availabilityFor(
                                                  item.section,
                                                  now,
                                                ).footerIcon,
                                            onTap:
                                                _availabilityFor(
                                                      item.section,
                                                      now,
                                                    ).enabled
                                                    ? () => context
                                                        .read<DailyZekrCubit>()
                                                        .toggle(item.section)
                                                    : null,
                                            onChanged:
                                                _availabilityFor(
                                                      item.section,
                                                      now,
                                                    ).enabled
                                                    ? (_) => context
                                                        .read<DailyZekrCubit>()
                                                        .toggle(item.section)
                                                    : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
                            child: Column(
                              children: [
                                content,
                                SizedBox(height: 12.h),
                                _buildHintText(),
                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
              SliverToBoxAdapter(child: _buildPersonalTasksSection()),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: DailyZekrDecorations.infoCard(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: DailyZekrDecorations.infoIconTile(),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: ColorsManager.primaryGold,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كيف تعمل هذه الصفحة؟',
                    style: DailyZekrTextStyles.infoTitle,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'ضع علامة الصح على البند الذي أنجزته اليوم. عند التفعيل يتوقف إرسال التذكير لهذا القسم. إذا تُرك بدون تفعيل سنذكّرك كل دقيقة (للتجربة).',
                    style: DailyZekrTextStyles.infoBody,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Padding(
    padding: EdgeInsetsDirectional.only(
      start: 30.w,
      end: 30.w,
      top: 8.h,
      bottom: 8.h,
    ),
    child: Container(
      height: 2.h,
      decoration: DailyZekrDecorations.dividerGradient(),
    ),
  );

  Widget _buildHintText() => Text(
    'تلميح: يمكنك تعديل الحالة في أي وقت، ولن تُرسل التنبيهات للأقسام المكتملة.',
    style: DailyZekrTextStyles.hintText,
    textAlign: TextAlign.center,
  );

  Widget _buildPersonalTasksSection() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: DailyZekrDecorations.personalTasksSection(),
        child: BlocBuilder<PersonalTasksCubit, PersonalTasksState>(
          builder: (context, state) {
            Widget content;
            if (state is PersonalTasksLoading ||
                state is PersonalTasksInitial) {
              content = const Center(child: CircularProgressIndicator());
            } else if (state is PersonalTasksError) {
              content = Text(
                state.message,
                style: TextStyles.bodyMedium.copyWith(
                  color: ColorsManager.secondaryText,
                ),
                textAlign: TextAlign.right,
              );
            } else {
              final tasks = (state as PersonalTasksLoaded).tasks;
              if (tasks.isEmpty) {
                content = Text(
                  'لم تضف مهامًا بعد. اضغط زر "إضافة مهمة" بالأسفل.',
                  style: DailyZekrTextStyles.inputHint,
                  textAlign: TextAlign.right,
                );
              } else {
                content = Column(
                  children: [
                    for (final t in tasks) ...[
                      _buildPersonalTaskTile(context, t),
                      SizedBox(height: 10.h),
                    ],
                  ],
                );
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مهامي اليومية:',
                  style: DailyZekrTextStyles.personalTasksTitle,
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 10.h),
                content,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonalTaskTile(BuildContext context, PersonalTask task) {
    final isDone = task.isDone;
    final title = task.title;
    final id = task.id;

    return InkWell(
      onTap: () => context.read<PersonalTasksCubit>().toggleDone(id),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        decoration: DailyZekrDecorations.personalTaskTile(isDone: isDone),
        child: Row(
          children: [
            Checkbox(
              value: isDone,
              activeColor: ColorsManager.primaryPurple,
              onChanged:
                  (_) => context.read<PersonalTasksCubit>().toggleDone(id),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: DailyZekrTextStyles.personalTaskText(isDone: isDone),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 16.w,
          end: 16.w,
          bottom: 12.h,
          top: 8.h,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            onPressed: () => _showAddTaskSheet(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 20.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 10.w),
                Text(
                  'إضافة مهمة',
                  style: DailyZekrTextStyles.primaryButtonLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddTaskSheet(BuildContext context) async {
    final personalTasksCubit = context.read<PersonalTasksCubit>();
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: ColorsManager.cardBackground,
      shape: DailyZekrDecorations.bottomSheetShape(),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: personalTasksCubit,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
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
                      Text(
                        'إضافة مهمة يومية',
                        style: DailyZekrTextStyles.sheetTitle,
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: controller,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'اكتب المهمة هنا…',
                          filled: true,
                          fillColor: ColorsManager.secondaryBackground,
                          border: DailyZekrDecorations.inputBorder(ColorsManager.mediumGray.withOpacity(0.6)),
                          enabledBorder: DailyZekrDecorations.inputBorder(ColorsManager.mediumGray.withOpacity(0.6)),
                          focusedBorder: DailyZekrDecorations.inputBorder(ColorsManager.primaryGold.withOpacity(0.8)),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          onPressed: () {
                            sheetContext.read<PersonalTasksCubit>().addTask(
                              controller.text,
                            );
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(
                            'إضافة',
                            style: DailyZekrTextStyles.primaryButtonLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
