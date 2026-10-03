import 'package:hijri/hijri_calendar.dart';

abstract class HijriDateState {}

class HijriDateInitial extends HijriDateState {}

class HijriDateLoading extends HijriDateState {}

class HijriDateLoaded extends HijriDateState {
  final HijriCalendar hijriDate;
  final int appliedOffset;

  HijriDateLoaded({required this.hijriDate, required this.appliedOffset});
}

class HijriDateError extends HijriDateState {
  final String message;

  HijriDateError({required this.message});
}
