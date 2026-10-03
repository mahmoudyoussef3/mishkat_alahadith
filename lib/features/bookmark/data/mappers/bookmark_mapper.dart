import '../../domain/entities/bookmark_action_result.dart';
import '../../domain/entities/bookmark_collection.dart';
import '../../domain/entities/user_bookmark.dart';
import '../models/book_mark_model.dart';
import '../models/book_mark_response.dart';
import '../models/collection_model.dart';

extension BookmarkMapper on Bookmark {
  UserBookmark toEntity() => UserBookmark(
    id: id,
    userId: userId,
    type: type,
    bookSlug: bookSlug,
    bookName: bookName,
    bookNameEn: bookNameEn,
    bookNameUr: bookNameUr,
    chapterNumber: chapterNumber,
    chapterName: chapterName,
    chapterNameEn: chapterNameEn,
    chapterNameUr: chapterNameUr,
    hadithId: hadithId,
    hadithNumber: hadithNumber,
    hadithText: hadithText,
    hadithTextEn: hadithTextEn,
    hadithTextUr: hadithTextUr,
    collection: collection,
    notes: notes,
    isLocal: isLocal,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension UserBookmarkMapper on UserBookmark {
  Bookmark toModel() => Bookmark(
    id: id,
    userId: userId,
    type: type,
    bookSlug: bookSlug,
    bookName: bookName,
    bookNameEn: bookNameEn,
    bookNameUr: bookNameUr,
    chapterNumber: chapterNumber,
    chapterName: chapterName,
    chapterNameEn: chapterNameEn,
    chapterNameUr: chapterNameUr,
    hadithId: hadithId,
    hadithNumber: hadithNumber,
    hadithText: hadithText,
    hadithTextEn: hadithTextEn,
    hadithTextUr: hadithTextUr,
    collection: collection,
    notes: notes,
    isLocal: isLocal,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension CollectionsResponseMapper on CollectionsResponse {
  List<BookmarkCollection> toEntities() => [
    for (final item in collections ?? const <CollectionItem>[])
      BookmarkCollection(collection: item.collection, count: item.count),
  ];
}

extension AddBookmarkResponseMapper on AddBookmarkResponse {
  BookmarkActionResult toEntity() =>
      BookmarkActionResult(message: message, bookmarkId: bookmarkId);
}
