import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';

Widget _button() => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder:
      (_, __) => MaterialApp(
        home: Center(
          child: FilledButton(
            style: QuranDecorations.continueReadingButton(),
            onPressed: () {},
            child: Text('متابعة', style: QuranTextStyles.continueReadingButton),
          ),
        ),
      ),
);

void main() {
  tearDown(() => ColorsManager.usePalette(AppPalette.light));

  for (final palette in [AppPalette.light, AppPalette.dark]) {
    final name = palette.isDark ? 'dark' : 'light';

    testWidgets('continue reading label uses the button foreground in $name '
        'mode', (tester) async {
      ColorsManager.usePalette(palette);
      await tester.pumpWidget(_button());

      final label = tester.widget<RichText>(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(RichText),
        ),
      );
      final foreground =
          QuranDecorations.continueReadingButton().foregroundColor!.resolve(
            {},
          );

      expect(label.text.style!.color, foreground);
    });
  }
}
