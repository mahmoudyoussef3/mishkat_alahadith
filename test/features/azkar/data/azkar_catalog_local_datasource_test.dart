import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/azkar/data/datasources/azkar_catalog_local_datasource.dart';

/// Serves asset files straight from the project folder.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());
}

/// Serves the strings it is given, counting every read.
class _StringBundle extends AssetBundle {
  final Map<String, String> files;
  int reads = 0;

  _StringBundle(this.files);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    reads++;
    final file = files[key];
    if (file == null) throw StateError('No asset $key');
    return file;
  }

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) => throw UnimplementedError();
}

void main() {
  group('the bundled book', () {
    final source = AzkarCatalogLocalDataSource(bundle: _DiskBundle());

    for (final language in ['ar', 'en']) {
      test('has all 132 chapters in "$language"', () async {
        final categories = await source.getCategories(language);

        expect(categories, hasLength(132));
        expect(categories.expand((c) => c.azkar), hasLength(267));
      });
    }

    test('lines up chapter by chapter and zikr by zikr', () async {
      final arabic = await source.getCategories('ar');
      final english = await source.getCategories('en');

      for (var i = 0; i < arabic.length; i++) {
        expect(english[i].id, arabic[i].id);
        expect(
          english[i].azkar.map((z) => z.id),
          arabic[i].azkar.map((z) => z.id),
        );
      }
    });

    test('carries no translation-service errors in place of text', () async {
      // Upstream's tr.json is mostly such errors, which is why it is left out.
      final error = RegExp(
        r'MYMEMORY|QUERY LENGTH LIMIT',
        caseSensitive: false,
      );

      for (final category in await source.getCategories('en')) {
        expect(category.title, isNot(matches(error)));
        for (final zikr in category.azkar) {
          expect(zikr.text, isNot(matches(error)), reason: '${category.id}');
        }
      }
    });

    test('opens with the morning and evening remembrances', () async {
      final first = (await source.getCategories('ar')).first;

      expect(first.id, 27);
      expect(first.audioFile, 'ar_7esn_AlMoslem_by_Doors_028.mp3');
      expect(first.azkar.first.audioFile, '75.mp3');
    });
  });

  test('skips damaged chapters and azkar', () async {
    final source = AzkarCatalogLocalDataSource(
      bundle: _StringBundle({
        'assets/azkar/ar.json':
            '[{"id":1},'
            '{"id":2,"category":"باب","audio":"","array":['
            '{"id":1},{"id":2,"text":"ذكر","count":0}]}]',
      }),
    );

    final categories = await source.getCategories('ar');

    expect(categories.single.id, 2);
    expect(categories.single.audioFile, isNull);
    expect(categories.single.azkar.single.count, 1);
  });

  test('reads each language once', () async {
    final bundle = _StringBundle({'assets/azkar/ar.json': '[]'});
    final source = AzkarCatalogLocalDataSource(bundle: bundle);

    await source.getCategories('ar');
    await source.getCategories('ar');

    expect(bundle.reads, 1);
  });

  test('tries again after a failed read', () async {
    final bundle = _StringBundle({});
    final source = AzkarCatalogLocalDataSource(bundle: bundle);

    await expectLater(source.getCategories('ar'), throwsA(isA<StateError>()));
    bundle.files['assets/azkar/ar.json'] = '[]';

    expect(await source.getCategories('ar'), isEmpty);
  });

  test('rejects a file that is not a list', () async {
    final source = AzkarCatalogLocalDataSource(
      bundle: _StringBundle({'assets/azkar/ar.json': '{}'}),
    );

    expect(source.getCategories('ar'), throwsFormatException);
  });
}
