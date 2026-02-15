import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Mini circular progress indicator for a single day's completion.
///
/// Uses [TweenAnimationBuilder] for smooth fill animation.
/// Color transitions: gray → gold → green based on completion %.
class GridProgressCell extends StatelessWidget {
  final int completed;
  final int total;

  const GridProgressCell({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percent),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) {
          final color =
              value >= 1.0
                  ? ColorsManager.success
                  : value >= 0.5
                  ? ColorsManager.primaryGold
                  : ColorsManager.secondaryText;
          return SizedBox(
            width: 38.w,
            height: 38.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3.5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: ColorsManager.mediumGray.withValues(
                    alpha: 0.25,
                  ),
                  color: color,
                ),
                Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
