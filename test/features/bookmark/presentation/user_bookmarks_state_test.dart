import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/user_bookmark.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/get_bookmarks/user_bookmarks_cubit.dart';

void main() {
  final state = UserBookmarksSuccess(const [
    UserBookmark(type: 'hadith', collection: 'للحفظ'),
    UserBookmark(type: 'hadith', collection: ' للحفظ '),
    UserBookmark(type: 'hadith', collection: 'أذكار'),
    UserBookmark(type: 'chapter'),
    UserBookmark(type: 'hadith', collection: ''),
  ]);

  test('counts saved hadiths and chapters separately', () {
    expect(state.hadithCount, 4);
    expect(state.chapterCount, 1);
  });

  test('counts each named collection once', () {
    expect(state.collectionCount, 2);
  });
}
