// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_daily_hadith_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewDailyHadithModel _$NewDailyHadithModelFromJson(
  Map<String, dynamic> json,
) => NewDailyHadithModel(
  title: json['title'] as String?,
  hadeeth: json['hadeeth'] as String?,
  attribution: json['attribution'] as String?,
  id: json['id'] as String?,
  grade: json['grade'] as String?,
  explanation: json['explanation'] as String?,
  hints: (json['hints'] as List<dynamic>?)?.map((e) => e as String).toList(),
  categories: _categoriesFromJson(json['categories']),
  words_meanings:
      (json['words_meanings'] as List<dynamic>?)
          ?.map(
            (e) => DailyHadithWordMeaning.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$NewDailyHadithModelToJson(
  NewDailyHadithModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'hadeeth': instance.hadeeth,
  'attribution': instance.attribution,
  'grade': instance.grade,
  'explanation': instance.explanation,
  'hints': instance.hints,
  'categories': instance.categories,
  'id': instance.id,
  'words_meanings': instance.words_meanings,
};

DailyHadithWordMeaning _$DailyHadithWordMeaningFromJson(
  Map<String, dynamic> json,
) => DailyHadithWordMeaning(
  word: json['word'] as String?,
  meaning: json['meaning'] as String?,
);

Map<String, dynamic> _$DailyHadithWordMeaningToJson(
  DailyHadithWordMeaning instance,
) => <String, dynamic>{'word': instance.word, 'meaning': instance.meaning};
