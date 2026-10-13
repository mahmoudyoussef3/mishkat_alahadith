import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Records the palette and theme brightness its context sees.
class _Probe extends StatelessWidget {
  const _Probe(this.seen);

  final List<(AppPalette, Brightness)> seen;

  @override
  Widget build(BuildContext context) {
    seen.add((AppPaletteOverride.of(context), Theme.of(context).brightness));
    return const SizedBox.shrink();
  }
}

/// A button that opens [open] from inside a dark override over a light app.
Widget _darkReaderOver(void Function(BuildContext context) open) => MaterialApp(
  home: AppPaletteOverride(
    palette: AppPalette.dark,
    child: Builder(
      builder:
          (context) => Scaffold(
            body: TextButton(
              onPressed: () => open(context),
              child: const Text('open'),
            ),
          ),
    ),
  ),
);

void main() {
  tearDown(() => ColorsManager.usePalette(AppPalette.light));

  testWidgets('falls back to the app palette outside an override', (
    tester,
  ) async {
    ColorsManager.usePalette(AppPalette.dark);
    final seen = <(AppPalette, Brightness)>[];

    await tester.pumpWidget(MaterialApp(home: _Probe(seen)));

    expect(seen.last.$1, same(AppPalette.dark));
  });

  testWidgets('sets both the palette and the theme inside an override', (
    tester,
  ) async {
    final seen = <(AppPalette, Brightness)>[];

    await tester.pumpWidget(
      MaterialApp(
        home: AppPaletteOverride(palette: AppPalette.dark, child: _Probe(seen)),
      ),
    );

    expect(seen.last.$1, same(AppPalette.dark));
    expect(seen.last.$2, Brightness.dark);
  });

  testWidgets('a bottom sheet opened inside an override keeps its palette', (
    tester,
  ) async {
    final seen = <(AppPalette, Brightness)>[];
    await tester.pumpWidget(
      _darkReaderOver(
        (context) => showModalBottomSheet<void>(
          context: context,
          builder: (_) => _Probe(seen),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(seen.last.$1, same(AppPalette.dark));
    expect(seen.last.$2, Brightness.dark);
  });

  testWidgets('a dialog opened inside an override keeps its palette', (
    tester,
  ) async {
    final seen = <(AppPalette, Brightness)>[];
    await tester.pumpWidget(
      _darkReaderOver(
        (context) => showDialog<void>(
          context: context,
          builder: (_) => _Probe(seen),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(seen.last.$1, same(AppPalette.dark));
    expect(seen.last.$2, Brightness.dark);
  });
}
