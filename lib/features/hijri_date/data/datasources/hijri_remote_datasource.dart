import 'package:firebase_remote_config/firebase_remote_config.dart';

abstract class HijriRemoteDataSource {
  Future<void> fetchAndActivate();

  int getHijriOffset();
}

class HijriRemoteDataSourceImpl implements HijriRemoteDataSource {
  final FirebaseRemoteConfig _remoteConfig;

  static const String _hijriOffsetKey = 'hijri_offset';

  static const int _defaultOffset = 0;

  HijriRemoteDataSourceImpl({required FirebaseRemoteConfig remoteConfig})
    : _remoteConfig = remoteConfig;

  @override
  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // ignore: avoid_print
      print('Failed to fetch Remote Config: $e');
    }
  }

  @override
  int getHijriOffset() {
    try {
      return _remoteConfig.getInt(_hijriOffsetKey);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to read hijri_offset from Remote Config: $e');
      return _defaultOffset;
    }
  }
}
