import 'package:flutter/material.dart';
import 'colors.dart';

class ChaptersDecorations {
  // Outer chapter card container
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

  // Number chip with gradient
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

  // Statistics card container
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

  // Shimmer placeholder for chapter card
  static BoxDecoration shimmerCard() => BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Colors.white,
  );

  static BoxDecoration shimmerBox() => BoxDecoration(
    color: Colors.grey.shade400,
    borderRadius: BorderRadius.circular(14),
  );

  static BoxDecoration shimmerLine() => BoxDecoration(
    color: Colors.grey.shade400,
    borderRadius: BorderRadius.circular(8),
  );

  // Empty state card in chapters list
  static ShapeBorder emptyCardShape() =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
}
