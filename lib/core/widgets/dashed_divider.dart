import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';

/// One-pixel dashed rule that separates a card's body from its footer.
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key, this.color});

  /// Defaults to the palette's medium gray.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashPainter(
          color ?? AppPaletteOverride.of(context).mediumGray,
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = size.height;
    final y = size.height / 2;
    for (double x = 0; x < size.width; x += _dash + _gap) {
      canvas.drawLine(Offset(x, y), Offset(x + _dash, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
