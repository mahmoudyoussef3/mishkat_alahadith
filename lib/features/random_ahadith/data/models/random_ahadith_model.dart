import 'package:json_annotation/json_annotation.dart';
import 'package:mishkat_almasabih/core/data/models/hadith_daily_response.dart';

part 'random_ahadith_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RandomAhadithResponse {
  final List<RandomHadithModel>? hadiths;

  RandomAhadithResponse({this.hadiths});

  factory RandomAhadithResponse.fromJson(Map<String, dynamic> json) =>
      _$RandomAhadithResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RandomAhadithResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RandomHadithModel {
  final String? hadithId;
  final String? hadith;
  final String? title;
  final String? attribution;
  final String? grade;
  final String? explanation;
  final List<String>? hints;
  final List<String>? categoriesIds;
  final List<WordMeaning>? words_meanings;
  final String? reference;
  final String? language;
  final List<String>? categories;

  RandomHadithModel({
    this.hadithId,
    this.hadith,
    this.title,
    this.attribution,
    this.grade,
    this.explanation,
    this.hints,
    this.categoriesIds,
    this.words_meanings,
    this.reference,
    this.language,
    this.categories,
  });

  factory RandomHadithModel.fromJson(Map<String, dynamic> json) =>
      _$RandomHadithModelFromJson(json);

  Map<String, dynamic> toJson() => _$RandomHadithModelToJson(this);
}


