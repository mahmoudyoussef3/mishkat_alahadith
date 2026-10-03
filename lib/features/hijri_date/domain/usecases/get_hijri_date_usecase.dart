import 'package:hijri/hijri_calendar.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/repositories/hijri_repository.dart';

class GetHijriDateUseCase {
  final HijriRepository _repository;

  GetHijriDateUseCase({required HijriRepository repository})
    : _repository = repository;

  HijriCalendar call() {
    final hijriDate = HijriCalendar.now();

    final offset = _repository.getHijriDateOffset();

    if (offset == 0) {
      return hijriDate;
    }

    final gregorianDate = hijriDate.hijriToGregorian(
      hijriDate.hYear,
      hijriDate.hMonth,
      hijriDate.hDay,
    );

    final adjustedGregorian = gregorianDate.add(Duration(days: offset));

    return HijriCalendar.fromDate(adjustedGregorian);
  }
}
