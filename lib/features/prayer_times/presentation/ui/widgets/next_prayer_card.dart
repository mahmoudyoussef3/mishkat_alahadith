import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_decorations.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_styles.dart';

class NextPrayerCard extends StatelessWidget {
  final String nextPrayerLabel;
  final DateTime nextPrayerTime;
  final Duration remaining;

  const NextPrayerCard({
    super.key,
    required this.nextPrayerLabel,
    required this.nextPrayerTime,
    required this.remaining,
  });

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDuration(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60);
    final ss = d.inSeconds.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(hh)}:${two(mm)}:${two(ss)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: PrayerTimesDecorations.nextPrayerContainer(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصلاة القادمة',
                    style: PrayerTimesTextStyles.nextPrayerSectionLabel,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    nextPrayerLabel,
                    style: PrayerTimesTextStyles.nextPrayerNameLabel,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: ColorsManager.primaryPurple,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _formatTime(nextPrayerTime),
                        style: PrayerTimesTextStyles.nextPrayerTimeValue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: PrayerTimesDecorations.countdownPill(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: ColorsManager.primaryPurple,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _formatDuration(remaining),
                    style: PrayerTimesTextStyles.countdownValue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
