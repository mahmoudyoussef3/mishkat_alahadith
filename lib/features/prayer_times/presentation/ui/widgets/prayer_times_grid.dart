import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_decorations.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_styles.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';

class PrayerTimesGrid extends StatelessWidget {
  final DailyPrayerTimes times;
  const PrayerTimesGrid({super.key, required this.times});

  String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final items = <_PrayerItem>[
      _PrayerItem(PrayerNames.fajr, times.fajr, Icons.nightlight_round),
      _PrayerItem(PrayerNames.dhuhr, times.dhuhr, Icons.wb_sunny),
      _PrayerItem(PrayerNames.asr, times.asr, Icons.sunny_snowing),
      _PrayerItem(PrayerNames.maghrib, times.maghrib, Icons.nightlight_outlined),
      _PrayerItem(PrayerNames.isha, times.isha, Icons.brightness_2_outlined),
    ];

    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700.w;
          if (isWide) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 3.6,
              ),
              itemCount: items.length,
              itemBuilder:
                  (context, i) => _PrayerRow(
                    title: items[i].title,
                    time: _fmt(items[i].time),
                    icon: items[i].icon,
                  ),
            );
          }
          return Column(
            children: [
              for (final it in items) ...[
                _PrayerRow(title: it.title, time: _fmt(it.time), icon: it.icon),
                SizedBox(height: 10.h),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PrayerItem {
  final String title;
  final DateTime time;
  final IconData icon;
  _PrayerItem(this.title, this.time, this.icon);
}

class _PrayerRow extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  const _PrayerRow({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: PrayerTimesDecorations.gridRowContainer(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PrayerTimesTextStyles.prayerRowTitle,
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: PrayerTimesTextStyles.prayerRowTime,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 36.r,
            height: 36.r,
            decoration: PrayerTimesDecorations.gridRowIconBg(),
            child: Icon(icon, color: ColorsManager.purpleText, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
