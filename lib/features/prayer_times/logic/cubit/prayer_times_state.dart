part of 'prayer_times_cubit.dart';

@immutable
sealed class PrayerTimesState {}

final class PrayerTimesInitial extends PrayerTimesState {}

final class PrayerTimesLoading extends PrayerTimesState {}

final class PrayerTimesLoaded extends PrayerTimesState {
  final DateTime date;
  final PrayerTimes times;
  final String? nextPrayerLabel;
  final DateTime? nextPrayerTime;
  final Duration? remaining;
  final AsrMethod asrMethod;

  PrayerTimesLoaded({
    required this.date,
    required this.times,
    required this.nextPrayerLabel,
    required this.nextPrayerTime,
    required this.remaining,
    required this.asrMethod,
  });

  PrayerTimesLoaded copyWith({
    DateTime? date,
    PrayerTimes? times,
    String? nextPrayerLabel,
    DateTime? nextPrayerTime,
    Duration? remaining,
    AsrMethod? asrMethod,
  }) {
    return PrayerTimesLoaded(
      date: date ?? this.date,
      times: times ?? this.times,
      nextPrayerLabel: nextPrayerLabel ?? this.nextPrayerLabel,
      nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
      remaining: remaining ?? this.remaining,
      asrMethod: asrMethod ?? this.asrMethod,
    );
  }
}

final class PrayerTimesError extends PrayerTimesState {
  final String message;
  PrayerTimesError(this.message);
}
