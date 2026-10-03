import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';

import '../models/new_daily_hadith_model.dart';

extension NewDailyHadithModelMapper on NewDailyHadithModel {
  ExplainedHadith toEntity() => ExplainedHadith(
    id: id,
    title: title,
    hadeeth: hadeeth,
    attribution: attribution,
    grade: grade,
    explanation: explanation,
    hints: hints,
    categories: categories,
    wordsMeanings:
        words_meanings
            ?.map((w) => HadithWordMeaning(word: w.word, meaning: w.meaning))
            .toList(),
  );
}
