 /* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../cubit/ramadan_tasks_cubit.dart';
import '../widgets/task_creation/task_creation_sheet.dart';
import '../widgets/calendar_button.dart';
import '../widgets/error_view.dart';
import '../widgets/ramadan_calendar_sheet.dart';
import '../widgets/table_view/ramadan_table_view.dart';
import '../../../../core/routing/routes.dart';

class RamadanTasksScreen extends StatefulWidget {
  const RamadanTasksScreen({super.key});

  @override
  State<RamadanTasksScreen> createState() => _RamadanTasksScreenState();
}

class _RamadanTasksScreenState extends State<RamadanTasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
          top: true,
        child: Scaffold(
          backgroundColor: ColorsManager.secondaryBackground,
          floatingActionButton: const _AddTaskFab(),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          body: BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
            buildWhen: (previous, current) {
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
                  // ── Custom Ramadan App Bar ──
                  _RamadanSliverAppBar(
                    overallPercent:
                        state is RamadanTasksLoaded ? state.overallPercent : 0,
                    onProgressTap:
                        () => Navigator.of(
                          context,
                        ).pushNamed(Routes.ramadanProgressScreen),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // ── Calendar Button ──
                  if (state is RamadanTasksLoaded)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 14.w,
                        ),
                        child: CalendarButton(
                          hijriDateString: state.hijriDateString,
                          onTap:
                              () => RamadanCalendarSheet.show(
                                context,
                                allTasks: state.allTasks,
                                todayDay: state.todayDay,
                              ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 6)),

                  // ── Content ──
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
                      child: RamadanTableView(
                        key: const ValueKey('table_mode'),
                        allTasks: state.allTasks,
                        todayDay: state.todayDay,
                        overallPercent: state.overallPercent,
                      ),
                    )
                  else
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Custom Ramadan-themed SliverAppBar
// ────────────────────────────────────────────────────────────────

class _RamadanSliverAppBar extends StatelessWidget {
  final double overallPercent;
  final VoidCallback onProgressTap;

  const _RamadanSliverAppBar({
    required this.overallPercent,
    required this.onProgressTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentInt = (overallPercent * 100).round().clamp(0, 100);

    return SliverAppBar(
      expandedHeight: 170.h.clamp(140, 210).toDouble(),
      floating: false,
      pinned: true,
      leading: const SizedBox.shrink(),
      automaticallyImplyLeading: false,
      backgroundColor: ColorsManager.primaryPurple,
      elevation: 4,
      shadowColor: ColorsManager.primaryPurple.withValues(alpha: 0.4),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _AppBarBackground(
          overallPercent: overallPercent,
          percentInt: percentInt,
          onProgressTap: onProgressTap,
          onBack: () => context.pop(),
        ),
      ),
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  final double overallPercent;
  final int percentInt;
  final VoidCallback onProgressTap;
  final VoidCallback onBack;

  const _AppBarBackground({
    required this.overallPercent,
    required this.percentInt,
    required this.onProgressTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6), // lighter purple
            ColorsManager.primaryPurple,
            ColorsManager.darkPurple,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // ── Decorative background circles ──
          PositionedDirectional(
            top: -30.h,
            end: -20.w,
            child: _DecorativeCircle(size: 120.w, opacity: 0.06),
          ),
          PositionedDirectional(
            bottom: 10.h,
            start: -40.w,
            child: _DecorativeCircle(size: 150.w, opacity: 0.04),
          ),
          PositionedDirectional(
            top: 40.h,
            start: 60.w,
            child: _DecorativeCircle(size: 50.w, opacity: 0.08),
          ),

          // ── Gold accent line at bottom ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    ColorsManager.primaryGold,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxH = constraints.maxHeight;
                final isCompact = maxH < 160;
                final titleSize = 22.sp.clamp(16.0, 24.0);
                final subtitleSize = 12.sp.clamp(9.0, 14.0);
                final iconBtnSize = 36.w.clamp(30.0, 42.0);

                return Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 16.w.clamp(10.0, 20.0),
                    vertical: 6.h.clamp(4.0, 10.0),
                  ),
                  child: Column(
                    children: [
                      // Top row: back button + crescent moon accent
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GlassIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            size: iconBtnSize,
                            onTap: onBack,
                          ),
                          Icon(
                            Icons.nightlight_round,
                            size: 20.sp.clamp(16.0, 24.0),
                            color: ColorsManager.primaryGold.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isCompact ? 4.h : 8.h),

                      // Title + subtitle
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'مشكاة في رمضان',
                          style: TextStyles.displaySmall.copyWith(
                            color: ColorsManager.white,
                            fontWeight: FontWeight.w800,
                            fontSize: titleSize,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (!isCompact) ...[
                        SizedBox(height: 2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'أنشئ خطتك الخاصة لشهر رمضان',
                            style: TextStyles.bodySmall.copyWith(
                              color: ColorsManager.white.withValues(
                                alpha: 0.75,
                              ),
                              fontSize: subtitleSize,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // ── Frosted progress pill ──
                      _ProgressPill(
                        overallPercent: overallPercent,
                        percentInt: percentInt,
                        onTap: onProgressTap,
                        isCompact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 4.h : 8.h),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Progress pill — responsive frosted glass widget
// ────────────────────────────────────────────────────────────────

class _ProgressPill extends StatelessWidget {
  final double overallPercent;
  final int percentInt;
  final VoidCallback onTap;
  final bool isCompact;

  const _ProgressPill({
    required this.overallPercent,
    required this.percentInt,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = isCompact ? 28.0 : 34.w.clamp(26.0, 40.0);
    final pillH = isCompact ? 6.0 : 8.h.clamp(4.0, 10.0);
    final pillW = isCompact ? 10.0 : 14.w.clamp(8.0, 18.0);
    final labelSize = isCompact ? 10.0 : 11.sp.clamp(9.0, 13.0);
    final subLabelSize = isCompact ? 8.0 : 9.sp.clamp(7.0, 11.0);
    final percentSize = isCompact ? 8.0 : 9.sp.clamp(7.0, 11.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: pillW,
          vertical: pillH,
        ),
        decoration: BoxDecoration(
          color: ColorsManager.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: ColorsManager.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini progress ring
            SizedBox(
              width: ringSize,
              height: ringSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: overallPercent.clamp(0.0, 1.0),
                    strokeWidth: 2.5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: ColorsManager.white.withValues(alpha: 0.2),
                    color: ColorsManager.primaryGold,
                  ),
                  Text(
                    '$percentInt',
                    style: TextStyles.labelSmall.copyWith(
                      color: ColorsManager.white,
                      fontWeight: FontWeight.w800,
                      fontSize: percentSize,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w.clamp(4.0, 12.0)),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تقدمك هذا الشهر',
                    style: TextStyles.labelSmall.copyWith(
                      color: ColorsManager.white,
                      fontWeight: FontWeight.w700,
                      fontSize: labelSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'اضغط للتفاصيل',
                    style: TextStyles.labelSmall.copyWith(
                      color: ColorsManager.white.withValues(alpha: 0.6),
                      fontSize: subLabelSize,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w.clamp(2.0, 10.0)),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12.sp.clamp(8.0, 14.0),
              color: ColorsManager.white.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass-morphism style icon button for the app bar.
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.5).clamp(14.0, 22.0);
    return Material(
      color: ColorsManager.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: ColorsManager.white.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(icon, color: ColorsManager.white, size: iconSize),
        ),
      ),
    );
  }
}

/// Decorative translucent circle for background visual interest.
class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorsManager.white.withValues(alpha: opacity),
      ),
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
              'إضافة عبادات',
              style: TextStyles.titleSmall.copyWith(color: ColorsManager.white),
            ),
            onPressed: () => showTaskCreationSheet(context),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

*/