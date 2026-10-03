// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_daily_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HadithData _$HadithDataFromJson(Map<String, dynamic> json) => HadithData(
  title: json['title'] as String?,
  hadeeth: json['hadeeth'] as String?,
  attribution: json['attribution'] as String?,
  id: json['id'] as String?,
  grade: json['grade'] as String?,
  explanation: json['explanation'] as String?,
  hints: (json['hints'] as List<dynamic>?)?.map((e) => e as String).toList(),
  wordsMeanings:
      (json['words_meanings'] as List<dynamic>?)
          ?.map((e) => WordMeaning.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$HadithDataToJson(HadithData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'hadeeth': instance.hadeeth,
      'attribution': instance.attribution,
      'grade': instance.grade,
      'explanation': instance.explanation,
      'hints': instance.hints,
      'id': instance.id,
      'words_meanings': instance.wordsMeanings,
    };

WordMeaning _$WordMeaningFromJson(Map<String, dynamic> json) => WordMeaning(
  word: json['word'] as String?,
  meaning: json['meaning'] as String?,
);

Map<String, dynamic> _$WordMeaningToJson(WordMeaning instance) =>
    <String, dynamic>{'word': instance.word, 'meaning': instance.meaning};
