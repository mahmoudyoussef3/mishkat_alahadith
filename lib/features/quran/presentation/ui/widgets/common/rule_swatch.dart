import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';

/// The small colour square that keys a tajweed rule.
class RuleSwatch extends StatelessWidget {
  final Color color;
  final double size;

  const RuleSwatch({super.key, required this.color, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: QuranDecorations.ruleSwatch(color),
    );
  }
}
