import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_time_format.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';

/// The next prayer with a live countdown, and how far the current prayer
/// window has run.
class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({
    super.key,
    required this.nextPrayerLabel,
    required this.nextPrayerTime,
    required this.remaining,
    this.previousPrayerLabel,
    this.previousPrayerTime,
  });

  final String nextPrayerLabel;
  final DateTime nextPrayerTime;
  final Duration remaining;
  final String? previousPrayerLabel;
  final DateTime? previousPrayerTime;

  static String _countdown(Duration remaining) {
    final seconds = remaining.inSeconds.clamp(0, 99 * 3600);
    String two(int value) => value.toString().padLeft(2, '0');
    return toArabicDigits(
      '${two(seconds ~/ 3600)}:${two(seconds % 3600 ~/ 60)}:${two(seconds % 60)}',
    );
  }

  double? get _progress {
    final previous = previousPrayerTime;
    if (previous == null) return null;
    final window = nextPrayerTime.difference(previous).inSeconds;
    if (window <= 0) return null;
    return (1 - remaining.inSeconds / window).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final muted = ColorsManager.white.withValues(alpha: 0.78);
    final big = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 30.sp,
      height: 1.3,
      fontWeight: FontWeight.w800,
      color: ColorsManager.white,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final small = TextStyles.labelSmall.copyWith(
      fontWeight: FontWeight.w600,
      color: muted,
    );
    final progress = _progress;
    final previousLabel = previousPrayerLabel;
    final previousTime = previousPrayerTime;

    return Semantics(
      label:
          'الصلاة القادمة $nextPrayerLabel ${formatArabicClock(nextPrayerTime)}، '
          'بعد ${formatArabicCountdown(remaining)}',
      excludeSemantics: true,
      child: HeroSurface(
        radius: 26.r,
        padding: EdgeInsets.all(20.r),
        imageOpacity: 0.28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الصلاة القادمة',
                        style: TextStyles.caption.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: muted,
                        ),
                      ),
                      Text(nextPrayerLabel, style: big),
                      Text(
                        formatArabicClock(nextPrayerTime),
                        style: TextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.goldBright,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('متبقٍ', style: small.copyWith(fontSize: 12.sp)),
                    Text(
                      _countdown(remaining),
                      textDirection: TextDirection.ltr,
                      style: big,
                    ),
                  ],
                ),
              ],
            ),
            if (progress != null && previousLabel != null && previousTime != null) ...[
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6.h,
                  color: ColorsManager.goldBright,
                  backgroundColor: ColorsManager.white.withValues(alpha: 0.18),
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$previousLabel ${formatArabicClock(previousTime)}',
                    style: small,
                  ),
                  Text(
                    '$nextPrayerLabel ${formatArabicClock(nextPrayerTime)}',
                    style: small,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
