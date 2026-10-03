import 'package:json_annotation/json_annotation.dart';

part 'navigation_hadith_model.g.dart';

@JsonSerializable()
class NavigationHadithResponse {
  final int? status;
  final Book? book;
  final Hadith? nextHadith;
  final Hadith? prevHadith;
  final String? currentHadithNumber;
  final int? totalHadiths;

  NavigationHadithResponse({
    this.status,
    this.book,
    this.nextHadith,
    this.prevHadith,
    this.currentHadithNumber,
    this.totalHadiths,
  });
  factory NavigationHadithResponse.fromJson(Map<String, dynamic> json) =>
      _$NavigationHadithResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NavigationHadithResponseToJson(this);
}

@JsonSerializable()
class Book {
  final String? bookName;
  final String? bookNameEn;

  Book({this.bookName, this.bookNameEn});
  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}

@JsonSerializable()
class Hadith {
  final String? id;
  final String? title;

  Hadith({this.id, this.title});
  factory Hadith.fromJson(Map<String, dynamic> json) => _$HadithFromJson(json);
  Map<String, dynamic> toJson() => _$HadithToJson(this);
}
