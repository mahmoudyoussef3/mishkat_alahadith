// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryResponse _$CategoryResponseFromJson(Map<String, dynamic> json) =>
    CategoryResponse(
      status: (json['status'] as num?)?.toInt(),
      category:
          json['category'] == null
              ? null
              : Category.fromJson(json['category'] as Map<String, dynamic>),
      books:
          (json['books'] as List<dynamic>?)
              ?.map((e) => Book.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CategoryResponseToJson(CategoryResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'category': instance.category,
      'books': instance.books,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String?,
  name: json['name'] as String?,
  nameEn: json['nameEn'] as String?,
  nameUr: json['nameUr'] as String?,
  description: json['description'] as String?,
  descriptionEn: json['descriptionEn'] as String?,
  descriptionUr: json['descriptionUr'] as String?,
  books: (json['books'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameEn': instance.nameEn,
  'nameUr': instance.nameUr,
  'description': instance.description,
  'descriptionEn': instance.descriptionEn,
  'descriptionUr': instance.descriptionUr,
  'books': instance.books,
};

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: (json['id'] as num?)?.toInt(),
  bookName: json['bookName'] as String?,
  bookNameEn: json['bookNameEn'] as String?,
  bookNameUr: json['bookNameUr'] as String?,
  writerName: json['writerName'] as String?,
  writerNameEn: json['writerNameEn'] as String?,
  writerNameUr: json['writerNameUr'] as String?,
  bookSlug: json['bookSlug'] as String?,
  hadiths_count: Book._toInt(json['hadiths_count']),
  chapters_count: Book._toInt(json['chapters_count']),
  status: json['status'] as String?,
  isLocal: json['isLocal'] as bool?,
  category: json['category'] as String?,
  filePath: json['filePath'] as String?,
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'bookName': instance.bookName,
  'bookNameEn': instance.bookNameEn,
  'bookNameUr': instance.bookNameUr,
  'writerName': instance.writerName,
  'writerNameEn': instance.writerNameEn,
  'writerNameUr': instance.writerNameUr,
  'bookSlug': instance.bookSlug,
  'hadiths_count': instance.hadiths_count,
  'chapters_count': instance.chapters_count,
  'status': instance.status,
  'isLocal': instance.isLocal,
  'category': instance.category,
  'filePath': instance.filePath,
};
