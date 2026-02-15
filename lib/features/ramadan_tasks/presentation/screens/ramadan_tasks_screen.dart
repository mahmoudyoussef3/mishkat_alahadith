import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import '../cubit/ramadan_tasks_cubit.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/calendar_button.dart';
import '../widgets/error_view.dart';
import '../widgets/ramadan_calendar_sheet.dart';
import '../widgets/table_view/presentation_mode_toggle.dart';
import '../widgets/table_view/ramadan_card_view.dart';
import '../widgets/table_view/ramadan_table_view.dart';
import '../../../../core/routing/routes.dart';

class RamadanTasksScreen extends StatefulWidget {
  const RamadanTasksScreen({super.key});

  @override
  State<RamadanTasksScreen> createState() => _RamadanTasksScreenState();
}

class _RamadanTasksScreenState extends State<RamadanTasksScreen> {
  PresentationMode _presentationMode = PresentationMode.table;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        floatingActionButton: const _AddTaskFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
          buildWhen: (previous, current) {
            // Rebuild when state type changes or key data changes
            if (previous.runtimeType != current.runtimeType) return true;
            if (current is RamadanTasksLoaded &&
                previous is RamadanTasksLoaded) {
              return previous.allTasks != current.allTasks ||
                  previous.todayDay != current.todayDay ||
                  previous.viewMode != current.viewMode ||
                  previous.overallPercent != current.overallPercent;
            }
            return false;
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                BuildHeaderAppBar(
                  home: false,
                  bottomNav: false,
                  title: 'مشكاة في رمضان',
                  description: 'أنشئ خطتك الخاصة لشهر رمضان',
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ── Monthly Progress Summary Card ──
                if (state is RamadanTasksLoaded)
                  SliverToBoxAdapter(
                    child: _MonthlyProgressCard(
                      overallPercent: state.overallPercent,
                      onTap:
                          () => Navigator.of(
                            context,
                          ).pushNamed(Routes.ramadanProgressScreen),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ── Calendar Button ──
                if (state is RamadanTasksLoaded)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 12.w,
                      ),
                      child: CalendarButton(
                        onTap:
                            () => RamadanCalendarSheet.show(
                              context,
                              allTasks: state.allTasks,
                              todayDay: state.todayDay,
                            ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // ── Control Section ──
                SliverToBoxAdapter(
                  child: _ControlSection(
                    presentationMode: _presentationMode,
                    onModeChanged: (mode) {
                      setState(() => _presentationMode = mode);
                    },
                  ),
                ),

                if (state is RamadanTasksLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorsManager.primaryPurple,
                      ),
                    ),
                  )
                else if (state is RamadanTasksError)
                  SliverFillRemaining(
                    child: Center(
                      child: RamadanErrorView(message: state.message),
                    ),
                  )
                else if (state is RamadanTasksLoaded)
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: _FullScreenContent(
                      state: state,
                      mode: _presentationMode,
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ControlSection extends StatelessWidget {
  final PresentationMode presentationMode;
  final ValueChanged<PresentationMode> onModeChanged;

  const _ControlSection({
    required this.presentationMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PresentationModeToggle(
      mode: presentationMode,
      onChanged: onModeChanged,
    );
  }
}

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
// Monthly Progress Card - Clickable summary preview
// ────────────────────────────────────────────────────────────────

class _MonthlyProgressCard extends StatefulWidget {
  final double overallPercent;
  final VoidCallback onTap;

  const _MonthlyProgressCard({
    required this.overallPercent,
    required this.onTap,
  });

  @override
  State<_MonthlyProgressCard> createState() => _MonthlyProgressCardState();
}

class _MonthlyProgressCardState extends State<_MonthlyProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsetsDirectional.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorsManager.primaryPurple.withOpacity(0.08),
                        ColorsManager.primaryPurple.withOpacity(0.04),
                      ],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: ColorsManager.primaryPurple.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.primaryPurple.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Circular Progress Indicator
                      /*    SizedBox(
                        width: 56.w,
                        height: 56.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: widget.overallPercent / 100,
                              strokeWidth: 5,
                              backgroundColor: ColorsManager.mediumGray
                                  .withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsManager.primaryPurple,
                              ),
                            ),
                            Text(
                              '$percentInt%',
                              style: TextStyles.titleMedium.copyWith(
                                color: ColorsManager.primaryPurple,
                                fontWeight: FontWeight.w800,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      */
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تقدمك هذا الشهر',
                              style: TextStyles.titleMedium.copyWith(
                                color: ColorsManager.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'اضغط لعرض تفاصيل الإحصائيات الكاملة',
                              style: TextStyles.bodySmall.copyWith(
                                color: ColorsManager.secondaryText,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.sp,
                          color: ColorsManager.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
