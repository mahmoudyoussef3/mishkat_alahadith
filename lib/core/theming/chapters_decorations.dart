import 'package:flutter/material.dart';
import 'colors.dart';

class ChaptersDecorations {
  static BoxDecoration chapterCard(Color accent) => BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: LinearGradient(
      colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(color: Colors.black.withOpacity(0.07)),
    boxShadow: [
      BoxShadow(
        color: accent.withOpacity(0.08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration numberChip(Color accent) => BoxDecoration(
    gradient: LinearGradient(
      colors: [accent, accent.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: accent.withOpacity(0.35),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration statsCard(Color color) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        color.withOpacity(0.95),
        ColorsManager.primaryPurple.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.25),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration shimmerCard() => BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: ColorsManager.cardBackground,
  );

  static BoxDecoration shimmerBox() => BoxDecoration(
    color: ColorsManager.disabledText,
    borderRadius: BorderRadius.circular(14),
  );

  static BoxDecoration shimmerLine() => BoxDecoration(
    color: ColorsManager.disabledText,
    borderRadius: BorderRadius.circular(8),
  );

  static ShapeBorder emptyCardShape() =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
}
