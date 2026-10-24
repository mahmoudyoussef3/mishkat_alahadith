import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/datasources/daily_ayah_catalog.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/datasources/daily_ayah_reminder_datasource.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/datasources/daily_ayah_widget_datasource.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/repos/daily_ayah_repo_impl.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/get_daily_ayahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_text_local_datasource.dart';
import 'package:mishkat_almasabih/features/quran/data/repos/quran_repo_impl.dart';

import '../../quran/quran_fakes.dart';

/// Runs against the mushaf text bundled with `mushaf_text`, so a reference
/// that names no ayah is caught here rather than on a reader's home screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const catalog = DailyAyahCatalog.ayahs;

  test('names each ayah once', () {
    expect(catalog.toSet(), hasLength(catalog.length));
  });

  test('is kept in mushaf order', () {
    for (var i = 1; i < catalog.length; i++) {
      final previous = catalog[i - 1];
      final current = catalog[i];
      expect(
        current.surah > previous.surah ||
            (current.surah == previous.surah && current.ayah > previous.ayah),
        isTrue,
        reason: '$current comes after $previous',
      );
    }
  });

  test('every day of a full cycle resolves to an ayah of the mushaf',
      () async {
    final getDailyAyahs = GetDailyAyahsUseCase(
      DailyAyahRepoImpl(
        DailyAyahWidgetDataSource(),
        DailyAyahReminderDataSource(),
      ),
      QuranRepoImpl(QuranTextLocalDataSource()),
    );

    final days = dataOf(
      await getDailyAyahs(from: DateTime(2026), days: catalog.length),
    );

    expect(days, hasLength(catalog.length));
    expect(
      days.map((d) => (d.ayah.surahNumber, d.ayah.number)).toSet(),
      {for (final r in catalog) (r.surah, r.ayah)},
    );
  });
}
