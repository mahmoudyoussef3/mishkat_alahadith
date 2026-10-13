import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/answer_blocks.dart';

void main() {
  test('reads Markdown headings, numbered points and paragraphs', () {
    final blocks = parseAnswer('''
## المعنى الإجمالي
يأمر النبي ﷺ بإتمام الركوع والسجود.

### من فوائد الحديث
1. وجوب الطمأنينة في الصلاة.
2. مشروعية القسم لتأكيد الأمر.
''');

    expect(blocks, hasLength(4));
    expect((blocks[0] as AnswerHeading).text, 'المعنى الإجمالي');
    expect(blocks[1], isA<AnswerParagraph>());
    expect((blocks[2] as AnswerHeading).text, 'من فوائد الحديث');
    final list = blocks[3] as AnswerList;
    expect(list.ordered, isTrue);
    expect(list.items, [
      'وجوب الطمأنينة في الصلاة.',
      'مشروعية القسم لتأكيد الأمر.',
    ]);
  });

  test('treats a bold-only line and a short line ending in a colon as headings', () {
    final blocks = parseAnswer('**معاني الكلمات:**\nفوائد الحديث:');

    expect(blocks.map((b) => (b as AnswerHeading).text), [
      'معاني الكلمات',
      'فوائد الحديث',
    ]);
  });

  test('reads Arabic-Indic numbers and bullets as lists', () {
    final blocks = parseAnswer('١. الأولى\n٢) الثانية\n\n- نقطة\n• أخرى');

    expect((blocks[0] as AnswerList).ordered, isTrue);
    expect((blocks[0] as AnswerList).items, ['الأولى', 'الثانية']);
    expect((blocks[1] as AnswerList).ordered, isFalse);
    expect((blocks[1] as AnswerList).items, ['نقطة', 'أخرى']);
  });

  test('sets a line that is wholly a quoted hadith apart', () {
    final blocks = parseAnswer('ومن أصحها:\n«الدين النصيحة».\n> إنما الأعمال بالنيات');

    expect(blocks[1], isA<AnswerQuote>());
    expect((blocks[2] as AnswerQuote).text, 'إنما الأعمال بالنيات');
  });

  test('keeps a long sentence ending in a colon as a paragraph', () {
    const sentence =
        'وردت أحاديث كثيرة تبيّن أن البلاء كفارة للذنوب ورفعة للدرجات لمن صبر، ومن أصحها:';

    expect(parseAnswer(sentence).single, isA<AnswerParagraph>());
  });

  test('returns nothing for blank text', () {
    expect(parseAnswer(' \n \n'), isEmpty);
  });
}
