extension CalendarDay on DateTime {
  DateTime get nextCalendarDay => DateTime(year, month, day + 1);
}
