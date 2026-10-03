import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';

import '../models/enhanced_search_response_model.dart';

extension EnhancedSearchMapper on EnhancedSearch {
  List<ExplainedHadith> toEntities() => [
    for (final hadith in results ?? const <EnhancedHadithModel>[])
      hadith.toEntity(),
  ];
}

extension EnhancedHadithModelMapper on EnhancedHadithModel {
  ExplainedHadith toEntity() => ExplainedHadith(
    id: id,
    title: title,
    hadeeth: hadeeth,
    hadeethIntro: hadeethIntro,
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
