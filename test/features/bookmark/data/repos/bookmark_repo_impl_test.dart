import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_response.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/collection_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/repos/bookmark_repo_impl.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/bookmark_collection.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/user_bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  Bookmark? addedBody;
  int? deletedId;

  @override
  Future<BookmarksResponse> getUserBookmarks(String token) async =>
      BookmarksResponse(
        bookmarks: [Bookmark(id: 1, hadithText: 'إنما الأعمال بالنيات')],
      );

  @override
  Future<CollectionsResponse> getBookmarkCollection(String token) async =>
      CollectionsResponse(
        collections: [CollectionItem(collection: 'المفضلة', count: 3)],
      );

  @override
  Future<AddBookmarkResponse> addBookmark(String token, Bookmark body) async {
    addedBody = body;
    return AddBookmarkResponse(message: 'تمت الإضافة', bookmarkId: 9);
  }

  @override
  Future<AddBookmarkResponse> deleteUserBookmsrk(int id, String token) async {
    deletedId = id;
    return AddBookmarkResponse(message: 'تم الحذف');
  }
}

void main() {
  final cache = GenericCacheService.instance;
  late _FakeApiService api;
  late BookmarkRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({'token': 't1'}));

  setUp(() {
    api = _FakeApiService();
    repo = BookmarkRepoImpl(api, TokenStorage(), cache);
  });

  tearDown(() async {
    await cache.clearCache(CacheKeys.bookmarks);
    await cache.clearCache(CacheKeys.bookmarkCollections);
  });

  test('getBookmarks maps and caches the list', () async {
    final result = await repo.getBookmarks();

    expect((result as ApiSuccess<List<UserBookmark>>).data.single.id, 1);
    expect((await repo.getCachedBookmarks())?.single.hadithText, 'إنما الأعمال بالنيات');
  });

  test('addBookmark sends the entity as the request body and drops the cached list', () async {
    await repo.getBookmarks();

    final result = await repo.addBookmark(
      const UserBookmark(type: 'hadith', hadithId: '5', collection: 'المفضلة'),
    );

    expect(result, isA<ApiSuccess>());
    expect(api.addedBody?.hadithId, '5');
    expect(api.addedBody?.collection, 'المفضلة');
    expect(await repo.getCachedBookmarks(), isNull);
  });

  test('deleteBookmark drops the cached list', () async {
    await repo.getBookmarks();

    await repo.deleteBookmark(1);

    expect(api.deletedId, 1);
    expect(await repo.getCachedBookmarks(), isNull);
  });

  test('getCollections maps collection items', () async {
    final result = await repo.getCollections();

    final collection =
        (result as ApiSuccess<List<BookmarkCollection>>).data.single;
    expect(collection.collection, 'المفضلة');
    expect(collection.count, 3);
  });

  test('returns UnauthorizedFailure without a session token', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    addTearDown(() => prefs.setString('token', 't1'));

    final result = await repo.deleteBookmark(1);

    expect((result as ApiFailure).failure, isA<UnauthorizedFailure>());
    expect(api.deletedId, isNull);
  });
}
