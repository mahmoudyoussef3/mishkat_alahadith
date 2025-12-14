import 'package:json_annotation/json_annotation.dart';

part 'stats_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StatsModel {
  int? bookmarksCount;
  int? collectionsCount;
  int? cardsCount;
  int? searchesCount;
  String? lastActivityAt;
  List<TopCollection>? topCollections;

  StatsModel({
    this.bookmarksCount,
    this.collectionsCount,
    this.cardsCount,
    this.searchesCount,
    this.lastActivityAt,
    this.topCollections,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) =>
      _$StatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatsModelToJson(this);
}

@JsonSerializable()
class TopCollection {
  String? name;
  int? count;

  TopCollection({this.name, this.count});

  factory TopCollection.fromJson(Map<String, dynamic> json) =>
      _$TopCollectionFromJson(json);

  Map<String, dynamic> toJson() => _$TopCollectionToJson(this);
}
