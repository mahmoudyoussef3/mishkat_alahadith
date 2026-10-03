import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../../cubit/ramadan_tasks_cubit.dart';
import 'ramadan_table_view.dart';

/// A fullscreen overlay that displays the Ramadan table in an immersive view.
class FullscreenTableOverlay extends StatefulWidget {
  const FullscreenTableOverlay({super.key});

  /// Push a fullscreen table overlay route.
  static Future<void> show(BuildContext context) {
    final cubit = context.read<RamadanTasksCubit>();
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder:
            (ctx, animation, secondaryAnimation) => BlocProvider.value(
              value: cubit,
              child: const FullscreenTableOverlay(),
            ),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<FullscreenTableOverlay> createState() => _FullscreenTableOverlayState();
}

class _FullscreenTableOverlayState extends State<FullscreenTableOverlay> {
  @override
  void initState() {
    super.initState();
    // Immersive fullscreen — hide status & nav bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system bars
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top control bar ──
              _FullscreenControlBar(onClose: _close),
              // ── Table ──
              Expanded(
                child: BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
                  builder: (context, state) {
                    if (state is RamadanTasksLoaded) {
                      return RamadanTableView(
                        allTasks: state.allTasks,
                        todayDay: state.todayDay,
                        overallPercent: state.overallPercent,
                        isFullscreen: true,
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorsManager.primaryPurple,
                      ),
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
// Control bar with close button
// ────────────────────────────────────────────────────────────────

class _FullscreenControlBar extends StatelessWidget {
  final VoidCallback onClose;

  const _FullscreenControlBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _ControlButton(
            icon: Icons.close_fullscreen_rounded,
            tooltip: 'إغلاق العرض الكامل',
            onTap: onClose,
          ),
          const Spacer(),
          Text(
            'عرض الجدول الكامل',
            style: TextStyles.titleSmall.copyWith(
              color: ColorsManager.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Balance spacer so title stays centered
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: ColorsManager.primaryPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            child: Icon(icon, size: 20.sp, color: ColorsManager.primaryPurple),
          ),
        ),
      ),
    );
  }
}
