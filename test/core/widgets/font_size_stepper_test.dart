import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_scope.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/font_size_stepper.dart';

const _labels = ['صغير', 'متوسط', 'كبير'];

Future<List<int>> _pump(WidgetTester tester, int selectedIndex) async {
  final changes = <int>[];
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (_, _) => MaterialApp(
            home: AppPaletteScope(
              child: Scaffold(
                body: FontSizeStepper(
                  labels: _labels,
                  selectedIndex: selectedIndex,
                  onChanged: changes.add,
                ),
              ),
            ),
          ),
    ),
  );
  return changes;
}

AppIconButton _button(WidgetTester tester, String tooltip) =>
    tester.widget<AppIconButton>(
      find.ancestor(
        of: find.byTooltip(tooltip),
        matching: find.byType(AppIconButton),
      ),
    );

void main() {
  testWidgets('the larger button steps one size up', (tester) async {
    final changes = await _pump(tester, 1);

    await tester.tap(find.byTooltip('تكبير الخط'));

    expect(changes, [2]);
  });

  testWidgets('the smaller button steps one size down', (tester) async {
    final changes = await _pump(tester, 1);

    await tester.tap(find.byTooltip('تصغير الخط'));

    expect(changes, [0]);
  });

  testWidgets('picking a size reports it', (tester) async {
    final changes = await _pump(tester, 0);

    await tester.tap(find.text('كبير'));

    expect(changes, [2]);
  });

  testWidgets('the smaller button is off at the smallest size', (tester) async {
    await _pump(tester, 0);

    expect(_button(tester, 'تصغير الخط').onPressed, isNull);
    expect(_button(tester, 'تكبير الخط').onPressed, isNotNull);
  });

  testWidgets('the larger button is off at the largest size', (tester) async {
    await _pump(tester, 2);

    expect(_button(tester, 'تكبير الخط').onPressed, isNull);
  });
}
