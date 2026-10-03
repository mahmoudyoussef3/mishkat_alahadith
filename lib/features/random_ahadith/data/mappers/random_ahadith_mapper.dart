import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';

import '../models/random_ahadith_model.dart';

extension RandomAhadithResponseMapper on RandomAhadithResponse {
  List<ExplainedHadith> toEntities() => [
    for (final hadith in hadiths ?? const <RandomHadithModel>[])
      hadith.toEntity(),
  ];
}

extension RandomHadithModelMapper on RandomHadithModel {
  ExplainedHadith toEntity() => ExplainedHadith(
    id: hadithId,
    title: title,
    hadeeth: hadith,
    hadeethIntro: title,
    attribution: attribution,
    grade: grade,
    explanation: explanation,
    reference: reference,
    hints: hints,
    categories: categories,
    wordsMeanings:
        words_meanings
            ?.map((w) => HadithWordMeaning(word: w.word, meaning: w.meaning))
            .toList(),
  );
}
