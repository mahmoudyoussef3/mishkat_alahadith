import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/notification/daily_ayah_payload.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/mappers/daily_ayah_mappers.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/entities/daily_ayah.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/services/daily_ayah_rotation.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';

import '../../quran/quran_fakes.dart';

void main() {
  final day = DateTime(2026, 10, 23);

  // The opening of 2:255, behind a quarter-hizb mark only to check that the
  // mark is dropped.
  const verse = 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ';
  const ayatAlKursi = QuranAyah(
    id: 262,
    surahNumber: 2,
    number: 255,
    juz: 3,
    page: 42,
    text: '\u06DE $verse',
  );
  final dailyAyah = DailyAyah(day: day, ayah: ayatAlKursi, surah: baqarah);

  group('widget entry', () {
    final entry = dailyAyah.toWidgetEntry();

    test('is keyed by the day number the widget counts days by', () {
      expect(entry['day'], DailyAyahRotation.dayNumber(day));
    });

    test('quotes the ayah without its quarter-hizb mark', () {
      expect(entry['text'], '\uFD3F$verse\uFD3E');
    });

    test('names the surah and ayah, and the page, in Arabic digits', () {
      expect(entry['reference'], 'سورة البقرة · الآية ٢٥٥');
      expect(entry['page'], 'الصفحة ٤٢');
    });

    test('carries the payload that opens the ayah', () {
      expect(
        DailyAyahPayload.tryParse(entry['payload'] as String?),
        const DailyAyahPayload(ayahId: 262, page: 42, surahNumber: 2),
      );
    });
  });

  group('notification', () {
    final fireAt = DateTime(2026, 10, 23, 8);
    final notification = (fireAt: fireAt, dailyAyah: dailyAyah).toNotification();

    test('is titled آية اليوم and subtitled with the reference', () {
      expect(notification.title, 'آية اليوم');
      expect(notification.subtitle, 'سورة البقرة · الآية ٢٥٥');
    });

    test('goes out at the reminder time with the payload', () {
      expect(notification.fireAt, fireAt);
      expect(
        DailyAyahPayload.tryParse(notification.payload)?.ayahId,
        ayatAlKursi.id,
      );
    });

    test('has one id per day, apart from the next day', () {
      final tomorrow = (
        fireAt: fireAt.add(const Duration(days: 1)),
        dailyAyah: DailyAyah(
          day: DateTime(2026, 10, 24),
          ayah: ayatAlKursi,
          surah: baqarah,
        ),
      ).toNotification();

      expect(tomorrow.id, notification.id + 1);
    });
  });

  group('DailyAyahText.forSystemFont', () {
    test('writes the stacked tanween as the plain tanween', () {
      expect(
        DailyAyahText.forSystemFont('د\u0657 ر\u065E م\u0656'),
        'د\u064B ر\u064C م\u064D',
      );
    });

    test('leaves the other Quranic marks as they are', () {
      const text = 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ';

      expect(DailyAyahText.forSystemFont(text), text);
    });
  });
}
