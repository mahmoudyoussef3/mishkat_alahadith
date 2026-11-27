import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_reading_local_datasource.dart';
import 'package:mishkat_almasabih/features/quran/data/repos/quran_reading_repo_impl.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../quran_fakes.dart';

void main() {
  late QuranReadingRepoImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = QuranReadingRepoImpl(QuranReadingLocalDataSource());
  });

  group('recitation settings', () {
    test('are the defaults before anything is saved', () async {
      expect(
        dataOf(await repo.getRecitationSettings()),
        RecitationSettings.defaults,
      );
    });

    test('round-trip every choice, the reciter\'s name included', () async {
      const saved = RecitationSettings(
        reciterId: 'ar.husary',
        reciterName: 'محمود خليل الحصري',
        repeat: AyahRepeat.thrice,
        speed: RecitationSpeed.faster,
        quality: RecitationQuality.dataSaver,
        continuous: false,
      );
      await repo.saveRecitationSettings(saved);

      expect(dataOf(await repo.getRecitationSettings()), saved);
    });

    test('an unusable stored reciter falls back to the default reciter and '
        'name', () async {
      SharedPreferences.setMockInitialValues({
        'quran_reciter': 'ar/../evil',
        'quran_reciter_name': 'Someone else',
      });

      final settings = dataOf(await repo.getRecitationSettings());

      expect(settings.reciterId, RecitationSettings.defaults.reciterId);
      expect(settings.reciterName, RecitationSettings.defaults.reciterName);
    });

    test('a reciter saved without a name is named by its identifier', () async {
      SharedPreferences.setMockInitialValues({'quran_reciter': 'ar.husary'});

      final settings = dataOf(await repo.getRecitationSettings());

      expect(settings.reciterId, 'ar.husary');
      expect(settings.reciterName, 'ar.husary');
    });

    test('unknown stored choices fall back to the defaults', () async {
      SharedPreferences.setMockInitialValues({
        'quran_ayah_repeat': 'sevenTimes',
        'quran_recitation_speed': 'ludicrous',
        'quran_recitation_quality': 'lossless',
      });

      final settings = dataOf(await repo.getRecitationSettings());

      expect(settings.repeat, RecitationSettings.defaults.repeat);
      expect(settings.speed, RecitationSettings.defaults.speed);
      expect(settings.quality, RecitationSettings.defaults.quality);
    });
  });

  group('commentary settings', () {
    test('are the default tafsir and no translation at first', () async {
      expect(
        dataOf(await repo.getCommentarySettings()),
        CommentarySettings.defaults,
      );
    });

    test('round-trip the tafsir and the translation', () async {
      const saved = CommentarySettings(
        tafsirId: 'ar.jalalayn',
        translationId: 'en.sahih',
      );
      await repo.saveCommentarySettings(saved);

      expect(dataOf(await repo.getCommentarySettings()), saved);
    });

    test('switching the translation off removes it', () async {
      await repo.saveCommentarySettings(
        const CommentarySettings(translationId: 'en.sahih'),
      );

      await repo.saveCommentarySettings(const CommentarySettings());

      expect(dataOf(await repo.getCommentarySettings()).translationId, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('quran_translation'), isFalse);
    });

    test('unusable stored editions fall back', () async {
      SharedPreferences.setMockInitialValues({
        'quran_tafsir': '../tafsir',
        'quran_translation': 'en sahih',
      });

      final settings = dataOf(await repo.getCommentarySettings());

      expect(settings.tafsirId, CommentarySettings.defaults.tafsirId);
      expect(settings.translationId, isNull);
    });
  });
}
