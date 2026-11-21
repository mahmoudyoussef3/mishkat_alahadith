import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> save(GenericCacheService cache, String key, String value) =>
      cache.saveData<String>(
        key: key,
        data: value,
        toJson: (v) => {'v': v},
      );

  Future<String?> read(GenericCacheService cache, String key) =>
      cache.getData<String>(
        key: key,
        fromJson: (json) => json['v'] as String,
        allowStale: true,
      );

  test('past the entry bound, the oldest save is forgotten', () async {
    final cache = GenericCacheService.withLimits(maxEntries: 2, maxChars: 1000);

    await save(cache, 'a', '1');
    await save(cache, 'b', '2');
    await save(cache, 'c', '3');

    expect(await read(cache, 'a'), isNull);
    expect(await read(cache, 'b'), '2');
    expect(await read(cache, 'c'), '3');
  });

  test('saving a key again makes it the newest', () async {
    final cache = GenericCacheService.withLimits(maxEntries: 2, maxChars: 1000);

    await save(cache, 'a', '1');
    await save(cache, 'b', '2');
    await save(cache, 'a', '1 again');
    await save(cache, 'c', '3');

    expect(await read(cache, 'a'), '1 again');
    expect(await read(cache, 'b'), isNull);
  });

  test('past the size bound, the oldest saves are forgotten', () async {
    // Each entry stores as {"v":"<value>"}: 10 characters for a 2-char value.
    final cache = GenericCacheService.withLimits(maxEntries: 10, maxChars: 25);

    await save(cache, 'a', 'xx');
    await save(cache, 'b', 'xx');
    await save(cache, 'c', 'xx');

    expect(await read(cache, 'a'), isNull);
    expect(await read(cache, 'b'), 'xx');
    expect(await read(cache, 'c'), 'xx');
  });

  test('an entry larger than the size bound is still kept on its own', () async {
    final cache = GenericCacheService.withLimits(maxEntries: 10, maxChars: 5);

    await save(cache, 'a', 'x');
    await save(cache, 'big', 'much longer than the bound');

    expect(await read(cache, 'a'), isNull);
    expect(await read(cache, 'big'), 'much longer than the bound');
  });

  test('a cleared key no longer counts toward the bound', () async {
    final cache = GenericCacheService.withLimits(maxEntries: 2, maxChars: 1000);

    await save(cache, 'a', '1');
    await save(cache, 'b', '2');
    await cache.clearCache('b');
    await save(cache, 'c', '3');

    expect(await read(cache, 'a'), '1');
    expect(await read(cache, 'c'), '3');
  });

  test('saves running together all stay within the bound', () async {
    final cache = GenericCacheService.withLimits(maxEntries: 3, maxChars: 1000);

    await Future.wait([for (var i = 0; i < 8; i++) save(cache, 'k$i', '$i')]);

    final prefs = await SharedPreferences.getInstance();
    final kept = prefs.getKeys().where((k) => k.endsWith('_data'));
    expect(kept, hasLength(3));
  });
}
