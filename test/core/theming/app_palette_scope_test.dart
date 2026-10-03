import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_scope.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

const _swatchKey = Key('swatch');

/// Const, so it is only rebuilt if the scope marks it dirty.
class _Swatch extends StatelessWidget {
  const _Swatch();

  @override
  Widget build(BuildContext context) =>
      ColoredBox(key: _swatchKey, color: ColorsManager.cardBackground);
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => taps++),
    child: Text('taps: $taps', textDirection: TextDirection.ltr),
  );
}

Widget _app(ThemeMode mode) => MaterialApp(
  theme: ThemeData(brightness: Brightness.light),
  darkTheme: ThemeData(brightness: Brightness.dark),
  themeMode: mode,
  builder: (context, child) => AppPaletteScope(child: child!),
  home: const Column(children: [Expanded(child: _Swatch()), _Counter()]),
);

Color _swatchColor(WidgetTester tester) =>
    tester.widget<ColoredBox>(find.byKey(_swatchKey)).color;

void main() {
  tearDown(() => ColorsManager.usePalette(AppPalette.light));

  testWidgets('first build uses the palette matching the theme', (
    tester,
  ) async {
    await tester.pumpWidget(_app(ThemeMode.dark));

    expect(ColorsManager.isDark, isTrue);
    expect(_swatchColor(tester), AppPalette.dark.cardBackground);
  });

  testWidgets('switching theme repaints const descendants in the new palette', (
    tester,
  ) async {
    await tester.pumpWidget(_app(ThemeMode.light));
    expect(_swatchColor(tester), AppPalette.light.cardBackground);

    await tester.pumpWidget(_app(ThemeMode.dark));
    await tester.pumpAndSettle();
    expect(_swatchColor(tester), AppPalette.dark.cardBackground);

    await tester.pumpWidget(_app(ThemeMode.light));
    await tester.pumpAndSettle();
    expect(_swatchColor(tester), AppPalette.light.cardBackground);
  });

  testWidgets('switching theme keeps widget state', (tester) async {
    await tester.pumpWidget(_app(ThemeMode.light));
    await tester.tap(find.byType(TextButton));
    await tester.pump();

    await tester.pumpWidget(_app(ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(find.text('taps: 1'), findsOneWidget);
  });
}
