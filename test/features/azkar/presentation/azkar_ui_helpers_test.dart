import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';

import '../azkar_fakes.dart';

void main() {
  group('repetitionLabel', () {
    test('reads naturally for each count', () {
      expect(repetitionLabel(1), 'مرة');
      expect(repetitionLabel(3), '٣ مرات');
      expect(repetitionLabel(33), '٣٣ مرة');
      expect(repetitionLabel(100), '١٠٠ مرة');
    });
  });

  group('formatZikrForSharing', () {
    test('gives the words, how often, and the source', () {
      final text = formatZikrForSharing(
        morningEvening,
        morningEvening.azkar[1],
      );

      expect(
        text,
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ\n(٣ مرات)\n\n'
        '— أذكار الصباح والمساء · حصن المسلم',
      );
    });

    test('adds the meaning when a translation is shown', () {
      final category = sampleCatalogEnglish.first;

      final text = formatZikrForSharing(category, category.azkar.first);

      expect(text, contains('\nMeaning 27.1\n'));
    });

    test('leaves out the count for a zikr said once', () {
      final text = formatZikrForSharing(
        morningEvening,
        morningEvening.azkar.first,
      );

      expect(text, isNot(contains('(')));
    });
  });
}
