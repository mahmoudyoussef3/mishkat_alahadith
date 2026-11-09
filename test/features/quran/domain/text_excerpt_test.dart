import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/domain/services/text_excerpt.dart';

/// The parts of [excerpt] its matches mark.
List<String> _marked(TextExcerpt excerpt) => [
  for (final m in excerpt.matches) excerpt.text.substring(m.start, m.end),
];

void main() {
  test('keeps a short passage whole and marks every occurrence', () {
    final excerpt = TextExcerpts.around(
      'الصبر مفتاح الفرج والصبر جميل',
      'الصبر',
    );

    expect(excerpt.text, 'الصبر مفتاح الفرج والصبر جميل');
    expect(_marked(excerpt), ['الصبر', 'الصبر']);
  });

  test('finds Arabic whatever its harakat', () {
    final excerpt = TextExcerpts.around(
      'إِنَّ ٱللَّهَ مَعَ ٱلصَّٰبِرِينَ',
      'الصابرين',
    );

    expect(_marked(excerpt), ['ٱلصَّٰبِرِينَ']);
  });

  test('finds Latin whatever its case', () {
    final excerpt = TextExcerpts.around(
      'Indeed, Allah is with the Patient',
      'patient',
    );

    expect(_marked(excerpt), ['Patient']);
  });

  test('cuts a long passage around the match, at word boundaries', () {
    final before = List.filled(60, 'قبل').join(' ');
    final after = List.filled(60, 'بعد').join(' ');
    final excerpt = TextExcerpts.around(
      '$before الربا $after',
      'الربا',
      radius: 20,
    );

    expect(excerpt.text, startsWith('${TextExcerpts.ellipsis} '));
    expect(excerpt.text, endsWith(' ${TextExcerpts.ellipsis}'));
    expect(excerpt.text.length, lessThan(80));
    expect(_marked(excerpt), ['الربا']);
    // Never half a word at either edge.
    final words = excerpt.text.split(' ');
    expect(words[1], 'قبل');
    expect(words[words.length - 2], 'بعد');
  });

  test('marks only the occurrences inside the excerpt', () {
    final filler = List.filled(80, 'كلمة').join(' ');
    final excerpt = TextExcerpts.around(
      'الربا $filler الربا',
      'الربا',
      radius: 20,
    );

    expect(_marked(excerpt), ['الربا']);
  });

  test('shows the opening, unmarked, when the query is not found', () {
    final passage = List.filled(100, 'نص').join(' ');
    final excerpt = TextExcerpts.around(passage, 'غائب', radius: 10);

    expect(excerpt.matches, isEmpty);
    expect(excerpt.text, startsWith('نص'));
    expect(excerpt.text, endsWith(TextExcerpts.ellipsis));
  });
}
