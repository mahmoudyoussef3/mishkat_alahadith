import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// A beautiful summary card showing daily/monthly/weekly progress
/// with an animated circular daily indicator and horizontal bars.
class RamadanProgress extends StatelessWidget {
  final int todayDay;
  final double dailyPercent;
  final double overallPercent;
  final double weeklyPercent;
  final int dailyCompleted;
  final int dailyTotal;
  final String? motivationalText;
  final String hijriDateString;

  const RamadanProgress({
    super.key,
    required this.todayDay,
    required this.dailyPercent,
    required this.overallPercent,
    required this.weeklyPercent,
    required this.dailyCompleted,
    required this.dailyTotal,
    this.motivationalText,
    required this.hijriDateString,
  });

  String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryPurple.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsetsDirectional.all(16.w),
      child: Column(
        children: [
          // ── Top row: circular progress + day label ──
          Row(
            children: [
              // Circular daily progress
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: dailyPercent.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) {
                  return SizedBox(
                    width: 72.w,
                    height: 72.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 72.w,
                          height: 72.w,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 6.w,
                            strokeCap: StrokeCap.round,
                            backgroundColor: ColorsManager.white.withOpacity(
                              0.15,
                            ),
                            color: ColorsManager.primaryGold,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(value * 100).toInt()}%',
                              style: TextStyles.headlineSmall.copyWith(
                                color: ColorsManager.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: 16.w),
              // Day info + completed count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اليوم $hijriDateString',
                      style: TextStyles.titleLarge.copyWith(
                        color: ColorsManager.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$dailyCompleted من $dailyTotal مهمة مكتملة',
                      style: TextStyles.bodyMedium.copyWith(
                        color: ColorsManager.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ── Monthly & weekly bars ──
          _ProgressBar(
            label: 'التقدّم الكلي',
            percent: overallPercent,
            barColor: ColorsManager.primaryGold,
          ),
          SizedBox(height: 10.h),
          _ProgressBar(
            label: 'تقدّم الأسبوع',
            percent: weeklyPercent,
            barColor: ColorsManager.secondaryPurple,
          ),

          // ── Motivational text ──
          if (motivationalText != null) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsetsDirectional.symmetric(
                vertical: 10.h,
                horizontal: 14.w,
              ),
              decoration: BoxDecoration(
                color: ColorsManager.primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: ColorsManager.primaryGold,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      motivationalText!,
                      style: TextStyles.titleSmall.copyWith(
                        color: ColorsManager.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single horizontal progress bar with label and percentage.
class _ProgressBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color barColor;

  const _ProgressBar({
    required this.label,
    required this.percent,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final capped = percent.clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyles.titleSmall.copyWith(
                  color: ColorsManager.white.withOpacity(0.9),
                ),
              ),
            ),
            Text(
              '${(capped * 100).toStringAsFixed(0)}%',
              style: TextStyles.titleSmall.copyWith(
                color: ColorsManager.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: capped),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8.h,
                color: barColor,
                backgroundColor: ColorsManager.white.withOpacity(0.15),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Converts an integer to Arabic-Indic numerals string.
String _toArabicNumerals(int number) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number
      .toString()
      .split('')
      .map((d) => arabicDigits[int.parse(d)])
      .join();
}
