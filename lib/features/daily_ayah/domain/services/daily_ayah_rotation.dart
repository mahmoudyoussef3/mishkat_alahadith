/// Which entry of the catalog is featured on a given day.
///
/// Successive days step through the catalog by a stride that shares no factor
/// with its length, so every entry comes up exactly once per cycle and ayahs
/// that sit next to each other in the catalog land weeks apart.
///
/// Only the calendar date counts, never the time or the time zone offset, so
/// the notification, the widget and the app agree all day long.
abstract final class DailyAyahRotation {
  /// The share of the catalog skipped from one day to the next. The golden
  /// ratio keeps successive picks well spread whatever the catalog's length.
  static const double _strideRatio = 0.618;

  /// The catalog index featured on the calendar day of [day].
  static int indexFor(DateTime day, int catalogLength) {
    if (catalogLength < 1) {
      throw ArgumentError.value(catalogLength, 'catalogLength', 'is empty');
    }
    return (dayNumber(day) * _strideFor(catalogLength)) % catalogLength;
  }

  /// Days from 1 January 1970 to the calendar day of [day].
  static int dayNumber(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  static int _strideFor(int length) {
    var stride = (length * _strideRatio).round().clamp(1, length);
    while (stride.gcd(length) != 1) {
      stride++;
    }
    return stride;
  }
}
