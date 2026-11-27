import 'package:mishkat_almasabih/core/helpers/arabic_time_format.dart';
import 'package:adhan/adhan.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_location_store.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_times_calculator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';
import 'package:mishkat_almasabih/core/helpers/date_extensions.dart';

class PrayerTimesHomeWidgetSync {
  static const PrayerTimesCalculator _calculator = PrayerTimesCalculator();

  static Future<void> refresh() async {
    try {
      final location = await _resolveLocation();
      final now = DateTime.now();
      final prayerTimes = _calculator.calculate(
        latitude: location.latitude,
        longitude: location.longitude,
        date: now,
      );

      final prayers = <_PrayerItem>[
        _PrayerItem('fajr', PrayerNames.fajr, prayerTimes.fajr),
        _PrayerItem('sunrise', PrayerNames.sunrise, prayerTimes.sunrise),
        _PrayerItem('dhuhr', PrayerNames.dhuhr, prayerTimes.dhuhr),
        _PrayerItem('asr', PrayerNames.asr, prayerTimes.asr),
        _PrayerItem('maghrib', PrayerNames.maghrib, prayerTimes.maghrib),
        _PrayerItem('isha', PrayerNames.isha, prayerTimes.isha),
      ];

      final next = _resolveNextPrayer(prayers, now);
      final hijriDate = _formatHijriDate(now);
      final gregorianDate = _formatGregorianDate(now);
      final tomorrow = now.nextCalendarDay;
      final tomorrowPrayerTimes = _calculator.calculate(
        latitude: location.latitude,
        longitude: location.longitude,
        date: tomorrow,
      );
      final tomorrowPrayers = <_PrayerItem>[
        _PrayerItem('fajr', PrayerNames.fajr, tomorrowPrayerTimes.fajr),
        _PrayerItem('sunrise', PrayerNames.sunrise, tomorrowPrayerTimes.sunrise),
        _PrayerItem('dhuhr', PrayerNames.dhuhr, tomorrowPrayerTimes.dhuhr),
        _PrayerItem('asr', PrayerNames.asr, tomorrowPrayerTimes.asr),
        _PrayerItem('maghrib', PrayerNames.maghrib, tomorrowPrayerTimes.maghrib),
        _PrayerItem('isha', PrayerNames.isha, tomorrowPrayerTimes.isha),
      ];
      final tomorrowNext = _resolveNextPrayer(tomorrowPrayers, tomorrow);

      await HomeWidget.saveWidgetData<int>(
        'prayer_widget_day_millis',
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData<String>('prayer_hijri_date', hijriDate);
      await HomeWidget.saveWidgetData<String>(
        'prayer_gregorian_date',
        gregorianDate,
      );
      await HomeWidget.saveWidgetData<String>(
        'prayer_tomorrow_hijri_date',
        _formatHijriDate(tomorrow),
      );
      await HomeWidget.saveWidgetData<String>(
        'prayer_tomorrow_gregorian_date',
        _formatGregorianDate(tomorrow),
      );

      await HomeWidget.saveWidgetData<String>(
        'prayer_fajr',
        _formatTime(prayerTimes.fajr),
      );
      await HomeWidget.saveWidgetData<String>(
        'prayer_sunrise',
        _formatTime(prayerTimes.sunrise),
      );
      await HomeWidget.saveWidgetData<String>(
        'prayer_dhuhr',
        _formatTime(prayerTimes.dhuhr),
      );
      await HomeWidget.saveWidgetData<String>(
        'prayer_asr',
        _formatTime(prayerTimes.asr),
      );
      await HomeWidget.saveWidgetData<String>(
        'prayer_maghrib',
        _formatTime(prayerTimes.maghrib),
      );
      await HomeWidget.saveWidgetData<String>(
        'prayer_isha',
        _formatTime(prayerTimes.isha),
      );

      await HomeWidget.saveWidgetData<int>(
        'prayer_fajr_millis',
        prayerTimes.fajr.millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData<int>(
        'prayer_sunrise_millis',
        prayerTimes.sunrise.millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData<int>(
        'prayer_dhuhr_millis',
        prayerTimes.dhuhr.millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData<int>(
        'prayer_asr_millis',
        prayerTimes.asr.millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData<int>(
        'prayer_maghrib_millis',
        prayerTimes.maghrib.millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData<int>(
        'prayer_isha_millis',
        prayerTimes.isha.millisecondsSinceEpoch,
      );

      await _savePrayerData('prayer_tomorrow', tomorrowPrayerTimes);
      await HomeWidget.saveWidgetData<int>(
        'prayer_tomorrow_fajr_millis',
        tomorrowPrayerTimes.fajr.millisecondsSinceEpoch,
      );

      await HomeWidget.saveWidgetData<String>('prayer_next_key', next.key);
      await HomeWidget.saveWidgetData<String>(
        'prayer_tomorrow_next_key',
        tomorrowNext.key,
      );

      await HomeWidget.updateWidget(
        name: 'PrayerTimesWidgetProvider',
        iOSName: 'PrayerTimesWidget',
      );
    } catch (_) {
    }
  }

  static _PrayerItem _resolveNextPrayer(
    List<_PrayerItem> prayers,
    DateTime now,
  ) {
    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }

    final fajr = prayers.firstWhere((prayer) => prayer.key == 'fajr');
    return _PrayerItem(
      fajr.key,
      PrayerNames.fajr,
      fajr.time.add(const Duration(days: 1)),
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatHijriDate(DateTime now) {
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    return '${_toArabicNumerals(hijri.hDay)} ${hijri.getLongMonthName()} ${_toArabicNumerals(hijri.hYear)} هـ';
  }

  static String _formatGregorianDate(DateTime now) {
    final months = <String>[
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${arabicWeekday(now)}، ${_toArabicNumerals(now.day)} ${months[now.month - 1]} ${_toArabicNumerals(now.year)} م';
  }

  static String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicDigits[int.parse(digit)])
        .join();
  }

  static Future<void> _savePrayerData(String prefix, PrayerTimes times) async {
    await HomeWidget.saveWidgetData<String>(
      '${prefix}_fajr',
      _formatTime(times.fajr),
    );
    await HomeWidget.saveWidgetData<String>(
      '${prefix}_sunrise',
      _formatTime(times.sunrise),
    );
    await HomeWidget.saveWidgetData<String>(
      '${prefix}_dhuhr',
      _formatTime(times.dhuhr),
    );
    await HomeWidget.saveWidgetData<String>(
      '${prefix}_asr',
      _formatTime(times.asr),
    );
    await HomeWidget.saveWidgetData<String>(
      '${prefix}_maghrib',
      _formatTime(times.maghrib),
    );
    await HomeWidget.saveWidgetData<String>(
      '${prefix}_isha',
      _formatTime(times.isha),
    );
    await HomeWidget.saveWidgetData<int>(
      '${prefix}_fajr_millis',
      times.fajr.millisecondsSinceEpoch,
    );
    await HomeWidget.saveWidgetData<int>(
      '${prefix}_sunrise_millis',
      times.sunrise.millisecondsSinceEpoch,
    );
    await HomeWidget.saveWidgetData<int>(
      '${prefix}_dhuhr_millis',
      times.dhuhr.millisecondsSinceEpoch,
    );
    await HomeWidget.saveWidgetData<int>(
      '${prefix}_asr_millis',
      times.asr.millisecondsSinceEpoch,
    );
    await HomeWidget.saveWidgetData<int>(
      '${prefix}_maghrib_millis',
      times.maghrib.millisecondsSinceEpoch,
    );
    await HomeWidget.saveWidgetData<int>(
      '${prefix}_isha_millis',
      times.isha.millisecondsSinceEpoch,
    );
  }

  static Future<_WidgetLocation> _resolveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final json = PrayerLocationStore.read(prefs);

    if (json != null) {
      try {
        return _WidgetLocation(
          latitude: (json['latitude'] as num?)?.toDouble() ?? PrayerDefaults.latitude,
          longitude: (json['longitude'] as num?)?.toDouble() ?? PrayerDefaults.longitude,
          cityName:
              (json['cityName'] as String?)?.trim().isNotEmpty == true
                  ? json['cityName'] as String
                  : PrayerDefaults.cityName,
        );
      } catch (_) {
      }
    }

    return const _WidgetLocation(
      latitude: PrayerDefaults.latitude,
      longitude: PrayerDefaults.longitude,
      cityName: PrayerDefaults.cityName,
    );
  }
}

class _PrayerItem {
  final String key;
  final String label;
  final DateTime time;

  const _PrayerItem(this.key, this.label, this.time);
}

class _WidgetLocation {
  final double latitude;
  final double longitude;
  final String cityName;

  const _WidgetLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });
}
