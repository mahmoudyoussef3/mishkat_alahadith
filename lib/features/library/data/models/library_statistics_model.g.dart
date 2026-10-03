// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatisticsResponse _$StatisticsResponseFromJson(Map<String, dynamic> json) =>
    StatisticsResponse(
      status: (json['status'] as num).toInt(),
      statistics: Statistics.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$StatisticsResponseToJson(StatisticsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'statistics': instance.statistics,
    };

Statistics _$StatisticsFromJson(Map<String, dynamic> json) => Statistics(
  totalBooks: (json['totalBooks'] as num).toInt(),
  totalHadiths: (json['totalHadiths'] as num).toInt(),
  totalChapters: (json['totalChapters'] as num).toInt(),
  booksByCategory: (json['booksByCategory'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, BooksByCategory.fromJson(e as Map<String, dynamic>)),
  ),
  topBooks:
      (json['topBooks'] as List<dynamic>)
          .map((e) => TopBook.fromJson(e as Map<String, dynamic>))
          .toList(),
  lastUpdated: json['lastUpdated'] as String,
);

Map<String, dynamic> _$StatisticsToJson(Statistics instance) =>
    <String, dynamic>{
      'totalBooks': instance.totalBooks,
      'totalHadiths': instance.totalHadiths,
      'totalChapters': instance.totalChapters,
      'booksByCategory': instance.booksByCategory,
      'topBooks': instance.topBooks,
      'lastUpdated': instance.lastUpdated,
    };

BooksByCategory _$BooksByCategoryFromJson(Map<String, dynamic> json) =>
    BooksByCategory(
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      nameUr: json['nameUr'] as String,
      count: (json['count'] as num).toInt(),
      hadiths: (json['hadiths'] as num).toInt(),
    );

Map<String, dynamic> _$BooksByCategoryToJson(BooksByCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameEn': instance.nameEn,
      'nameUr': instance.nameUr,
      'count': instance.count,
      'hadiths': instance.hadiths,
    };

TopBook _$TopBookFromJson(Map<String, dynamic> json) => TopBook(
  name: json['name'] as String,
  hadiths: (json['hadiths'] as num).toInt(),
  chapters: (json['chapters'] as num).toInt(),
);

Map<String, dynamic> _$TopBookToJson(TopBook instance) => <String, dynamic>{
  'name': instance.name,
  'hadiths': instance.hadiths,
  'chapters': instance.chapters,
};
