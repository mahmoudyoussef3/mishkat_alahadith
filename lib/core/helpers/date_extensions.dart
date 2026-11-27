extension CalendarDay on DateTime {
  DateTime get nextCalendarDay => DateTime(year, month, day + 1);

  /// Number of days in this date's month, leap years included.
  int get daysInMonth => DateTime(year, month + 1, 0).day;
}
