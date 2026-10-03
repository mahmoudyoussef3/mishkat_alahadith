import 'package:firebase_remote_config/firebase_remote_config.dart';

abstract class RamadanConfigRemoteDataSource {
  Future<void> fetchAndActivate();

  int getRamadanStartOffset();

  int getRamadanTotalDays();

  String getRamadanStartGregorian();
}

class RamadanConfigRemoteDataSourceImpl
    implements RamadanConfigRemoteDataSource {
  final FirebaseRemoteConfig _remoteConfig;

  static const String _ramadanStartOffsetKey = 'ramadan_start_offset';

  static const String _ramadanTotalDaysKey = 'ramadan_total_days';

  static const String _ramadanStartGregorianKey = 'ramadan_start_gregorian';

  static const int _defaultStartOffset = 0;
  static const int _defaultTotalDays = 30;
  static const String _defaultStartGregorian = '';

  RamadanConfigRemoteDataSourceImpl({
    required FirebaseRemoteConfig remoteConfig,
  }) : _remoteConfig = remoteConfig;

  @override
  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // ignore: avoid_print
      print('Failed to fetch Ramadan Remote Config: $e');
    }
  }

  @override
  int getRamadanStartOffset() {
    try {
      final offset = _remoteConfig.getInt(_ramadanStartOffsetKey);
      return offset.clamp(-2, 2);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to read ramadan_start_offset: $e');
      return _defaultStartOffset;
    }
  }

  @override
  int getRamadanTotalDays() {
    try {
      final days = _remoteConfig.getInt(_ramadanTotalDaysKey);
      return days == 29 ? 29 : 30;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to read ramadan_total_days: $e');
      return _defaultTotalDays;
    }
  }

  @override
  String getRamadanStartGregorian() {
    try {
      final startDate = _remoteConfig.getString(_ramadanStartGregorianKey);
      return startDate;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to read ramadan_start_gregorian: $e');
      return _defaultStartGregorian;
    }
  }
}
