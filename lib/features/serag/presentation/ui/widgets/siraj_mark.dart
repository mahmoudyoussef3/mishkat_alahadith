import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Siraj's mark: a gold sparkle on a gold tile, or on night indigo when
/// [onLight] (for light backgrounds).
class SirajMark extends StatelessWidget {
  const SirajMark({super.key, this.size, this.onLight = false});

  final double? size;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 44.r;
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: onLight ? ColorsManager.heroBackground : ColorsManager.goldBright,
        borderRadius: BorderRadius.circular(dimension * 0.32),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: dimension * 0.55,
        color: onLight ? ColorsManager.goldBright : ColorsManager.onGoldBright,
      ),
    );
  }
}
