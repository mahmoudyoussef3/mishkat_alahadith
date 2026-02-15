import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../cubit/ramadan_tasks_cubit.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/error_view.dart';
import '../widgets/table_view/presentation_mode_toggle.dart';
import '../widgets/table_view/ramadan_card_view.dart';
import '../widgets/table_view/ramadan_table_view.dart';
import '../../../../core/routing/routes.dart';

// ────────────────────────────────────────────────────────────────
// RamadanTasksScreen
// ────────────────────────────────────────────────────────────────

class RamadanTasksScreen extends StatefulWidget {
  const RamadanTasksScreen({super.key});

  @override
  State<RamadanTasksScreen> createState() => _RamadanTasksScreenState();
}

class _RamadanTasksScreenState extends State<RamadanTasksScreen> {
  PresentationMode _presentationMode = PresentationMode.card;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.primaryBackground,
        floatingActionButton: const _AddTaskFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Compact app bar ──
              _CompactAppBar(
                presentationMode: _presentationMode,
                onModeChanged: (mode) {
                  setState(() => _presentationMode = mode);
                },
              ),

              // ── Full-screen content area ──
              Expanded(
                child: BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
                  builder: (context, state) {
                    if (state is RamadanTasksLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ColorsManager.primaryPurple,
                        ),
                      );
                    }
                    if (state is RamadanTasksError) {
                      return Center(
                        child: RamadanErrorView(message: state.message),
                      );
                    }
                    final s = state as RamadanTasksLoaded;
                    return _FullScreenContent(
                      state: s,
                      mode: _presentationMode,
                    );
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

// ────────────────────────────────────────────────────────────────
// Compact App Bar + Toggle
// ────────────────────────────────────────────────────────────────

class _CompactAppBar extends StatelessWidget {
  final PresentationMode presentationMode;
  final ValueChanged<PresentationMode> onModeChanged;

  const _CompactAppBar({
    required this.presentationMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 10.h),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ──
          Row(
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
                    Icons.arrow_forward_rounded,
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
                      'مشكاة في رمضان',
                      style: TextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ColorsManager.primaryText,
                      ),
                    ),
                    Text(
                      'أنشئ خطتك الخاصة لشهر رمضان',
                      style: TextStyles.bodySmall.copyWith(
                        color: ColorsManager.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Stats button ──
              GestureDetector(
                onTap:
                    () => Navigator.of(
                      context,
                    ).pushNamed(Routes.ramadanProgressScreen),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ColorsManager.primaryPurple,
                        ColorsManager.darkPurple,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    size: 20.sp,
                    color: ColorsManager.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // ── Toggle ──
          Center(
            child: PresentationModeToggle(
              mode: presentationMode,
              onChanged: onModeChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Full screen content with animated transitions
// ────────────────────────────────────────────────────────────────

class _FullScreenContent extends StatelessWidget {
  final RamadanTasksLoaded state;
  final PresentationMode mode;

  const _FullScreenContent({required this.state, required this.mode});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final slideOffset = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slideOffset, child: child),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child:
          mode == PresentationMode.table
              ? RamadanTableView(
                key: const ValueKey('table_mode'),
                allTasks: state.allTasks,
                todayDay: state.todayDay,
                overallPercent: state.overallPercent,
              )
              : RamadanCardView(key: const ValueKey('card_mode'), state: state),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// FAB
// ────────────────────────────────────────────────────────────────

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
