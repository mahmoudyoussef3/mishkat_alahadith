import 'package:json_annotation/json_annotation.dart';
part 'library_statistics_model.g.dart';
@JsonSerializable()
class StatisticsResponse {
  final int status;
  final Statistics statistics;

  StatisticsResponse({required this.status, required this.statistics});
  factory StatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatisticsResponseFromJson(json);

        Map<String,dynamic> toJson()=>_$StatisticsResponseToJson(this);


}

@JsonSerializable()
class Statistics {
  final int totalBooks;
  final int totalHadiths;
  final int totalChapters;
  final Map<String, BooksByCategory> booksByCategory;
  final List<TopBook> topBooks;
  final String lastUpdated;

  Statistics({
    required this.totalBooks,
    required this.totalHadiths,
    required this.totalChapters,
    required this.booksByCategory,
    required this.topBooks,
    required this.lastUpdated,
  });
  factory Statistics.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFromJson(json);
              Map<String,dynamic> toJson()=>_$StatisticsToJson(this);

}

@JsonSerializable()
class BooksByCategory {
  final String name;
  final String nameEn;
  final String nameUr;
  final int count;
  final int hadiths;

  BooksByCategory({
    required this.name,
    required this.nameEn,
    required this.nameUr,
    required this.count,
    required this.hadiths,
  });
  factory BooksByCategory.fromJson(Map<String, dynamic> json) =>
      _$BooksByCategoryFromJson(json);
                    Map<String,dynamic> toJson()=>_$BooksByCategoryToJson(this);

}

@JsonSerializable()
class TopBook {
  final String name;
  final int hadiths;
  final int chapters;

  TopBook({required this.name, required this.hadiths, required this.chapters});
  factory TopBook.fromJson(Map<String, dynamic> json) => _$TopBookFromJson(json);
                Map<String,dynamic> toJson()=>_$TopBookToJson(this);

}