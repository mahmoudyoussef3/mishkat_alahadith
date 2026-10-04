import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/deep_links/deep_link_router.dart';

void main() {
  group('DeepLinkRouter.extractHadithId', () {
    test('extracts from https /api/hadith/<id>', () {
      final uri = Uri.parse('https://api.hadith-shareef.com/api/hadith/123');
      expect(DeepLinkRouter.extractHadithId(uri), '123');
    });

    test('extracts from https /hadith/<id>', () {
      final uri = Uri.parse('https://api.hadith-shareef.com/hadith/ABC');
      expect(DeepLinkRouter.extractHadithId(uri), 'ABC');
    });

    test('extracts from query parameter id', () {
      final uri = Uri.parse('https://api.hadith-shareef.com/api/hadith?id=999');
      expect(DeepLinkRouter.extractHadithId(uri), '999');
    });

    test('extracts from custom scheme mishkat://hadith/<id>', () {
      final uri = Uri.parse('mishkat://hadith/777');
      expect(DeepLinkRouter.extractHadithId(uri), '777');
    });

    test('extracts from custom scheme mishkat://hadith/api/hadith/<id>', () {
      final uri = Uri.parse('mishkat://hadith/api/hadith/555');
      expect(DeepLinkRouter.extractHadithId(uri), '555');
    });

    test('returns null when no id exists', () {
      final uri = Uri.parse('mishkat://hadith');
      expect(DeepLinkRouter.extractHadithId(uri), isNull);
    });
  });
}

