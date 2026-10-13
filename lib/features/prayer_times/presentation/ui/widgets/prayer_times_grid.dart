import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_time_format.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/daily_prayer_times.dart';

enum _RowState { past, next, upcoming }

/// The six times of a day, one row each. On today the prayers already
/// prayed are muted and the next one is marked in gold.
class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({
    super.key,
    required this.times,
    required this.isToday,
    required this.isPastDay,
    required this.notificationsEnabled,
    this.nextPrayerTime,
  });

  final DailyPrayerTimes times;
  final bool isToday;

  /// True when the listed day is before today.
  final bool isPastDay;
  final bool notificationsEnabled;

  /// When the next prayer is due; its row is marked. Matched by time, not
  /// name, so after Isha today's (past) Fajr is not taken for tomorrow's.
  final DateTime? nextPrayerTime;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final rows = [
      (PrayerNames.fajr, times.fajr, Icons.dark_mode_rounded),
      (PrayerNames.sunrise, times.sunrise, Icons.wb_twilight_rounded),
      (PrayerNames.dhuhr, times.dhuhr, Icons.light_mode_rounded),
      (PrayerNames.asr, times.asr, Icons.wb_sunny_outlined),
      (PrayerNames.maghrib, times.maghrib, Icons.wb_twilight_rounded),
      (PrayerNames.isha, times.isha, Icons.bedtime_rounded),
    ];

    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Column(
        children: [
          for (final (name, time, icon) in rows)
            _PrayerRow(
              name: name,
              time: time,
              icon: icon,
              isSunrise: name == PrayerNames.sunrise,
              notificationsEnabled: notificationsEnabled,
              state:
                  isPastDay
                      ? _RowState.past
                      : !isToday
                      ? _RowState.upcoming
                      : time == nextPrayerTime
                      ? _RowState.next
                      : time.isBefore(now)
                      ? _RowState.past
                      : _RowState.upcoming,
            ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.name,
    required this.time,
    required this.icon,
    required this.state,
    required this.isSunrise,
    required this.notificationsEnabled,
  });

  final String name;
  final DateTime time;
  final IconData icon;
  final _RowState state;
  final bool isSunrise;
  final bool notificationsEnabled;

  @override
  Widget build(BuildContext context) {
    final next = state == _RowState.next;
    final past = state == _RowState.past;
    final ink = past ? ColorsManager.secondaryText : ColorsManager.primaryText;
    final timeInk = next ? ColorsManager.goldInk : ink;
    final alerts = notificationsEnabled && !isSunrise;

    return Semantics(
      label:
          '$name ${formatArabicClock(time)}'
          '${next ? '، الصلاة التالية' : ''}'
          '${alerts ? '، التنبيه مفعّل' : ''}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: next ? ColorsManager.goldSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: next ? ColorsManager.goldBright : ColorsManager.primarySoft,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(
                icon,
                size: 21.r,
                color: next ? ColorsManager.onGoldBright : ColorsManager.purpleText,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Row(
                children: [
                  Text(
                    name,
                    style: TextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  if (next) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
                      decoration: ShapeDecoration(
                        color: ColorsManager.goldBright,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'التالية',
                        style: TextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorsManager.onGoldBright,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              formatArabicClock(time),
              style: TextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: timeInk,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              alerts
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              size: 20.r,
              color:
                  !alerts
                      ? ColorsManager.mediumGray
                      : next
                      ? ColorsManager.primaryGold
                      : ColorsManager.purpleText,
            ),
          ],
        ),
      ),
    );
  }
}
