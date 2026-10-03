import 'package:json_annotation/json_annotation.dart';
part 'hadith_daily_response.g.dart';



@JsonSerializable()
class HadithData {
  final String? title;
  final String? hadeeth;
  final String? attribution;
  final String? grade;
  final String? explanation;
  final List<String>? hints;
  final String? id;

  @JsonKey(name: 'words_meanings')
  final List<WordMeaning>? wordsMeanings;

  const HadithData({
    this.title,
    this.hadeeth,
    this.attribution,
    this.id,
    this.grade,
    this.explanation,
    this.hints,
    this.wordsMeanings,
  });
  factory HadithData.fromJson(Map<String, dynamic> json) =>
      _$HadithDataFromJson(json);

  Map<String, dynamic> toJson() => _$HadithDataToJson(this);
}

@JsonSerializable()
class WordMeaning {
  final String? word;
  final String? meaning;

  const WordMeaning({this.word, this.meaning});
  factory WordMeaning.fromJson(Map<String, dynamic> json) =>
      _$WordMeaningFromJson(json);

  Map<String, dynamic> toJson() => _$WordMeaningToJson(this);
}
