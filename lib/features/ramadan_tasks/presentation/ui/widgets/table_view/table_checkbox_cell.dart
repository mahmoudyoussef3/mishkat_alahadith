import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// An animated circular checkbox cell for the Ramadan table grid.
///
/// Features:
/// - Smooth scale animation on toggle
/// - Subtle color transition when completed
/// - Soft glow effect for completed state
/// - Haptic feedback on tap
class TableCheckboxCell extends StatefulWidget {
  final bool isCompleted;
  final bool enabled;
  final VoidCallback? onToggle;

  const TableCheckboxCell({
    super.key,
    required this.isCompleted,
    this.enabled = true,
    this.onToggle,
  });

  @override
  State<TableCheckboxCell> createState() => _TableCheckboxCellState();
}

class _TableCheckboxCellState extends State<TableCheckboxCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onToggle == null) return;
    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
    widget.onToggle!();
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.isCompleted;
    final enabled = widget.enabled;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48.w,
        height: 48.w,
        child: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 26.w,
              height: 26.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    completed
                        ? ColorsManager.success.withOpacity(0.15)
                        : enabled
                        ? ColorsManager.lightGray
                        : ColorsManager.lightGray.withOpacity(0.4),
                border: Border.all(
                  color:
                      completed
                          ? ColorsManager.success
                          : enabled
                          ? ColorsManager.mediumGray
                          : ColorsManager.mediumGray.withOpacity(0.4),
                  width: 2.w,
                ),
                boxShadow:
                    completed
                        ? [
                          BoxShadow(
                            color: ColorsManager.success.withOpacity(0.25),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                        : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child:
                    completed
                        ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey('check'),
                          size: 16.sp,
                          color: ColorsManager.success,
                        )
                        : SizedBox.shrink(key: const ValueKey('empty')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An empty placeholder cell used when a todayOnly task
/// doesn't apply to a particular day row.
class TableEmptyCell extends StatelessWidget {
  const TableEmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: Center(
        child: Container(
          width: 10.w,
          height: 2.h,
          decoration: BoxDecoration(
            color: ColorsManager.mediumGray.withOpacity(0.4),
            borderRadius: BorderRadius.circular(1.r),
          ),
        ),
      ),
    );
  }
}
