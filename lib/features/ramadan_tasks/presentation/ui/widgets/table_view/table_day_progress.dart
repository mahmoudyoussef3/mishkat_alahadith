import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// A mini circular progress indicator shown at the end of each day row.
/// Displays the percentage of tasks completed for that day.
class TableDayProgress extends StatelessWidget {
  final int completed;
  final int total;

  const TableDayProgress({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: 52.w,
      height: 40.h,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) {
            final color =
                value >= 1.0
                    ? ColorsManager.success
                    : value >= 0.5
                    ? ColorsManager.primaryGold
                    : ColorsManager.secondaryText;
            return SizedBox(
              width: 30.w,
              height: 30.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 3.w,
                    strokeCap: StrokeCap.round,
                    backgroundColor: ColorsManager.mediumGray.withOpacity(0.3),
                    color: color,
                  ),
                  Text(
                    '${(value * 100).toInt()}',
                    style: TextStyles.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 8.sp,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
