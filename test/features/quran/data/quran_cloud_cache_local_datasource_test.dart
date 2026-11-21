import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_cloud_cache_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late QuranCloudCacheLocalDataSource cache;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cache = QuranCloudCacheLocalDataSource();
  });

  Future<void> saveMany(int count, {int from = 0}) async {
    for (var i = from; i < from + count; i++) {
      await cache.saveResponse('k$i', {'n': i});
    }
  }

  group('responses', () {
    test('an answer saved reads back the same', () async {
      await cache.saveResponse('ayah|255|ar.muyassar', [
        {'number': 262, 'text': 'نص'},
      ]);

      expect(await cache.getResponse('ayah|255|ar.muyassar'), [
        {'number': 262, 'text': 'نص'},
      ]);
    });

    test('nothing saved reads as null', () async {
      expect(await cache.getResponse('ayah|1|ar.muyassar'), isNull);
    });

    test('a damaged answer reads as null', () async {
      SharedPreferences.setMockInitialValues({
        'quran_cloud_response_k0': 'not json',
      });

      expect(await QuranCloudCacheLocalDataSource().getResponse('k0'), isNull);
    });

    test('past the cap, the oldest answer is forgotten', () async {
      await saveMany(QuranCloudCacheLocalDataSource.maxResponses + 1);

      expect(await cache.getResponse('k0'), isNull);
      expect(await cache.getResponse('k1'), {'n': 1});
      expect(
        await cache.getResponse(
          'k${QuranCloudCacheLocalDataSource.maxResponses}',
        ),
        {'n': QuranCloudCacheLocalDataSource.maxResponses},
      );
    });

    test('past the size bound, the oldest answers are forgotten', () async {
      final long =
          'ن' * (QuranCloudCacheLocalDataSource.maxResponseChars ~/ 2);
      await cache.saveResponse('old', long);
      await cache.saveResponse('mid', long);
      await cache.saveResponse('new', long);

      expect(await cache.getResponse('old'), isNull);
      expect(await cache.getResponse('mid'), isNull);
      expect(await cache.getResponse('new'), long);
    });

    test('an answer saved again counts as the newest', () async {
      await saveMany(QuranCloudCacheLocalDataSource.maxResponses);
      await cache.saveResponse('k0', {'n': 0});

      await saveMany(1, from: QuranCloudCacheLocalDataSource.maxResponses);

      expect(await cache.getResponse('k0'), {'n': 0});
      expect(await cache.getResponse('k1'), isNull);
    });
  });
}
