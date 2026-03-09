import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/models/location_model.dart';
part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  PrayerTimesCubit() : super(PrayerTimesInitial());

  Timer? _ticker;
  LocationModel _currentLocation = LocationModel.defaultLocation;
  PrayerTimes? _prayerTimes;

  LocationModel get currentLocation => _currentLocation;

  Future<void> init() async {
    emit(PrayerTimesLoading());
    try {
      // Load saved location or use default
      await _loadSavedLocation();
      
      final times = _calculatePrayerTimes(_currentLocation);
      final date = DateTime.now();
      final loaded = _buildLoaded(date, times);
      emit(loaded);

      _startTicker();
    } catch (e) {
      debugPrint('Error in init: $e');
      emit(PrayerTimesError('تعذر حساب مواقيت الصلاة'));
    }
  }

  PrayerTimes _calculatePrayerTimes(LocationModel location) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;
    
    final prayerTimes = PrayerTimes.today(coordinates, params);
    _prayerTimes = prayerTimes;
    return prayerTimes;
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString('prayer_location');
      if (locationJson != null) {
        final json = jsonDecode(locationJson) as Map<String, dynamic>;
        _currentLocation = LocationModel.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  Future<void> _saveLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('prayer_location', jsonEncode(location.toJson()));
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  /// Update prayer times with a new location
  Future<void> updateLocation(LocationModel location) async {
    emit(PrayerTimesLoading());
    try {
      _currentLocation = location;
      await _saveLocation(location);

      final times = _calculatePrayerTimes(location);
      final date = DateTime.now();
      final loaded = _buildLoaded(date, times);
      emit(loaded);

      _startTicker();
    } catch (e) {
      debugPrint('Error updating location: $e');
      emit(PrayerTimesError('تعذر حساب مواقيت الصلاة'));
    }
  }

  /// Get user's current location and update prayer times
  Future<void> useCurrentLocation() async {
    try {
      debugPrint('🔍 Starting location request...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        emit(PrayerTimesError('الرجاء تفعيل خدمات الموقع على جهازك'));
        return;
      }

      debugPrint('✅ Location services enabled');

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        debugPrint('🔐 Requesting permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('📍 Permission after request: $permission');
        
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Permission denied');
          emit(PrayerTimesError('يجب السماح بالوصول إلى الموقع'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Permission denied forever');
        emit(PrayerTimesError('تم رفض الوصول إلى الموقع بشكل دائم. الرجاء تفعيله من الإعدادات'));
        return;
      }

      debugPrint('✅ Permission granted, getting position...');
      emit(PrayerTimesLoading());
      
      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('✅ Position obtained: ${position.latitude}, ${position.longitude}');

      // Calculate timezone offset (simplified - using device timezone)
      final timezoneOffset = DateTime.now().timeZoneOffset.inHours;

      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'موقعك الحالي',
        timezone: timezoneOffset >= 0 ? '+$timezoneOffset.0' : '$timezoneOffset.0',
      );

      debugPrint('📍 Updating location to: ${location.cityName}');
      await updateLocation(location);
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting location: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(PrayerTimesError('تعذر الحصول على الموقع الحالي: ${e.toString()}'));
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is! PrayerTimesLoaded) return;

      // Recalculate at day change
      final now = DateTime.now();
      if (!_isSameDay(now, current.date)) {
        final newTimes = _calculatePrayerTimes(_currentLocation);
        emit(_buildLoaded(now, newTimes));
        return;
      }

      // Update remaining time for next prayer
      if (_prayerTimes != null) {
        final nextPrayer = _getNextPrayer(now);
        if (nextPrayer != null) {
          final remaining = _calculateRemaining(nextPrayer, now);
          emit(
            current.copyWith(
              remaining: remaining,
              nextPrayerLabel: _arabicLabel(nextPrayer.$1),
              nextPrayerTime: nextPrayer.$2,
            ),
          );
        }
      }
    });
  }

  (String, DateTime)? _getNextPrayer(DateTime now) {
    if (_prayerTimes == null) return null;

    final prayers = [
      ('fajr', _prayerTimes!.fajr),
      ('dhuhr', _prayerTimes!.dhuhr),
      ('asr', _prayerTimes!.asr),
      ('maghrib', _prayerTimes!.maghrib),
      ('isha', _prayerTimes!.isha),
    ];

    for (final prayer in prayers) {
      if (prayer.$2.isAfter(now)) {
        return prayer;
      }
    }

    // If no prayer remaining today, return tomorrow's Fajr
    return ('fajr', _prayerTimes!.fajr.add(const Duration(days: 1)));
  }

  Duration _calculateRemaining((String, DateTime) nextPrayer, DateTime now) {
    return nextPrayer.$2.difference(now);
  }

  PrayerTimesLoaded _buildLoaded(DateTime date, PrayerTimes times) {
    final now = DateTime.now();
    final nextPrayer = _getNextPrayer(now);
    
    return PrayerTimesLoaded(
      date: DateTime(date.year, date.month, date.day),
      times: times,
      nextPrayerLabel: nextPrayer != null ? _arabicLabel(nextPrayer.$1) : null,
      nextPrayerTime: nextPrayer?.$2,
      remaining: nextPrayer != null ? _calculateRemaining(nextPrayer, now) : null,
    );
  }

  String? _arabicLabel(String? name) {
    switch (name) {
      case 'fajr':
        return 'الفجر';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
