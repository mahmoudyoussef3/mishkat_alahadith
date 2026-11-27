import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/ui/widgets/prayer_times_grid.dart';

DailyPrayerTimes _on(DateTime day) {
  DateTime at(int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);
  return DailyPrayerTimes(
    fajr: at(4, 24),
    sunrise: at(5, 49),
    dhuhr: at(11, 43),
    asr: at(15, 7),
    maghrib: at(17, 37),
    isha: at(18, 54),
  );
}

Widget _list(DailyPrayerTimes today, DateTime? next) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder:
      (_, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: PrayerTimesList(
              times: today,
              isToday: true,
              isPastDay: false,
              notificationsEnabled: true,
              nextPrayerTime: next,
            ),
          ),
        ),
      ),
);

void main() {
  final today = _on(DateTime.now());
  final tomorrow = _on(DateTime.now().add(const Duration(days: 1)));

  testWidgets('after Isha, today\'s Fajr is not marked as the next prayer', (
    tester,
  ) async {
    await tester.pumpWidget(_list(today, tomorrow.fajr));

    expect(find.text('التالية'), findsNothing);
  });

  testWidgets('marks the row whose time is the next prayer', (tester) async {
    await tester.pumpWidget(_list(today, today.asr));

    expect(find.text('التالية'), findsOneWidget);
  });
}
