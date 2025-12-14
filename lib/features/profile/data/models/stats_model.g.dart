// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatsModel _$StatsModelFromJson(Map<String, dynamic> json) => StatsModel(
  bookmarksCount: (json['bookmarksCount'] as num?)?.toInt(),
  collectionsCount: (json['collectionsCount'] as num?)?.toInt(),
  cardsCount: (json['cardsCount'] as num?)?.toInt(),
  searchesCount: (json['searchesCount'] as num?)?.toInt(),
  lastActivityAt: json['lastActivityAt'] as String?,
  topCollections:
      (json['topCollections'] as List<dynamic>?)
          ?.map((e) => TopCollection.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$StatsModelToJson(
  StatsModel instance,
) => <String, dynamic>{
  'bookmarksCount': instance.bookmarksCount,
  'collectionsCount': instance.collectionsCount,
  'cardsCount': instance.cardsCount,
  'searchesCount': instance.searchesCount,
  'lastActivityAt': instance.lastActivityAt,
  'topCollections': instance.topCollections?.map((e) => e.toJson()).toList(),
};

TopCollection _$TopCollectionFromJson(Map<String, dynamic> json) =>
    TopCollection(
      name: json['name'] as String?,
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TopCollectionToJson(TopCollection instance) =>
    <String, dynamic>{'name': instance.name, 'count': instance.count};
