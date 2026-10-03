class BookmarksResponse {
  final List<Bookmark>? bookmarks;
  final Pagination? pagination;

  BookmarksResponse({this.bookmarks, this.pagination});

  factory BookmarksResponse.fromJson(Map<String, dynamic> json) {
    return BookmarksResponse(
      bookmarks: (json['bookmarks'] as List<dynamic>?)
          ?.map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookmarks': bookmarks?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class Bookmark {
  final int? id;
  final int? userId;
  final String? type;
  final String? bookSlug;
  final String? bookName;
  final String? bookNameEn;
  final String? bookNameUr;
  final int? chapterNumber;
  final String? chapterName;
  final String? chapterNameEn;
  final String? chapterNameUr;
  final String? hadithId;
  final String? hadithNumber;
  final String? hadithText;
  final String? hadithTextEn;
  final String? hadithTextUr;
  final String? collection;
  final String? notes;
  final int? isLocal;
  final String? createdAt;
  final String? updatedAt;

  Bookmark({
    this.id,
    this.userId,
    this.type,
    this.bookSlug,
    this.bookName,
    this.bookNameEn,
    this.bookNameUr,
    this.chapterNumber,
    this.chapterName,
    this.chapterNameEn,
    this.chapterNameUr,
    this.hadithId,
    this.hadithNumber,
    this.hadithText,
    this.hadithTextEn,
    this.hadithTextUr,
    this.collection,
    this.notes,
    this.isLocal,
    this.createdAt,
    this.updatedAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
          bookSlug: json['book_slug'] ?? json['bookSlug'],
    hadithText: json['hadith_text'] ?? json['hadithText'],
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      type: json['type'] as String?,
      bookName: json['book_name'] ?? json['bookName'],
      bookNameEn: json['book_name_en'] as String?,
      bookNameUr: json['book_name_ur'] as String?,
      chapterNumber: json['chapter_number'] as int?,
      chapterName: json['chapter_name'] as String?,
      chapterNameEn: json['chapter_name_en'] as String?,
      chapterNameUr: json['chapter_name_ur'] as String?,
      hadithId: json['hadith_id'] as String?,
      hadithNumber: json['hadith_number'] as String?,
      hadithTextEn: json['hadith_text_en'] as String?,
      hadithTextUr: json['hadith_text_ur'] as String?,
      collection: json['collection'] as String?,
      notes: json['notes'] as String?,
      isLocal: json['is_local'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'bookSlug': bookSlug,
      'bookName': bookName,
      'bookNameEn': bookNameEn,
      'bookNameUr': bookNameUr,
      'chapterNumber': chapterNumber,
      'chapterName': chapterName,
      'chapterNameEn': chapterNameEn,
      'chapterNameUr': chapterNameUr,
      'hadithId': hadithId,
      'hadithNumber': hadithNumber,
      'hadithText': hadithText,
      'hadithTextEn': hadithTextEn,
      'hadithTextUr': hadithTextUr,
      'collection': collection,
      'notes': notes,
      'isLocal': isLocal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Pagination {
  final int? currentPage;
  final int? totalPages;
  final int? totalItems;
  final int? itemsPerPage;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalItems,
    this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int?,
      totalPages: json['total_pages'] as int?,
      totalItems: json['total_items'] as int?,
      itemsPerPage: json['items_per_page'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
    };
  }
}
