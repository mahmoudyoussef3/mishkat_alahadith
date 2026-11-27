import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_collection.dart';

/// The chapter ids in the bundled book.
List<int> _bundledIds() {
  final decoded = jsonDecode(File('assets/azkar/ar.json').readAsStringSync());
  return [for (final category in decoded as List) category['id'] as int];
}

void main() {
  test('every bundled chapter belongs to exactly one collection', () {
    for (final id in _bundledIds()) {
      final owners = [
        for (final collection in AzkarCollection.values)
          if (collection.contains(id)) collection,
      ];
      expect(owners, hasLength(1), reason: 'chapter $id');
    }
  });

  test('no collection names a chapter the book does not have', () {
    final ids = _bundledIds().toSet();

    for (final collection in AzkarCollection.values) {
      expect(ids.containsAll(collection.categoryIds), isTrue);
    }
  });

  test('every chapter the app names is in the book', () {
    const named = [
      AzkarCategoryIds.morningEvening,
      AzkarCategoryIds.sleep,
      AzkarCategoryIds.waking,
      AzkarCategoryIds.adhan,
      AzkarCategoryIds.afterPrayer,
      AzkarCategoryIds.worry,
      AzkarCategoryIds.istighfar,
      AzkarCategoryIds.tasbeeh,
    ];

    expect(_bundledIds().toSet().containsAll(named), isTrue);
  });
}
