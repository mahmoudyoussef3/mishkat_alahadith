import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';

List<int?> _ids(List<ChapterHadith> list) => list.map((h) => h.id).toList();

void main() {
  group('appendUnique', () {
    test('appends only items whose ids are not already loaded', () {
      const existing = [ChapterHadith(id: 1), ChapterHadith(id: 2)];
      const next = [ChapterHadith(id: 2), ChapterHadith(id: 3)];

      expect(_ids(existing.appendUnique(next)), [1, 2, 3]);
    });

    test('keeps the existing copy when an id repeats', () {
      const existing = [ChapterHadith(id: 1, hadithArabic: 'old')];
      const next = [ChapterHadith(id: 1, hadithArabic: 'new')];

      expect(existing.appendUnique(next).single.hadithArabic, 'old');
    });
  });

  group('refreshedWith', () {
    test('puts fresh items first, then cached items not in the fresh page', () {
      const cached = [
        ChapterHadith(id: 1),
        ChapterHadith(id: 2),
        ChapterHadith(id: 3),
      ];
      const fresh = [ChapterHadith(id: 2), ChapterHadith(id: 4)];

      expect(_ids(cached.refreshedWith(fresh)), [2, 4, 1, 3]);
    });

    test('prefers the fresh copy when an id repeats', () {
      const cached = [ChapterHadith(id: 1, status: 'cached')];
      const fresh = [ChapterHadith(id: 1, status: 'fresh')];

      expect(cached.refreshedWith(fresh).single.status, 'fresh');
    });
  });
}
