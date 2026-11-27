import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/deep_links/hadith_link.dart';

void main() {
  group('HadithLink.parseId', () {
    test('extracts from https /api/hadith/<id>', () {
      final uri = Uri.parse('https://api.hadith-shareef.com/api/hadith/123');
      expect(HadithLink.parseId(uri), '123');
    });

    test('extracts from https /hadith/<id>', () {
      final uri = Uri.parse('https://api.hadith-shareef.com/hadith/ABC');
      expect(HadithLink.parseId(uri), 'ABC');
    });

    test('extracts from query parameter id', () {
      final uri = Uri.parse('https://api.hadith-shareef.com/api/hadith?id=999');
      expect(HadithLink.parseId(uri), '999');
    });

    test('extracts from custom scheme mishkat://hadith/<id>', () {
      final uri = Uri.parse('mishkat://hadith/777');
      expect(HadithLink.parseId(uri), '777');
    });

    test('extracts from custom scheme mishkat://hadith/api/hadith/<id>', () {
      final uri = Uri.parse('mishkat://hadith/api/hadith/555');
      expect(HadithLink.parseId(uri), '555');
    });

    test('skips reserved segments in mishkat://hadith/api/<id>', () {
      final uri = Uri.parse('mishkat://hadith/api/123');
      expect(HadithLink.parseId(uri), '123');
    });

    test('returns null when no id exists', () {
      final uri = Uri.parse('mishkat://hadith');
      expect(HadithLink.parseId(uri), isNull);
    });

    test('returns null when the only segment is reserved', () {
      final uri = Uri.parse('mishkat://hadith/hadith');
      expect(HadithLink.parseId(uri), isNull);
    });

    test('strips a trailing non-breaking space copied with the link', () {
      final uri = Uri.parse(
        'https://api.hadith-shareef.com/api/hadith/123%C2%A0',
      );
      expect(HadithLink.parseId(uri), '123');
    });

    test('ignores links on other hosts', () {
      final uri = Uri.parse('https://evil.example.com/api/hadith/123');
      expect(HadithLink.parseId(uri), isNull);
    });

    test('ignores plain http links', () {
      final uri = Uri.parse('http://api.hadith-shareef.com/api/hadith/123');
      expect(HadithLink.parseId(uri), isNull);
    });

    test('ignores api paths that are not a hadith', () {
      final uri = Uri.parse(
        'https://api.hadith-shareef.com/api/uploads/avatars/default.jpg',
      );
      expect(HadithLink.parseId(uri), isNull);
    });

    test('rejects ids with characters outside the allowed set', () {
      final uri = Uri.parse(
        'https://api.hadith-shareef.com/api/hadith/1%3Cscript%3E',
      );
      expect(HadithLink.parseId(uri), isNull);
    });

    test('rejects ids longer than 64 characters', () {
      final uri = Uri.parse(
        'https://api.hadith-shareef.com/api/hadith/${'1' * 65}',
      );
      expect(HadithLink.parseId(uri), isNull);
    });

    test('returns null for path encoding that is not valid UTF-8', () {
      final uri = Uri.parse('https://api.hadith-shareef.com/api/hadith/%FF');
      expect(HadithLink.parseId(uri), isNull);
    });

    test('returns null for query encoding that is not valid UTF-8', () {
      final uri = Uri.parse('https://api.hadith-shareef.com/api/hadith?id=%FF');
      expect(HadithLink.parseId(uri), isNull);
    });
  });

  group('HadithLink.build', () {
    test('builds the https link the app is registered for', () {
      expect(
        HadithLink.build('3062').toString(),
        'https://api.hadith-shareef.com/api/hadith/3062',
      );
    });

    test('trims surrounding whitespace from the id', () {
      expect(
        HadithLink.build(' 3062 ').toString(),
        'https://api.hadith-shareef.com/api/hadith/3062',
      );
    });

    test('returns null for an id the receiver could not read back', () {
      expect(HadithLink.build(''), isNull);
      expect(HadithLink.build('12 34'), isNull);
      expect(HadithLink.build('١٢٣'), isNull);
      expect(HadithLink.build('hadith'), isNull);
    });

    test('round-trips through parseId', () {
      expect(HadithLink.parseId(HadithLink.build('3062')!), '3062');
    });
  });
}
