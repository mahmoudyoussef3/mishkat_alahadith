import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/remove_quran_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/toggle_quran_bookmark_use_case.dart';

import '../quran_fakes.dart';

void main() {
  final now = DateTime(2026, 10, 3, 9, 30);

  group('ToggleQuranBookmarkUseCase', () {
    test('adds a page that is not bookmarked and reports it added', () async {
      final repo = FakeQuranReadingRepo();
      final toggle = ToggleQuranBookmarkUseCase(repo, now: () => now);

      final result = await toggle(page: 5, surahNumber: 2, surahName: 'البقرة');

      expect(dataOf(result), isTrue);
      expect(repo.bookmarks.single.page, 5);
      expect(repo.bookmarks.single.createdAt, now);
    });

    test('removes a page that is bookmarked and reports it removed', () async {
      final repo = FakeQuranReadingRepo(bookmarks: [pageBookmark(5)]);
      final toggle = ToggleQuranBookmarkUseCase(repo, now: () => now);

      final result = await toggle(page: 5, surahNumber: 2, surahName: 'البقرة');

      expect(dataOf(result), isFalse);
      expect(repo.bookmarks, isEmpty);
    });

    test('keeps a page bookmark when an ayah on that page is added', () async {
      final repo = FakeQuranReadingRepo(bookmarks: [pageBookmark(1)]);
      final toggle = ToggleQuranBookmarkUseCase(repo, now: () => now);

      await toggle(
        page: 1,
        surahNumber: 1,
        surahName: 'الفاتحة',
        ayahId: 2,
        ayahNumber: 2,
      );

      expect(repo.bookmarks, hasLength(2));
    });

    test('fails without writing when the bookmarks cannot be read', () async {
      final repo = FakeQuranReadingRepo(failReads: true);
      final toggle = ToggleQuranBookmarkUseCase(repo, now: () => now);

      final result = await toggle(page: 5, surahNumber: 2, surahName: 'البقرة');

      expect(result, isA<ApiFailure>());
    });

    test('fails when the new list cannot be saved', () async {
      final repo = FakeQuranReadingRepo(failWrites: true);
      final toggle = ToggleQuranBookmarkUseCase(repo, now: () => now);

      final result = await toggle(page: 5, surahNumber: 2, surahName: 'البقرة');

      expect(result, isA<ApiFailure>());
    });
  });

  test('GetQuranBookmarksUseCase lists the newest bookmark first', () async {
    final repo = FakeQuranReadingRepo(
      bookmarks: [
        pageBookmark(3, at: DateTime(2026, 1, 1)),
        pageBookmark(9, at: DateTime(2026, 5, 1)),
      ],
    );

    final bookmarks = dataOf(await GetQuranBookmarksUseCase(repo)());

    expect(bookmarks.map((b) => b.page), [9, 3]);
  });

  test('RemoveQuranBookmarkUseCase removes only the given place', () async {
    final repo = FakeQuranReadingRepo(
      bookmarks: [pageBookmark(3), ayahBookmark(7)],
    );

    await RemoveQuranBookmarkUseCase(repo)(pageBookmark(3));

    expect(repo.bookmarks.single.ayahId, 7);
  });

  group('SaveLastReadUseCase', () {
    test('saves the page with the current time', () async {
      final repo = FakeQuranReadingRepo();

      await SaveLastReadUseCase(repo, now: () => now)(45);

      expect(repo.lastRead?.page, 45);
      expect(repo.lastRead?.savedAt, now);
    });

    test('rejects a page outside the mushaf', () async {
      final repo = FakeQuranReadingRepo();

      final result = await SaveLastReadUseCase(repo, now: () => now)(0);

      expect(result, isA<ApiFailure>());
      expect(repo.lastRead, isNull);
    });
  });
}
