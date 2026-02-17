import 'package:hijri/hijri_calendar.dart';

/// States for Hijri Date feature
abstract class HijriDateState {}

/// Initial state before any date is loaded
class HijriDateInitial extends HijriDateState {}

/// Loading state while fetching date
class HijriDateLoading extends HijriDateState {}

/// Success state with the loaded Hijri date
class HijriDateLoaded extends HijriDateState {
  final HijriCalendar hijriDate;
  final int appliedOffset;

  HijriDateLoaded({required this.hijriDate, required this.appliedOffset});
}

/// Error state if something goes wrong
class HijriDateError extends HijriDateState {
  final String message;

  HijriDateError({required this.message});
}
