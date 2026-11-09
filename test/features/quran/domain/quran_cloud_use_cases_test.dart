import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition_search.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_hizb_quarter.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_quran_editions_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_ayah_commentary_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_hizb_index_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_editions_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_reflection_ayah_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surah_commentary_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/load_recitation_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/quran_study_settings_use_cases.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/search_quran_edition_use_case.dart';

import '../quran_fakes.dart';

QuranEdition _edition(
  String id, {
  String? name,
  String language = 'ar',
  QuranEditionType type = QuranEditionType.recitation,
}) => QuranEdition(
  identifier: id,
  name: name ?? id,
  englishName: id,
  language: language,
  type: type,
  isRightToLeft: language == 'ar',
);

/// 240 quarters, each starting at one of [ayahs] by its surah and number.
List<QuranAyahRef> _starts(List<({int surah, int ayah})> firsts) => [
  ...firsts,
  for (var i = firsts.length; i < QuranMetrics.hizbQuarterCount; i++)
    firsts.last,
];

void main() {
  group('RecitationScope', () {
    test('carries on into the next of its kind', () {
      expect(
        const RecitationScope.surah(2).next,
        const RecitationScope.surah(3),
      );
    });

    test('has nothing after the last of its kind', () {
      expect(const RecitationScope.juz(30).next, isNull);
      expect(const RecitationScope.hizbQuarter(240).next, isNull);
    });

    test('is valid only within the mushaf', () {
      expect(const RecitationScope.page(604).isValid, isTrue);
      expect(const RecitationScope.page(605).isValid, isFalse);
      expect(const RecitationScope.surah(0).isValid, isFalse);
    });
  });

  group('QuranHizbQuarter', () {
    QuranHizbQuarter quarter(int number, {int startAyahId = 1}) =>
        QuranHizbQuarter(
          number: number,
          startAyahId: startAyahId,
          surahNumber: 1,
          surahName: '',
          ayahNumber: 1,
          page: 1,
        );

    test('places a quarter in its hizb and juz', () {
      final q = quarter(7);
      expect(q.hizb, 2);
      expect(q.quarter, 2);
      expect(q.juz, 1);
      expect(quarter(9).juz, 2);
      expect(quarter(240).hizb, 60);
    });

    test('finds the quarter an ayah falls in', () {
      final quarters = [
        quarter(1, startAyahId: 1),
        quarter(2, startAyahId: 33),
        quarter(3, startAyahId: 51),
      ];
      expect(QuranHizbQuarter.containingAyah(quarters, 40)?.number, 2);
      expect(QuranHizbQuarter.containingAyah(quarters, 51)?.number, 3);
    });
  });

  group('GetQuranEditionsUseCase.arrange', () {
    test('lists each Arabic reciter once, without read translations', () {
      final arranged =
          GetQuranEditionsUseCase.arrange(QuranEditionType.recitation, [
            _edition('ar.alafasy', name: 'مشاري العفاسي'),
            _edition('en.walk', name: 'Ibrahim Walk', language: 'en'),
            _edition('ar.alafasy-2', name: 'مشاري العفاسي'),
            _edition('ar.husary', name: 'محمود خليل الحصري'),
          ]);
      expect(arranged.map((e) => e.identifier), ['ar.alafasy', 'ar.husary']);
    });

    test('puts Arabic tafsir first', () {
      final arranged =
          GetQuranEditionsUseCase.arrange(QuranEditionType.tafsir, [
            _edition('en.x', language: 'en', type: QuranEditionType.tafsir),
            _edition('ar.muyassar', type: QuranEditionType.tafsir),
          ]);
      expect(arranged.map((e) => e.identifier), ['ar.muyassar', 'en.x']);
    });

    test('groups translations by language, in order of appearance', () {
      const t = QuranEditionType.translation;
      final arranged = GetQuranEditionsUseCase.arrange(t, [
        _edition('en.sahih', language: 'en', type: t),
        _edition('ur.jalandhry', language: 'ur', type: t),
        _edition('en.pickthall', language: 'en', type: t),
      ]);
      expect(arranged.map((e) => e.identifier), [
        'en.sahih',
        'en.pickthall',
        'ur.jalandhry',
      ]);
    });

    test('leaves out editions of another kind', () {
      final arranged = GetQuranEditionsUseCase.arrange(
        QuranEditionType.tafsir,
        [_edition('ar.alafasy')],
      );
      expect(arranged, isEmpty);
    });
  });

  group('FilterQuranEditionsUseCase', () {
    final filter = FilterQuranEditionsUseCase();
    final editions = [alafasy, husary, sahih];

    test('matches the Arabic name without its marks', () {
      expect(filter(editions, 'الحصرى'), [husary]);
    });

    test('matches the English name whatever the case', () {
      expect(filter(editions, 'ALAFASY'), [alafasy]);
    });

    test('matches a language code exactly', () {
      expect(filter(editions, 'en'), [sahih]);
    });

    test('keeps every edition for an empty query', () {
      expect(filter(editions, '  '), editions);
    });
  });

  group('LoadRecitationUseCase', () {
    late FakeQuranCloudRepo cloud;
    late LoadRecitationUseCase load;

    setUp(() {
      cloud = FakeQuranCloudRepo(
        recitations: {
          const RecitationScope.surah(1): audioFor([1, 2]),
          const RecitationScope.page(106): audioFor([669, 670]),
        },
      );
      load = LoadRecitationUseCase(cloud, FakeQuranRepo());
    });

    test('recites the surah an ayah is in, from that ayah', () async {
      final result = await load(
        const RecitationFromAyah(2),
        RecitationSettings.defaults,
      );

      final start = dataOf(result);
      expect(start.playlist.scope, const RecitationScope.surah(1));
      expect(start.startIndex, 1);
      expect(cloud.recitationRequests.single.reciter, 'ar.alafasy');
    });

    test('places each track on its page with its surah name', () async {
      final result = await load(
        const RecitationOfScope(RecitationScope.page(106)),
        RecitationSettings.defaults,
      );

      final tracks = dataOf(result).playlist.tracks;
      expect(tracks.map((t) => t.surahName), ['النساء', 'المائدة']);
      expect(tracks.map((t) => t.ayahNumber), [176, 1]);
      expect(tracks.every((t) => t.page == 106), isTrue);
    });

    test('starts a scope at the ayah asked for', () async {
      final result = await load(
        const RecitationOfScope(RecitationScope.page(106), startAyahId: 670),
        RecitationSettings.defaults,
      );
      expect(dataOf(result).startIndex, 1);
    });

    test('starts at the top when the start ayah is not in the scope', () async {
      final result = await load(
        const RecitationOfScope(RecitationScope.page(106), startAyahId: 2),
        RecitationSettings.defaults,
      );
      expect(dataOf(result).startIndex, 0);
    });

    test('plays the small files when saving data', () async {
      final result = await load(
        const RecitationFromAyah(1),
        const RecitationSettings(quality: RecitationQuality.dataSaver),
      );
      expect(dataOf(result).playlist.tracks.first.url, contains('/64/'));
    });

    test('drops audio for ayahs the mushaf cannot place', () async {
      cloud.recitations[const RecitationScope.surah(1)] = audioFor([1, 9999]);
      final result = await load(
        const RecitationFromAyah(1),
        RecitationSettings.defaults,
      );
      expect(dataOf(result).playlist.tracks.map((t) => t.ayahId), [1]);
    });

    test('fails as unavailable when nothing can be placed', () async {
      cloud.recitations[const RecitationScope.surah(1)] = audioFor([9999]);
      final result = await load(
        const RecitationFromAyah(1),
        RecitationSettings.defaults,
      );
      expect(
        (result as ApiFailure).failure.message,
        FailureMessages.audioUnavailable,
      );
    });

    test('refuses a reciter id that could reshape the request', () async {
      final result = await load(
        const RecitationFromAyah(1),
        const RecitationSettings(reciterId: 'ar/../x'),
      );
      expect(result, isA<ApiFailure<RecitationStart>>());
      expect(cloud.recitationRequests, isEmpty);
    });

    test('refuses a scope outside the mushaf', () async {
      final result = await load(
        const RecitationOfScope(RecitationScope.juz(31)),
        RecitationSettings.defaults,
      );
      expect(result, isA<ApiFailure<RecitationStart>>());
      expect(cloud.recitationRequests, isEmpty);
    });

    test('passes a network failure through', () async {
      cloud.failure = const NetworkFailure();
      final result = await load(
        const RecitationFromAyah(1),
        RecitationSettings.defaults,
      );
      expect((result as ApiFailure).failure, isA<NetworkFailure>());
    });
  });

  group('GetAyahCommentaryUseCase', () {
    test('sorts the passages into tafsir and translation', () async {
      final cloud = FakeQuranCloudRepo(
        ayahTexts: {
          2: [passage(muyassar, 'الثناء على الله'), passage(sahih, 'Praise')],
        },
      );
      final result = await GetAyahCommentaryUseCase(cloud)(
        2,
        const CommentarySettings(translationId: 'en.sahih'),
      );

      final commentary = dataOf(result);
      expect(commentary.tafsir?.text, 'الثناء على الله');
      expect(commentary.translation?.text, 'Praise');
      expect(cloud.ayahTextRequests.single.editions, [
        'ar.muyassar',
        'en.sahih',
      ]);
    });

    test('asks for the tafsir alone without a translation', () async {
      final cloud = FakeQuranCloudRepo();
      await GetAyahCommentaryUseCase(cloud)(2, CommentarySettings.defaults);
      expect(cloud.ayahTextRequests.single.editions, ['ar.muyassar']);
    });

    test('treats a blank passage as missing', () async {
      final cloud = FakeQuranCloudRepo(
        ayahTexts: {
          2: [passage(muyassar, '  ')],
        },
      );
      final result = await GetAyahCommentaryUseCase(cloud)(
        2,
        CommentarySettings.defaults,
      );
      expect(dataOf(result).isEmpty, isTrue);
    });

    test('refuses an ayah outside the mushaf', () async {
      final cloud = FakeQuranCloudRepo();
      final result = await GetAyahCommentaryUseCase(cloud)(
        0,
        CommentarySettings.defaults,
      );
      expect(result, isA<ApiFailure<AyahCommentary>>());
      expect(cloud.ayahTextRequests, isEmpty);
    });
  });

  group('GetSurahCommentaryUseCase', () {
    test('pairs each ayah of the page with its passages', () async {
      final cloud = FakeQuranCloudRepo(
        surahTexts: [
          AyahEditionText(ayahId: 2, text: passage(muyassar, 'ب')),
          AyahEditionText(ayahId: 1, text: passage(muyassar, 'أ')),
        ],
      );
      final result = await GetSurahCommentaryUseCase(cloud, FakeQuranRepo())(
        1,
        CommentarySettings.defaults,
      );

      final page = dataOf(result);
      expect(page.ayahs.map((a) => a.ayah.id), [1, 2]);
      expect(page.ayahs.map((a) => a.commentary.tafsir?.text), ['أ', 'ب']);
      expect(cloud.surahTextRequests.single.limit, 10);
    });

    test('moves on past every ayah it asked for, shown or not', () async {
      // Al-Baqarah: ten ayahs asked for, only one with a passage to show.
      final cloud = FakeQuranCloudRepo(
        surahTexts: [
          AyahEditionText(ayahId: 8, text: passage(muyassar, 'الم')),
        ],
      );
      final page = dataOf(
        await GetSurahCommentaryUseCase(cloud, FakeQuranRepo())(
          2,
          CommentarySettings.defaults,
        ),
      );

      expect(page.ayahs, hasLength(1));
      expect(page.nextOffset, 10);
      expect(page.hasMore, isTrue);
    });

    test('ends at the surah\'s last ayah', () async {
      final cloud = FakeQuranCloudRepo(
        surahTexts: [AyahEditionText(ayahId: 1, text: passage(muyassar, 'أ'))],
      );
      final page = dataOf(
        await GetSurahCommentaryUseCase(cloud, FakeQuranRepo())(
          1,
          CommentarySettings.defaults,
        ),
      );

      expect(page.nextOffset, 7);
      expect(page.hasMore, isFalse);
    });

    test('a page with nothing to show still moves on', () async {
      // The service answered, but only for an ayah the mushaf lacks.
      final cloud = FakeQuranCloudRepo(
        surahTexts: [
          AyahEditionText(ayahId: 9, text: passage(muyassar, 'ذلك')),
        ],
      );
      final page = dataOf(
        await GetSurahCommentaryUseCase(cloud, FakeQuranRepo())(
          2,
          CommentarySettings.defaults,
        ),
      );

      expect(page.ayahs, isEmpty);
      expect(page.hasMore, isTrue);
    });

    test('leaves out passages of another surah', () async {
      final cloud = FakeQuranCloudRepo(
        surahTexts: [
          AyahEditionText(ayahId: 1, text: passage(muyassar, 'أ')),
          AyahEditionText(ayahId: 8, text: passage(muyassar, 'الم')),
        ],
      );
      final result = await GetSurahCommentaryUseCase(cloud, FakeQuranRepo())(
        1,
        CommentarySettings.defaults,
      );
      expect(dataOf(result).ayahs.map((a) => a.ayah.id), [1]);
    });

    test('refuses an offset past the end of the surah', () async {
      final cloud = FakeQuranCloudRepo();
      final result = await GetSurahCommentaryUseCase(cloud, FakeQuranRepo())(
        1,
        CommentarySettings.defaults,
        offset: 7,
      );
      expect(result, isA<ApiFailure<SurahCommentaryPage>>());
      expect(cloud.surahTextRequests, isEmpty);
    });

    test('fails when the service sends nothing to show', () async {
      final result = await GetSurahCommentaryUseCase(
        FakeQuranCloudRepo(),
        FakeQuranRepo(),
      )(1, CommentarySettings.defaults);
      expect(result, isA<ApiFailure<SurahCommentaryPage>>());
    });
  });

  group('SearchQuranEditionUseCase', () {
    test('does not ask the service for one letter', () async {
      final cloud = FakeQuranCloudRepo();
      final result = await SearchQuranEditionUseCase(cloud, FakeQuranRepo())(
        'ر',
        'ar.muyassar',
      );
      expect(dataOf(result).hits, isEmpty);
      expect(cloud.searchRequests, isEmpty);
    });

    test('places each match in the mushaf with an excerpt', () async {
      final cloud = FakeQuranCloudRepo(
        searchMatches: const [
          AyahEditionMatch(ayahId: 2, text: 'الثناء على الله بصفاته'),
        ],
      );
      final result = await SearchQuranEditionUseCase(cloud, FakeQuranRepo())(
        'الله',
        'ar.muyassar',
      );

      final hit = dataOf(result).hits.single;
      expect(hit.ayah, hamd);
      expect(hit.surahName, 'الفاتحة');
      expect(hit.excerpt, 'الثناء على الله بصفاته');
      expect(hit.matches, isNotEmpty);
    });

    test('pages through the matches', () async {
      final cloud = FakeQuranCloudRepo(
        searchMatches: [
          for (var i = 0; i < 25; i++)
            const AyahEditionMatch(ayahId: 1, text: 'الرحمن الرحيم'),
        ],
      );
      final search = SearchQuranEditionUseCase(cloud, FakeQuranRepo());

      final first = dataOf(await search('الرحمن', 'ar.muyassar'));
      final second = dataOf(
        await search('الرحمن', 'ar.muyassar', offset: first.nextOffset),
      );

      expect(first.hasMore, isTrue);
      expect(cloud.searchRequests.last.offset, 20);
      expect(second.hits, hasLength(5));
      expect(second.hasMore, isFalse);
    });

    test('counts matches it cannot place toward the next page', () async {
      final cloud = FakeQuranCloudRepo(
        searchMatches: const [
          AyahEditionMatch(ayahId: 9999, text: 'الرحمن'),
          AyahEditionMatch(ayahId: 1, text: 'الرحمن'),
        ],
      );
      final page = dataOf(
        await SearchQuranEditionUseCase(cloud, FakeQuranRepo())(
          'الرحمن',
          'ar.muyassar',
        ),
      );
      expect(page.hits, hasLength(1));
      expect(page.nextOffset, 2);
    });

    test('refuses an edition id that could reshape the request', () async {
      final cloud = FakeQuranCloudRepo();
      final result = await SearchQuranEditionUseCase(cloud, FakeQuranRepo())(
        'الرحمن',
        'x/y',
      );
      expect(result, isA<ApiFailure<EditionSearchPage>>());
      expect(cloud.searchRequests, isEmpty);
    });
  });

  group('GetHizbIndexUseCase', () {
    test('refuses quarters that do not advance through the mushaf', () async {
      final cloud = FakeQuranCloudRepo(
        hizbStarts: [
          (surah: 1, ayah: 1),
          (surah: 2, ayah: 1),
          (surah: 2, ayah: 142),
          (surah: 4, ayah: 176),
          for (var i = 4; i < QuranMetrics.hizbQuarterCount; i++)
            (surah: 5, ayah: 1),
        ],
      );
      // The quarters after the fourth all start at the same ayah.
      final result = await GetHizbIndexUseCase(cloud, FakeQuranRepo())();
      expect(result, isA<ApiFailure<List<QuranHizbQuarter>>>());
    });

    test('builds the index from starts in mushaf order', () async {
      final quran = FakeQuranRepo(
        ayahs: [
          for (var i = 1; i <= QuranMetrics.hizbQuarterCount; i++)
            QuranAyah(
              id: i,
              surahNumber: 1,
              number: i,
              juz: 1,
              page: (i + 1) ~/ 2,
              text: 'آية',
            ),
        ],
        surahs: [fatihah],
      );
      final cloud = FakeQuranCloudRepo(
        hizbStarts: [
          for (var i = 1; i <= QuranMetrics.hizbQuarterCount; i++)
            (surah: 1, ayah: i),
        ],
      );

      final quarters = dataOf(await GetHizbIndexUseCase(cloud, quran)());

      expect(quarters, hasLength(240));
      expect(quarters[4].number, 5);
      expect(quarters[4].hizb, 2);
      expect(quarters[4].page, 3);
      expect(quarters[4].surahName, 'الفاتحة');
    });

    test('refuses an index without all 240 quarters', () async {
      final cloud = FakeQuranCloudRepo(hizbStarts: [(surah: 1, ayah: 1)]);
      final result = await GetHizbIndexUseCase(cloud, FakeQuranRepo())();
      expect(result, isA<ApiFailure<List<QuranHizbQuarter>>>());
    });

    test('refuses a start the mushaf has no ayah for', () async {
      final cloud = FakeQuranCloudRepo(
        hizbStarts: _starts([(surah: 3, ayah: 1)]),
      );
      final result = await GetHizbIndexUseCase(cloud, FakeQuranRepo())();
      expect(result, isA<ApiFailure<List<QuranHizbQuarter>>>());
    });
  });

  group('GetReflectionAyahUseCase', () {
    test('pairs the random passage with the bundled ayah', () async {
      final cloud = FakeQuranCloudRepo(
        random: AyahEditionText(ayahId: 670, text: passage(muyassar, 'أوفوا')),
      );
      final result = await GetReflectionAyahUseCase(cloud, FakeQuranRepo())(
        CommentarySettings.defaults,
      );

      final reflection = dataOf(result);
      expect(reflection.ayah, maidahFirst);
      expect(reflection.surah, maidah);
      expect(reflection.commentary.tafsir?.text, 'أوفوا');
    });

    test('fails when the ayah is not in the mushaf', () async {
      final cloud = FakeQuranCloudRepo(
        random: AyahEditionText(ayahId: 3, text: passage(muyassar, 'x')),
      );
      final result = await GetReflectionAyahUseCase(cloud, FakeQuranRepo())(
        CommentarySettings.defaults,
      );
      expect(result, isA<ApiFailure<CommentedAyah>>());
    });
  });

  group('study settings', () {
    test('a reciter id that could reshape a request is not saved', () async {
      final reading = FakeQuranReadingRepo();
      final result = await SaveRecitationSettingsUseCase(reading)(
        const RecitationSettings(reciterId: '../etc'),
      );
      expect(result, isA<ApiFailure<void>>());
      expect(reading.savedRecitationSettings, isEmpty);
    });

    test(
      'a translation id that could reshape a request is not saved',
      () async {
        final reading = FakeQuranReadingRepo();
        final result = await SaveCommentarySettingsUseCase(reading)(
          const CommentarySettings(translationId: 'en/../x'),
        );
        expect(result, isA<ApiFailure<void>>());
        expect(reading.savedCommentarySettings, isEmpty);
      },
    );

    test('lists the tafsir before the translation', () {
      expect(const CommentarySettings(translationId: 'en.sahih').editionIds, [
        'ar.muyassar',
        'en.sahih',
      ]);
    });
  });
}
