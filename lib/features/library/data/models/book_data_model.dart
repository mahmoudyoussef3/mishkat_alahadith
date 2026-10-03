import 'package:json_annotation/json_annotation.dart';
part 'book_data_model.g.dart';

@JsonSerializable()
class CategoryResponse {
  final int? status;
  final Category? category;
  final List<Book>? books;

  const CategoryResponse({this.status, this.category, this.books});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);
}

@JsonSerializable()
class Category {
  final String? id;
  final String? name;
  final String? nameEn;
  final String? nameUr;
  final String? description;
  final String? descriptionEn;
  final String? descriptionUr;
  final List<String>? books;

  const Category({
    this.id,
    this.name,
    this.nameEn,
    this.nameUr,
    this.description,
    this.descriptionEn,
    this.descriptionUr,
    this.books,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
        Map<String, dynamic> toJson() => _$CategoryToJson(this);

}

@JsonSerializable()
class Book {
  final int? id;
  final String? bookName;
  final String? bookNameEn;
  final String? bookNameUr;
  final String? writerName;
  final String? writerNameEn;
  final String? writerNameUr;
  final String? bookSlug;
  @JsonKey(fromJson: _toInt)
  final int? hadiths_count;
  @JsonKey(fromJson: _toInt)
  final int? chapters_count;
  final String? status;
  final bool? isLocal;
  final String? category;
  final String? filePath;

  const Book({
    this.id,
    this.bookName,
    this.bookNameEn,
    this.bookNameUr,
    this.writerName,
    this.writerNameEn,
    this.writerNameUr,
    this.bookSlug,
    this.hadiths_count,
    this.chapters_count,
    this.status,
    this.isLocal,
    this.category,
    this.filePath,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
          Map<String, dynamic> toJson() => _$BookToJson(this);

}