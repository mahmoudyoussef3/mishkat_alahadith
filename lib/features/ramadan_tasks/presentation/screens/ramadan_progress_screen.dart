import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../cubit/ramadan_tasks_cubit.dart';
import '../widgets/error_view.dart';
import '../widgets/progress_screen/day_records_view.dart';
import '../widgets/progress_screen/monthly_calendar_view.dart';
import '../widgets/progress_screen/progress_stats_card.dart';

// ────────────────────────────────────────────────────────────────
// RamadanProgressScreen — Statistics + Monthly Calendar + Day Records
// ────────────────────────────────────────────────────────────────

class RamadanProgressScreen extends StatefulWidget {
  const RamadanProgressScreen({super.key});

  @override
  State<RamadanProgressScreen> createState() => _RamadanProgressScreenState();
}

class _RamadanProgressScreenState extends State<RamadanProgressScreen> {
  int? _selectedDay;
  DayRecordsMode _recordsMode = DayRecordsMode.card;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.primaryBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── App bar ──
              _buildAppBar(context),

              // ── Body ──
              Expanded(
                child: BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
                  buildWhen: (previous, current) {
                    // Only rebuild when state type changes or data changes
                    if (previous.runtimeType != current.runtimeType)
                      return true;
                    if (current is RamadanTasksLoaded &&
                        previous is RamadanTasksLoaded) {
                      return previous.allTasks != current.allTasks ||
                          previous.todayDay != current.todayDay;
                    }
                    return false;
                  },
                  builder: (context, state) {
                    if (state is RamadanTasksLoading) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: ColorsManager.primaryPurple,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'جاري التحميل...',
                              style: TextStyles.bodyMedium.copyWith(
                                color: ColorsManager.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is RamadanTasksError) {
                      return Center(
                        child: RamadanErrorView(message: state.message),
                      );
                    }
                    final s = state as RamadanTasksLoaded;
                    return _buildScrollableBody(s);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // App Bar
  // ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: ColorsManager.primaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: ColorsManager.lightGray,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20.sp,
                color: ColorsManager.primaryText,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات وتقويم رمضان',
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ColorsManager.primaryText,
                  ),
                ),
                Text(
                  'متابعة المهام اليومية والتقدّم الشهري',
                  style: TextStyles.bodySmall.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Calendar icon badge
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: 20.sp,
              color: ColorsManager.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Scrollable body
  // ─────────────────────────────────────────────────────────────

  Widget _buildScrollableBody(RamadanTasksLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: on wider screens (tablet ≥ 700px), use a
        // two-column layout with calendar beside day records.
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return _buildWideLayout(state, constraints);
        }
        return _buildNarrowLayout(state);
      },
    );
  }

  // ── Narrow (phone) layout ──

  Widget _buildNarrowLayout(RamadanTasksLoaded state) {
    return ListView(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      children: [
        SizedBox(height: 12.h),

        // Progress stats card
        ProgressStatsCard(
          todayDay: state.todayDay,
          dailyPercent: state.dailyPercent,
          weeklyPercent: state.weeklyPercent,
          overallPercent: state.overallPercent,
          dailyCompleted: state.dailyCompleted,
          dailyTotal: state.dailyTotal,
          allTasks: state.allTasks,
          hijriDateString: state.hijriDateString,
        ),

        SizedBox(height: 16.h),

        // Monthly calendar
        MonthlyCalendarView(
          allTasks: state.allTasks,
          todayDay: state.todayDay,
          selectedDay: _selectedDay,
          onDaySelected: (day) => setState(() => _selectedDay = day),
        ),

        SizedBox(height: 16.h),

        // Day records (shown when a day is selected)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1.0,
                child: child,
              ),
            );
          },
          child:
              _selectedDay != null
                  ? DayRecordsView(
                    key: ValueKey('day_records_$_selectedDay'),
                    day: _selectedDay!,
                    todayDay: state.todayDay,
                    allTasks: state.allTasks,
                    mode: _recordsMode,
                    onModeChanged: (m) => setState(() => _recordsMode = m),
                  )
                  : _buildSelectDayPrompt(),
        ),

        SizedBox(height: 80.h),
      ],
    );
  }

  // ── Wide (tablet) layout ──

  Widget _buildWideLayout(
    RamadanTasksLoaded state,
    BoxConstraints constraints,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 12.h),

          // Progress stats card (full width)
          ProgressStatsCard(
            todayDay: state.todayDay,
            dailyPercent: state.dailyPercent,
            weeklyPercent: state.weeklyPercent,
            overallPercent: state.overallPercent,
            dailyCompleted: state.dailyCompleted,
            dailyTotal: state.dailyTotal,
            allTasks: state.allTasks,
            hijriDateString: state.hijriDateString,
          ),

          SizedBox(height: 16.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Calendar
              Expanded(
                flex: 5,
                child: MonthlyCalendarView(
                  allTasks: state.allTasks,
                  todayDay: state.todayDay,
                  selectedDay: _selectedDay,
                  onDaySelected: (day) => setState(() => _selectedDay = day),
                ),
              ),
              SizedBox(width: 16.w),

              // Day records
              Expanded(
                flex: 5,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child:
                      _selectedDay != null
                          ? DayRecordsView(
                            key: ValueKey('day_records_$_selectedDay'),
                            day: _selectedDay!,
                            todayDay: state.todayDay,
                            allTasks: state.allTasks,
                            mode: _recordsMode,
                            onModeChanged:
                                (m) => setState(() => _recordsMode = m),
                          )
                          : Center(child: _buildSelectDayPrompt()),
                ),
              ),
            ],
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Prompt to select a day
  // ─────────────────────────────────────────────────────────────

  Widget _buildSelectDayPrompt() {
    return Container(
      key: const ValueKey('select_prompt'),
      padding: EdgeInsetsDirectional.all(28.w),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ColorsManager.mediumGray.withOpacity(0.4),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 40.sp,
            color: ColorsManager.primaryPurple.withOpacity(0.4),
          ),
          SizedBox(height: 8.h),
          Text(
            'اختر يومًا من التقويم',
            style: TextStyles.titleSmall.copyWith(
              color: ColorsManager.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'اضغط على أي يوم لعرض تفاصيل المهام',
            style: TextStyles.bodySmall.copyWith(
              color: ColorsManager.disabledText,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
