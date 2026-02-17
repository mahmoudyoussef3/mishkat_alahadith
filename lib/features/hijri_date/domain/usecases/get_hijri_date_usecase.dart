import 'package:hijri/hijri_calendar.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/repositories/hijri_repository.dart';

/// Use case for getting the current Hijri date with applied offset.
///
/// This use case:
/// 1. Gets the current calculated Hijri date
/// 2. Retrieves the offset from Remote Config
/// 3. Applies the offset to adjust the date
/// 4. Returns the corrected Hijri date
///
/// Why this matters:
/// Islamic dates are traditionally based on moon sighting, but apps use calculations.
/// When official announcements differ from calculations (common for Ramadan/Eid),
/// this system allows immediate correction for all users without app updates.
class GetHijriDateUseCase {
  final HijriRepository _repository;

  GetHijriDateUseCase({required HijriRepository repository})
    : _repository = repository;

  /// Gets the current Hijri date with remote offset applied.
  ///
  /// Process:
  /// 1. Creates HijriCalendar for current date
  /// 2. Gets offset from repository (defaults to 0 if unavailable)
  /// 3. Adjusts date by offset days
  /// 4. Returns adjusted HijriCalendar
  ///
  /// Example scenarios:
  /// - Offset = 0: Returns today's calculated date
  /// - Offset = 1: Returns tomorrow's calculated date (adds 1 day)
  /// - Offset = -1: Returns yesterday's calculated date (subtracts 1 day)
  ///
  /// Thread-safe and can be called from any isolate.
  HijriCalendar call() {
    // Get today's Hijri date based on calculation
    final hijriDate = HijriCalendar.now();

    // Get the offset value from Remote Config (0 if unavailable)
    final offset = _repository.getHijriDateOffset();

    // If offset is zero, return the calculated date as-is
    if (offset == 0) {
      return hijriDate;
    }

    // Apply the offset by converting to Gregorian, adjusting, and converting back
    // This ensures proper handling of month/year boundaries
    final gregorianDate = hijriDate.hijriToGregorian(
      hijriDate.hYear,
      hijriDate.hMonth,
      hijriDate.hDay,
    );

    // Add the offset days to the Gregorian date
    final adjustedGregorian = gregorianDate.add(Duration(days: offset));

    // Convert back to Hijri with the adjusted date
    return HijriCalendar.fromDate(adjustedGregorian);
  }
}
