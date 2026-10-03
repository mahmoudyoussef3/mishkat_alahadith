import 'dart:async';
import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mishkat_almasabih/core/notification/prayer_time_notification_scheduler.dart';
import 'package:mishkat_almasabih/core/services/prayer_times_home_widget_sync.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  PrayerTimesCubit() : super(PrayerTimesInitial());

  static const String _notificationLocationKey = 'prayer_notification_location';
  static const String _legacyLocationKey = 'prayer_location';

  Timer? _ticker;
  LocationModel _currentLocation = LocationModel.defaultLocation;
  PrayerTimes? _prayerTimes;

  LocationModel get currentLocation => _currentLocation;

  Future<void> init() async {
    emit(PrayerTimesLoading());
    try {
      await _loadSavedLocation();
      final times = _calculatePrayerTimes(_currentLocation);
      emit(_buildLoaded(DateTime.now(), times));
      _startTicker();
      unawaited(PrayerTimesHomeWidgetSync.refresh());
    } catch (e) {
      debugPrint('Error in prayer times init: $e');
      emit(PrayerTimesError('تعذر حساب مواقيت الصلاة'));
    }
  }

  PrayerTimes _calculatePrayerTimes(LocationModel location) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(DateTime.now()),
      params,
    );
    _prayerTimes = prayerTimes;
    return prayerTimes;
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson =
          prefs.getString(_notificationLocationKey) ??
          prefs.getString(_legacyLocationKey);
      if (locationJson == null || locationJson.isEmpty) return;

      final json = jsonDecode(locationJson) as Map<String, dynamic>;
      _currentLocation = LocationModel.fromJson(json);
    } catch (e) {
      debugPrint('Error loading saved prayer location: $e');
    }
  }

  Future<void> _saveLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = jsonEncode(location.toJson());
    await prefs.setString(_notificationLocationKey, locationJson);
    await prefs.setString(_legacyLocationKey, locationJson);
  }

  Future<void> updateLocation(LocationModel location) async {
    emit(PrayerTimesLoading());
    try {
      _currentLocation = location;
      await _saveLocation(location);

      final times = _calculatePrayerTimes(location);
      emit(_buildLoaded(DateTime.now(), times));

      _startTicker();
      await PrayerTimesHomeWidgetSync.refresh();
      unawaited(PrayerNotificationScheduler.refreshSchedule());
    } catch (e) {
      debugPrint('Error updating prayer location: $e');
      emit(PrayerTimesError('تعذر حساب مواقيت الصلاة'));
    }
  }

  Future<void> useCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(PrayerTimesError('الرجاء تفعيل خدمات الموقع على جهازك'));
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        emit(PrayerTimesError('يجب السماح بالوصول إلى الموقع'));
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          PrayerTimesError(
            'تم رفض الوصول إلى الموقع بشكل دائم. الرجاء تفعيله من الإعدادات',
          ),
        );
        return;
      }

      emit(PrayerTimesLoading());
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final timezoneOffset = DateTime.now().timeZoneOffset.inHours;
      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'موقعك الحالي',
        timezone:
            timezoneOffset >= 0 ? '+$timezoneOffset.0' : '$timezoneOffset.0',
      );

      await updateLocation(location);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      emit(PrayerTimesError('تعذر الحصول على الموقع الحالي'));
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is! PrayerTimesLoaded) return;

      final now = DateTime.now();
      if (!_isSameDay(now, current.date)) {
        final newTimes = _calculatePrayerTimes(_currentLocation);
        emit(_buildLoaded(now, newTimes));
        unawaited(PrayerTimesHomeWidgetSync.refresh());
        unawaited(PrayerNotificationScheduler.refreshSchedule());
        return;
      }

      final nextPrayer = _getNextPrayer(now);
      if (nextPrayer == null) return;

      emit(
        current.copyWith(
          remaining: nextPrayer.$2.difference(now),
          nextPrayerLabel: _arabicLabel(nextPrayer.$1),
          nextPrayerTime: nextPrayer.$2,
        ),
      );
    });
  }

  (String, DateTime)? _getNextPrayer(DateTime now) {
    final prayerTimes = _prayerTimes;
    if (prayerTimes == null) return null;

    final prayers = [
      ('fajr', prayerTimes.fajr),
      ('dhuhr', prayerTimes.dhuhr),
      ('asr', prayerTimes.asr),
      ('maghrib', prayerTimes.maghrib),
      ('isha', prayerTimes.isha),
    ];

    for (final prayer in prayers) {
      if (prayer.$2.isAfter(now)) return prayer;
    }

    final tomorrow = now.add(const Duration(days: 1));
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;
    final tomorrowTimes = PrayerTimes(
      Coordinates(_currentLocation.latitude, _currentLocation.longitude),
      DateComponents.from(tomorrow),
      params,
    );
    return ('fajr', tomorrowTimes.fajr);
  }

  PrayerTimesLoaded _buildLoaded(DateTime date, PrayerTimes times) {
    final now = DateTime.now();
    final nextPrayer = _getNextPrayer(now);

    return PrayerTimesLoaded(
      date: DateTime(date.year, date.month, date.day),
      times: times,
      nextPrayerLabel: _arabicLabel(nextPrayer?.$1),
      nextPrayerTime: nextPrayer?.$2,
      remaining: nextPrayer?.$2.difference(now),
    );
  }

  String? _arabicLabel(String? name) {
    return switch (name) {
      'fajr' => 'الفجر',
      'dhuhr' => 'الظهر',
      'asr' => 'العصر',
      'maghrib' => 'المغرب',
      'isha' => 'العشاء',
      _ => null,
    };
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
