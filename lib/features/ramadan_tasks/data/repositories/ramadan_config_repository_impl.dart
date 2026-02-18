import '../../domain/repositories/ramadan_config_repository.dart';
import '../datasources/ramadan_config_remote_datasource.dart';

/// Implementation of Ramadan configuration repository.
///
/// Delegates to the remote datasource while providing a clean domain interface.
class RamadanConfigRepositoryImpl implements RamadanConfigRepository {
  final RamadanConfigRemoteDataSource _remoteDataSource;

  RamadanConfigRepositoryImpl({
    required RamadanConfigRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<void> initializeRemoteConfig() async {
    await _remoteDataSource.fetchAndActivate();
  }

  @override
  int getRamadanStartOffset() {
    return _remoteDataSource.getRamadanStartOffset();
  }

  @override
  int getRamadanTotalDays() {
    return _remoteDataSource.getRamadanTotalDays();
  }

  @override
  String getRamadanStartGregorian() {
    return _remoteDataSource.getRamadanStartGregorian();
  }

  @override
  int calculateCurrentRamadanDay() {
    // Get Gregorian start date from Remote Config
    final startDateString = getRamadanStartGregorian();

    // Fallback to day 1 if not configured
    if (startDateString.isEmpty) {
      return 1;
    }

    // Parse the start date safely
    final startDate = _parseGregorianDate(startDateString);
    if (startDate == null) {
      return 1;
    }

    // Get today's date (midnight for accurate day comparison)
    // For testing, uncomment the line below and set your test date:
    // For production, use DateTime.now():
     final today = DateTime.now();

    final todayMidnight = DateTime(today.year, today.month, today.day);

    // Calculate difference in days
    final diff = todayMidnight.difference(startDate).inDays + 1;

    // Return 0 if Ramadan hasn't started yet
    if (diff < 1) {
      return 0;
    }

    // Clamp to valid Ramadan day range (1 to totalDays)
    final totalDays = getRamadanTotalDays();
    return diff.clamp(1, totalDays);
  }

  /// Parses a Gregorian date string in 'yyyy-MM-dd' format.
  ///
  /// Returns null if parsing fails or format is invalid.
  DateTime? _parseGregorianDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) {
        return null;
      }

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // Create date at midnight for accurate day comparison
      return DateTime(year, month, day);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to parse ramadan_start_gregorian "$dateString": $e');
      return null;
    }
  }
}
