import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/entities/search_history_entry.dart';

void main() {
  test('stamps a query with a zero-padded date and 24-hour time', () {
    final entry = NewSearchHistoryEntry.forQuery(
      'الصبر',
      DateTime(2026, 3, 7, 9, 5, 4),
    );

    expect(entry.title, 'الصبر');
    expect(entry.date, '2026-03-07');
    expect(entry.time, '09:05:04');
  });

  test('trims the query', () {
    final entry = NewSearchHistoryEntry.forQuery(
      '  بر الوالدين ',
      DateTime(2026, 10, 4, 21, 30),
    );

    expect(entry.title, 'بر الوالدين');
    expect(entry.time, '21:30:00');
  });
}
