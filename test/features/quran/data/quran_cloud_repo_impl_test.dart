import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_cloud_cache_local_datasource.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_cloud_remote_datasource.dart';
import 'package:mishkat_almasabih/features/quran/data/repos/quran_cloud_repo_impl.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../quran_fakes.dart';
import 'quran_cloud_http_fakes.dart';

final DateTime _start = DateTime(2026, 11, 1, 9);

Failure _failureOf<T>(ApiResult<T> result) => (result as ApiFailure<T>).failure;

void main() {
  late FakeQuranCloudAdapter adapter;
  late DateTime now;

  QuranCloudRepoImpl newRepo() => QuranCloudRepoImpl(
    QuranCloudRemoteDataSource(dioOver(adapter)),
    QuranCloudCacheLocalDataSource(),
    now: () => now,
  );

  void answer(FakeReply reply) => adapter.reply = (_) => reply;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    adapter = FakeQuranCloudAdapter((_) => ok(null));
    now = _start;
  });

  // Every test here once hung: whenComplete was handed an arrow returning
  // the very future it returns, so each load waited on itself.
  group('getEditions', () {
    final tafsirList = ok([
      edition('ar.muyassar', name: 'تفسير المیسر'),
      edition('ar.jalalayn'),
      // The service mixes in kinds the app has no use for.
      edition('quran-simple', type: 'quran'),
    ]);

    test('asks for the format and type of the kind', () async {
      answer(tafsirList);

      await newRepo().getEditions(QuranEditionType.tafsir);

      expect(adapter.requests.single.uri.queryParameters, {
        'format': 'text',
        'type': 'tafsir',
      });
    });

    test('asks for verse-by-verse audio for the reciters', () async {
      answer(
        ok([edition('ar.alafasy', format: 'audio', type: 'versebyverse')]),
      );

      final reciters = dataOf(
        await newRepo().getEditions(QuranEditionType.recitation),
      );

      expect(adapter.requests.single.uri.queryParameters, {
        'format': 'audio',
        'type': 'versebyverse',
      });
      expect(reciters.single.type, QuranEditionType.recitation);
    });

    test('keeps only editions of the kind asked for', () async {
      answer(tafsirList);

      final editions = dataOf(
        await newRepo().getEditions(QuranEditionType.tafsir),
      );

      expect(editions.map((e) => e.identifier), ['ar.muyassar', 'ar.jalalayn']);
    });

    test('a second call is answered from memory', () async {
      answer(tafsirList);
      final repo = newRepo();

      await repo.getEditions(QuranEditionType.tafsir);
      await repo.getEditions(QuranEditionType.tafsir);

      expect(adapter.requests, hasLength(1));
    });

    test('calls made while loading share one request', () async {
      answer(tafsirList);
      adapter.gate = Completer<void>();
      final repo = newRepo();

      final first = repo.getEditions(QuranEditionType.tafsir);
      final second = repo.getEditions(QuranEditionType.tafsir);
      adapter.gate!.complete();
      final results = await Future.wait([first, second]);

      expect(adapter.requests, hasLength(1));
      expect(results.every((r) => r is ApiSuccess), isTrue);
    });

    test('a copy kept on the device opens without a request', () async {
      answer(tafsirList);
      await newRepo().getEditions(QuranEditionType.tafsir);
      now = _start.add(const Duration(days: 6));

      final editions = dataOf(
        await newRepo().getEditions(QuranEditionType.tafsir),
      );

      expect(adapter.requests, hasLength(1));
      expect(editions.map((e) => e.name), ['تفسير الميسر', 'ar.jalalayn']);
    });

    test('a copy older than a week is fetched again', () async {
      answer(tafsirList);
      await newRepo().getEditions(QuranEditionType.tafsir);
      now = _start.add(QuranCloudRepoImpl.editionsMaxAge);

      await newRepo().getEditions(QuranEditionType.tafsir);

      expect(adapter.requests, hasLength(2));
    });

    test(
      'an old copy still opens when the service cannot be reached',
      () async {
        answer(tafsirList);
        await newRepo().getEditions(QuranEditionType.tafsir);
        now = _start.add(const Duration(days: 30));
        adapter.reply =
            (options) =>
                throw DioException.connectionError(
                  requestOptions: options,
                  reason: 'offline',
                );

        final editions = dataOf(
          await newRepo().getEditions(QuranEditionType.tafsir),
        );

        expect(editions.map((e) => e.identifier), [
          'ar.muyassar',
          'ar.jalalayn',
        ]);
      },
    );

    test('fails offline with nothing kept on the device', () async {
      adapter.reply =
          (options) =>
              throw DioException.connectionError(
                requestOptions: options,
                reason: 'offline',
              );

      final result = await newRepo().getEditions(QuranEditionType.tafsir);

      expect(_failureOf(result), isA<NetworkFailure>());
    });

    test('a failed load is forgotten, so the next call tries again', () async {
      answer((status: 500, body: {'code': 500}));
      final repo = newRepo();
      await repo.getEditions(QuranEditionType.tafsir);
      answer(tafsirList);

      final result = await repo.getEditions(QuranEditionType.tafsir);

      expect(result, isA<ApiSuccess<List<QuranEdition>>>());
      expect(adapter.requests, hasLength(2));
    });

    test('fails for a list with no usable edition', () async {
      answer(ok([edition('quran-simple', type: 'quran')]));

      final result = await newRepo().getEditions(QuranEditionType.tafsir);

      expect(_failureOf(result), isA<ServerFailure>());
    });

    test('a damaged copy on the device is passed over', () async {
      SharedPreferences.setMockInitialValues({
        'quran_cloud_editions_tafsir': 'not json',
        'quran_cloud_editions_tafsir_saved_at': _start.millisecondsSinceEpoch,
      });
      answer(tafsirList);

      final result = await newRepo().getEditions(QuranEditionType.tafsir);

      expect(dataOf(result), hasLength(2));
      expect(adapter.requests, hasLength(1));
    });
  });

  group('getRecitation', () {
    const scope = RecitationScope.surah(112);

    Map<String, dynamic> surahOf(
      List<Map<String, dynamic>> ayahs, {
      Map<String, dynamic>? withEdition,
    }) => {
      'number': 112,
      'ayahs': ayahs,
      'edition':
          withEdition ??
          edition('ar.alafasy', format: 'audio', type: 'versebyverse'),
    };

    test('asks for the division by its name in the service', () async {
      answer(ok(surahOf([audioAyah(6222)])));

      await newRepo().getRecitation(
        'ar.alafasy',
        const RecitationScope.hizbQuarter(240),
      );

      expect(
        adapter.requests.single.uri.path,
        '/v1/hizbQuarter/240/ar.alafasy',
      );
    });

    test('reads the audio of every ayah', () async {
      answer(ok(surahOf([for (var n = 6222; n <= 6225; n++) audioAyah(n)])));

      final audio = dataOf(await newRepo().getRecitation('ar.alafasy', scope));

      expect(audio.map((a) => a.ayahId), [6222, 6223, 6224, 6225]);
      expect(audio.first.lowBitrateUrls, hasLength(1));
    });

    test(
      'an unknown reciter, swapped for the default text, is unavailable',
      () async {
        answer(
          ok(
            surahOf([
              {'number': 6222, 'text': 'قُلْ هُوَ ٱللَّهُ أَحَدٌ'},
            ], withEdition: defaultTextEdition),
          ),
        );

        final result = await newRepo().getRecitation('ar.nobody', scope);

        expect(
          _failureOf(result),
          isA<ServerFailure>().having(
            (f) => f.message,
            'message',
            FailureMessages.audioUnavailable,
          ),
        );
      },
    );

    test('a reciter with no audio for the part is unavailable', () async {
      answer(
        ok(
          surahOf([
            {'number': 6222, 'text': 'قُلْ هُوَ ٱللَّهُ أَحَدٌ'},
          ]),
        ),
      );

      final result = await newRepo().getRecitation('ar.alafasy', scope);

      expect(
        _failureOf(result),
        isA<ServerFailure>().having(
          (f) => f.message,
          'message',
          FailureMessages.audioUnavailable,
        ),
      );
    });

    test('a part played again is answered from memory', () async {
      answer(ok(surahOf([audioAyah(6222)])));
      final repo = newRepo();

      await repo.getRecitation('ar.alafasy', scope);
      await repo.getRecitation('ar.alafasy', scope);

      expect(adapter.requests, hasLength(1));
    });

    test('another reciter of the same part is fetched', () async {
      answer(ok(surahOf([audioAyah(6222)])));
      final repo = newRepo();
      await repo.getRecitation('ar.alafasy', scope);
      answer(
        ok(
          surahOf(
            [audioAyah(6222, reciter: 'ar.husary')],
            withEdition: edition(
              'ar.husary',
              format: 'audio',
              type: 'versebyverse',
            ),
          ),
        ),
      );

      final audio = dataOf(await repo.getRecitation('ar.husary', scope));

      expect(adapter.requests, hasLength(2));
      expect(audio.single.url, contains('ar.husary'));
    });

    test('a part outside the mushaf fails without a request', () async {
      final result = await newRepo().getRecitation(
        'ar.alafasy',
        const RecitationScope.surah(115),
      );

      expect(_failureOf(result), isA<UnexpectedFailure>());
      expect(adapter.requests, isEmpty);
    });

    test('a failed request reports the recitation unavailable', () async {
      answer(notFound('Surat number should be between 1 and 114.'));

      final result = await newRepo().getRecitation('ar.alafasy', scope);

      expect(
        _failureOf(result),
        isA<ServerFailure>()
            .having((f) => f.statusCode, 'status', 404)
            .having(
              (f) => f.message,
              'message',
              FailureMessages.audioUnavailable,
            ),
      );
    });
  });

  group('getAyahTexts', () {
    Map<String, dynamic> passageOf(String id, {String type = 'tafsir'}) => {
      'number': 255,
      'text': 'نص $id',
      'edition': edition(id, type: type),
    };

    test('drops the default text swapped in for an unknown edition', () async {
      answer(
        ok([
          passageOf('ar.muyassar'),
          {
            'number': 255,
            'text': 'ٱللَّهُ لَآ إِلَٰهَ',
            'edition': defaultTextEdition,
          },
        ]),
      );

      final texts = dataOf(
        await newRepo().getAyahTexts(255, ['ar.muyassar', 'xx.nope']),
      );

      expect(texts.map((t) => t.edition.identifier), ['ar.muyassar']);
    });

    test('keeps the order the editions were asked in', () async {
      answer(
        ok([
          passageOf('ar.muyassar'),
          passageOf('en.sahih', type: 'translation'),
        ]),
      );

      final texts = dataOf(
        await newRepo().getAyahTexts(255, ['en.sahih', 'ar.muyassar']),
      );

      expect(texts.map((t) => t.edition.identifier), [
        'en.sahih',
        'ar.muyassar',
      ]);
    });

    test('drops a passage of another ayah', () async {
      answer(
        ok([
          {...passageOf('ar.muyassar'), 'number': 256},
        ]),
      );

      final texts = dataOf(await newRepo().getAyahTexts(255, ['ar.muyassar']));

      expect(texts, isEmpty);
    });

    test('an ayah opened again is answered from memory', () async {
      answer(ok([passageOf('ar.muyassar')]));
      final repo = newRepo();

      await repo.getAyahTexts(255, ['ar.muyassar']);
      await repo.getAyahTexts(255, ['ar.muyassar']);

      expect(adapter.requests, hasLength(1));
    });

    test('fails without a request for an ayah outside the mushaf', () async {
      final result = await newRepo().getAyahTexts(0, ['ar.muyassar']);

      expect(_failureOf(result), isA<UnexpectedFailure>());
      expect(adapter.requests, isEmpty);
    });

    test('a server error carries its status', () async {
      answer((status: 503, body: {'code': 503}));

      final result = await newRepo().getAyahTexts(255, ['ar.muyassar']);

      expect(
        _failureOf(result),
        isA<ServerFailure>().having((f) => f.statusCode, 'status', 503),
      );
    });

    test('no answer at all is the connection', () async {
      adapter.reply =
          (options) =>
              throw DioException.connectionTimeout(
                requestOptions: options,
                timeout: const Duration(seconds: 20),
              );

      final result = await newRepo().getAyahTexts(255, ['ar.muyassar']);

      expect(_failureOf(result), isA<NetworkFailure>());
    });
  });

  group('getSurahTexts', () {
    test('keeps only the editions asked for, from the surah', () async {
      answer(
        ok([
          {
            'number': 2,
            'ayahs': [
              {'number': 8, 'text': 'تفسير الآية الأولى'},
              {'number': 9, 'text': 'تفسير الآية الثانية'},
            ],
            'edition': edition('ar.muyassar'),
          },
          {
            'number': 2,
            'ayahs': [
              {'number': 8, 'text': 'الٓمٓ'},
            ],
            'edition': defaultTextEdition,
          },
        ]),
      );

      final texts = dataOf(
        await newRepo().getSurahTexts(
          2,
          ['ar.muyassar', 'xx.nope'],
          offset: 0,
          limit: 10,
        ),
      );

      expect(texts.map((t) => t.ayahId), [8, 9]);
      expect(texts.map((t) => t.text.edition.identifier).toSet(), {
        'ar.muyassar',
      });
    });

    test('fails without a request for a surah outside the mushaf', () async {
      final result = await newRepo().getSurahTexts(
        115,
        ['ar.muyassar'],
        offset: 0,
        limit: 10,
      );

      expect(_failureOf(result), isA<UnexpectedFailure>());
      expect(adapter.requests, isEmpty);
    });
  });

  group('searchEdition', () {
    test('drops matches from another edition', () async {
      answer(
        ok({
          'count': 2,
          'total': 2,
          'matches': [
            {'number': 7, 'text': 'الصلاة', 'edition': edition('ar.muyassar')},
            {'number': 10, 'text': 'الصلاة', 'edition': edition('ar.jalalayn')},
          ],
        }),
      );

      final found = dataOf(
        await newRepo().searchEdition(
          'الصلاة',
          'ar.muyassar',
          offset: 0,
          limit: 20,
        ),
      );

      expect(found.matches.map((m) => m.ayahId), [7]);
    });

    test('never reports fewer matches than it has shown', () async {
      answer(
        ok({
          'count': 2,
          'total': 1,
          'matches': [
            {'number': 7, 'text': 'الصلاة', 'edition': edition('ar.muyassar')},
            {'number': 8, 'text': 'الصلاة', 'edition': edition('ar.muyassar')},
          ],
        }),
      );

      final found = dataOf(
        await newRepo().searchEdition(
          'الصلاة',
          'ar.muyassar',
          offset: 20,
          limit: 20,
        ),
      );

      expect(found.total, 22);
    });

    test('finding nothing is no matches, not a failure', () async {
      answer(notFound('Nothing matching your search was found..'));

      final found = dataOf(
        await newRepo().searchEdition(
          'zzzz',
          'ar.muyassar',
          offset: 0,
          limit: 20,
        ),
      );

      expect(found.matches, isEmpty);
      expect(found.total, 0);
    });

    test('blank words fail without a request', () async {
      final result = await newRepo().searchEdition(
        '   ',
        'ar.muyassar',
        offset: 0,
        limit: 20,
      );

      expect(_failureOf(result), isA<UnexpectedFailure>());
      expect(adapter.requests, isEmpty);
    });

    test('an unusable edition id is a server failure, not a crash', () async {
      final result = await newRepo().searchEdition(
        'الصلاة',
        'ar/../x',
        offset: 0,
        limit: 20,
      );

      expect(_failureOf(result), isA<ServerFailure>());
      expect(adapter.requests, isEmpty);
    });
  });

  group('getRandomAyahText', () {
    test('reads the ayah and its passage', () async {
      answer(
        ok({'number': 936, 'text': 'تفسير', 'edition': edition('ar.muyassar')}),
      );

      final entry = dataOf(await newRepo().getRandomAyahText('ar.muyassar'));

      expect(entry.ayahId, 936);
      expect(entry.text.text, 'تفسير');
    });

    test('rejects a passage of another edition', () async {
      answer(
        ok({'number': 936, 'text': 'تفسير', 'edition': edition('ar.jalalayn')}),
      );

      final result = await newRepo().getRandomAyahText('ar.muyassar');

      expect(_failureOf(result), isA<ServerFailure>());
    });
  });

  group('getHizbQuarterStarts', () {
    test('reads the 240 quarters and keeps them on the device', () async {
      answer(
        ok({
          'hizbQuarters': {'references': hizbReferences()},
        }),
      );

      final starts = dataOf(await newRepo().getHizbQuarterStarts());

      expect(starts, hasLength(240));
      expect(starts.first, (surah: 2, ayah: 1));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('quran_cloud_hizb_quarter_starts'), isNotNull);
    });

    test('rejects an index that does not have 240 quarters', () async {
      answer(
        ok({
          'hizbQuarters': {'references': hizbReferences(3)},
        }),
      );

      final result = await newRepo().getHizbQuarterStarts();

      expect(_failureOf(result), isA<ServerFailure>());
    });

    test('reads a copy kept on the device without a request', () async {
      SharedPreferences.setMockInitialValues({
        'quran_cloud_hizb_quarter_starts': jsonEncode([
          for (final ref in hizbReferences()) [ref['surah'], ref['ayah']],
        ]),
      });

      final starts = dataOf(await newRepo().getHizbQuarterStarts());

      expect(starts, hasLength(240));
      expect(adapter.requests, isEmpty);
    });

    test('a second call is answered from memory', () async {
      answer(
        ok({
          'hizbQuarters': {'references': hizbReferences()},
        }),
      );
      final repo = newRepo();

      await repo.getHizbQuarterStarts();
      await repo.getHizbQuarterStarts();

      expect(adapter.requests, hasLength(1));
    });

    test('an incomplete copy on the device is fetched again', () async {
      SharedPreferences.setMockInitialValues({
        'quran_cloud_hizb_quarter_starts': jsonEncode([
          [2, 1],
        ]),
      });
      answer(
        ok({
          'hizbQuarters': {'references': hizbReferences()},
        }),
      );

      final starts = dataOf(await newRepo().getHizbQuarterStarts());

      expect(starts, hasLength(240));
      expect(adapter.requests, hasLength(1));
    });
  });
}
