class ExplainedHadith {
  final String? id;
  final String? title;
  final String? hadeeth;
  final String? hadeethIntro;
  final String? attribution;
  final String? grade;
  final String? explanation;
  final String? reference;
  final List<String>? hints;
  final List<String>? categories;
  final List<HadithWordMeaning>? wordsMeanings;

  const ExplainedHadith({
    this.id,
    this.title,
    this.hadeeth,
    this.hadeethIntro,
    this.attribution,
    this.grade,
    this.explanation,
    this.reference,
    this.hints,
    this.categories,
    this.wordsMeanings,
  });
}

class HadithWordMeaning {
  final String? word;
  final String? meaning;

  const HadithWordMeaning({this.word, this.meaning});
}
