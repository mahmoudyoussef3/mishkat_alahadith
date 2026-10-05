part of 'prayer_times_cubit.dart';

@immutable
sealed class PrayerTimesState {}

final class PrayerTimesInitial extends PrayerTimesState {}

final class PrayerTimesLoading extends PrayerTimesState {}

final class PrayerTimesLoaded extends PrayerTimesState {
  /// Today; the countdown always follows it.
  final DateTime date;
  final DailyPrayerTimes times;
  final String? nextPrayerLabel;
  final DateTime? nextPrayerTime;
  final Duration? remaining;

  /// The prayer before the next one, for showing progress between them.
  final String? previousPrayerLabel;
  final DateTime? previousPrayerTime;

  /// The day whose times are listed, which the reader can move away from
  /// today; and its times.
  final DateTime selectedDate;
  final DailyPrayerTimes selectedTimes;

  PrayerTimesLoaded({
    required this.date,
    required this.times,
    required this.nextPrayerLabel,
    required this.nextPrayerTime,
    required this.remaining,
    this.previousPrayerLabel,
    this.previousPrayerTime,
    DateTime? selectedDate,
    DailyPrayerTimes? selectedTimes,
  }) : selectedDate = selectedDate ?? date,
       selectedTimes = selectedTimes ?? times;

  bool get isShowingToday =>
      selectedDate.year == date.year &&
      selectedDate.month == date.month &&
      selectedDate.day == date.day;

  PrayerTimesLoaded copyWith({
    DateTime? date,
    DailyPrayerTimes? times,
    String? nextPrayerLabel,
    DateTime? nextPrayerTime,
    Duration? remaining,
    String? previousPrayerLabel,
    DateTime? previousPrayerTime,
    DateTime? selectedDate,
    DailyPrayerTimes? selectedTimes,
  }) {
    return PrayerTimesLoaded(
      date: date ?? this.date,
      times: times ?? this.times,
      nextPrayerLabel: nextPrayerLabel ?? this.nextPrayerLabel,
      nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
      remaining: remaining ?? this.remaining,
      previousPrayerLabel: previousPrayerLabel ?? this.previousPrayerLabel,
      previousPrayerTime: previousPrayerTime ?? this.previousPrayerTime,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimes: selectedTimes ?? this.selectedTimes,
    );
  }
}

final class PrayerTimesError extends PrayerTimesState {
  final String message;

  PrayerTimesError(this.message);
}
