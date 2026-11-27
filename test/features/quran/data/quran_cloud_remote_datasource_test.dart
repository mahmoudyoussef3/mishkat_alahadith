import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_cloud_remote_datasource.dart';
import 'package:mishkat_almasabih/features/quran/data/models/quran_cloud_models.dart';

import 'quran_cloud_http_fakes.dart';

void main() {
  late FakeQuranCloudAdapter adapter;
  late QuranCloudRemoteDataSource remote;

  void answer(FakeReply reply) => adapter.reply = (_) => reply;

  Uri lastUri() => adapter.requests.last.uri;

  setUp(() {
    adapter = FakeQuranCloudAdapter((_) => ok(null));
    remote = QuranCloudRemoteDataSource(dioOver(adapter));
  });

  group('getEditions', () {
    test('asks for the format and type', () async {
      answer(ok([edition('ar.muyassar')]));

      await remote.getEditions(format: 'text', type: 'tafsir');

      expect(lastUri().path, '/v1/edition');
      expect(lastUri().host, 'api.alquran.cloud');
      expect(lastUri().queryParameters, {'format': 'text', 'type': 'tafsir'});
    });

    test('reads every edition, skipping any that cannot be read', () async {
      answer(
        ok([
          edition('ar.muyassar'),
          {'name': 'no identifier'},
          edition('ar.jalalayn'),
        ]),
      );

      final editions = await remote.getEditions(format: 'text', type: 'tafsir');

      expect(editions.map((e) => e.identifier), ['ar.muyassar', 'ar.jalalayn']);
    });

    test('throws for data that is not a list', () async {
      answer(ok({'identifier': 'ar.muyassar'}));

      await expectLater(
        remote.getEditions(format: 'text', type: 'tafsir'),
        throwsA(isA<QuranCloudFormatException>()),
      );
    });
  });

  group('getDivision', () {
    test('asks for the division, its number and the edition', () async {
      answer(
        ok({
          'number': 3,
          'ayahs': [audioAyah(20)],
          'edition': edition('ar.alafasy', format: 'audio'),
        }),
      );

      final group = await remote.getDivision('hizbQuarter', 3, 'ar.alafasy');

      expect(lastUri().path, '/v1/hizbQuarter/3/ar.alafasy');
      expect(group.ayahs.single.audio, isNotNull);
      expect(group.edition?.identifier, 'ar.alafasy');
    });

    test('throws for data without ayahs', () async {
      answer(ok({'number': 3}));

      await expectLater(
        remote.getDivision('surah', 3, 'ar.alafasy'),
        throwsA(isA<QuranCloudFormatException>()),
      );
    });

    test('throws the network error for a division that is not found', () async {
      answer(notFound('Surat number should be between 1 and 114.'));

      await expectLater(
        remote.getDivision('surah', 115, 'ar.alafasy'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            404,
          ),
        ),
      );
    });

    test('refuses an edition that could reshape the request', () async {
      await expectLater(
        remote.getDivision('surah', 1, 'ar/../x'),
        throwsArgumentError,
      );

      expect(adapter.requests, isEmpty);
    });
  });

  group('getAyahEditions', () {
    test('joins the editions with commas', () async {
      answer(ok([]));

      await remote.getAyahEditions(255, ['ar.muyassar', 'en.sahih']);

      expect(lastUri().path, '/v1/ayah/255/editions/ar.muyassar,en.sahih');
    });

    test('reads one ayah per edition', () async {
      answer(
        ok([
          {'number': 255, 'text': 'تفسير', 'edition': edition('ar.muyassar')},
          {
            'number': 255,
            'text': 'translation',
            'edition': edition('en.sahih', type: 'translation'),
          },
        ]),
      );

      final ayahs = await remote.getAyahEditions(255, [
        'ar.muyassar',
        'en.sahih',
      ]);

      expect(ayahs.map((a) => a.edition?.identifier), [
        'ar.muyassar',
        'en.sahih',
      ]);
    });

    test('reads a single ayah sent without a list', () async {
      answer(
        ok({'number': 255, 'text': 'تفسير', 'edition': edition('ar.muyassar')}),
      );

      final ayahs = await remote.getAyahEditions(255, ['ar.muyassar']);

      expect(ayahs, hasLength(1));
    });

    test('refuses any edition that could reshape the request', () async {
      await expectLater(
        remote.getAyahEditions(255, ['ar.muyassar', 'x?y=1']),
        throwsArgumentError,
      );

      expect(adapter.requests, isEmpty);
    });
  });

  group('getSurahEditions', () {
    test('asks for a page of the surah from the offset', () async {
      answer(ok([]));

      await remote.getSurahEditions(
        2,
        ['ar.muyassar', 'en.sahih'],
        offset: 20,
        limit: 10,
      );

      expect(lastUri().path, '/v1/surah/2/editions/ar.muyassar,en.sahih');
      expect(lastUri().queryParameters, {'offset': '20', 'limit': '10'});
    });

    test('reads one group per edition', () async {
      answer(
        ok([
          {
            'number': 2,
            'ayahs': [
              {'number': 8, 'text': 'تفسير'},
            ],
            'edition': edition('ar.muyassar'),
          },
          'not a group',
        ]),
      );

      final groups = await remote.getSurahEditions(
        2,
        ['ar.muyassar'],
        offset: 0,
        limit: 10,
      );

      expect(groups.single.edition?.identifier, 'ar.muyassar');
      expect(groups.single.ayahs.single.number, 8);
    });

    test('reads a single group sent without a list', () async {
      answer(
        ok({
          'number': 2,
          'ayahs': <Object>[],
          'edition': edition('ar.muyassar'),
        }),
      );

      final groups = await remote.getSurahEditions(
        2,
        ['ar.muyassar'],
        offset: 0,
        limit: 10,
      );

      expect(groups, hasLength(1));
    });
  });

  group('search', () {
    test('sends the words percent-encoded, with the page', () async {
      answer(ok({'count': 0, 'total': 0, 'matches': <Object>[]}));

      await remote.search('الصلاة', 'ar.muyassar', offset: 20, limit: 20);

      expect(lastUri().path, startsWith('/v1/search/%D8%A7%D9%84'));
      expect(lastUri().pathSegments, [
        'v1',
        'search',
        'الصلاة',
        'all',
        'ar.muyassar',
      ]);
      expect(lastUri().queryParameters, {'offset': '20', 'limit': '20'});
    });

    test('keeps a slash in the words inside one path segment', () async {
      answer(ok({'count': 0, 'total': 0, 'matches': <Object>[]}));

      await remote.search('a/../b', 'en.sahih', offset: 0, limit: 20);

      expect(lastUri().pathSegments, [
        'v1',
        'search',
        'a/../b',
        'all',
        'en.sahih',
      ]);
    });

    test('reads the matches and the total', () async {
      answer(
        ok({
          'count': 1,
          'total': 144,
          'offset': 0,
          'limit': 1,
          'matches': [
            {'number': 7, 'text': 'تفسير', 'edition': edition('ar.muyassar')},
          ],
        }),
      );

      final result = await remote.search(
        'الصلاة',
        'ar.muyassar',
        offset: 0,
        limit: 1,
      );

      expect(result.total, 144);
      expect(result.matches.single.number, 7);
    });

    test(
      'reads nothing found, which the service answers 404, as empty',
      () async {
        answer(notFound('Nothing matching your search was found..'));

        final result = await remote.search(
          'zzzzqqq',
          'en.sahih',
          offset: 0,
          limit: 20,
        );

        expect(result, same(CloudSearchModel.empty));
      },
    );

    test('throws a server error that is not 404', () async {
      answer((status: 500, body: {'code': 500}));

      await expectLater(
        remote.search('الصلاة', 'ar.muyassar', offset: 0, limit: 20),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('getRandomAyah', () {
    test('asks for a random ayah of the edition', () async {
      answer(
        ok({'number': 936, 'text': 'تفسير', 'edition': edition('ar.muyassar')}),
      );

      final ayah = await remote.getRandomAyah('ar.muyassar');

      expect(lastUri().path, '/v1/ayah/random/ar.muyassar');
      expect(ayah.number, 936);
    });

    test('throws for data that is not an ayah', () async {
      answer(ok({'text': 'no number'}));

      await expectLater(
        remote.getRandomAyah('ar.muyassar'),
        throwsA(isA<QuranCloudFormatException>()),
      );
    });
  });

  group('getHizbQuarterStarts', () {
    test('reads where each quarter begins from the metadata', () async {
      answer(
        ok({
          'ayahs': {'count': 6236},
          'hizbQuarters': {
            'count': 2,
            'references': [
              {'surah': 1, 'ayah': 1},
              {'surah': 2, 'ayah': 26},
            ],
          },
        }),
      );

      final starts = await remote.getHizbQuarterStarts();

      expect(lastUri().path, '/v1/meta');
      expect(starts, [(surah: 1, ayah: 1), (surah: 2, ayah: 26)]);
    });

    test('throws for metadata without hizb quarters', () async {
      answer(
        ok({
          'ayahs': {'count': 6236},
        }),
      );

      await expectLater(
        remote.getHizbQuarterStarts(),
        throwsA(isA<QuranCloudFormatException>()),
      );
    });

    test('throws for a reference that cannot be read', () async {
      answer(
        ok({
          'hizbQuarters': {
            'references': [
              {'surah': 1, 'ayah': '1'},
            ],
          },
        }),
      );

      await expectLater(
        remote.getHizbQuarterStarts(),
        throwsA(isA<QuranCloudFormatException>()),
      );
    });
  });

  test('throws for an answer whose code is not 200', () async {
    answer((status: 200, body: {'code': 500, 'status': 'ERROR', 'data': null}));

    await expectLater(
      remote.getRandomAyah('ar.muyassar'),
      throwsA(isA<QuranCloudFormatException>()),
    );
  });

  test('throws for an answer that is not an envelope', () async {
    answer((status: 200, body: [1, 2, 3]));

    await expectLater(
      remote.getEditions(format: 'audio', type: 'versebyverse'),
      throwsA(isA<QuranCloudFormatException>()),
    );
  });
}
