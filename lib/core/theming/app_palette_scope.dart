import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'colors.dart';

class AppPaletteScope extends StatefulWidget {
  final Widget child;

  const AppPaletteScope({super.key, required this.child});

  @override
  State<AppPaletteScope> createState() => _AppPaletteScopeState();
}

class _AppPaletteScopeState extends State<AppPaletteScope> {
  Brightness? _brightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (brightness == _brightness) return;

    final isFirstBuild = _brightness == null;
    _brightness = brightness;
    ColorsManager.usePalette(
      brightness == Brightness.dark ? AppPalette.dark : AppPalette.light,
    );
    if (!isFirstBuild) _rebuildDescendants();
  }

  void _rebuildDescendants() {
    void markDirty(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markDirty);
    }

    (context as Element).visitChildren(markDirty);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
