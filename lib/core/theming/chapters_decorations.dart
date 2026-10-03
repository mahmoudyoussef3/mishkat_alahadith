import 'decorations.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class ChaptersDecorations {
  static BoxDecoration chapterCard() => Decorations.card(radius: 18);

  static BoxDecoration numberChip(Color accent) =>
      Decorations.iconWell(accent, radius: 14);

  static BoxDecoration statsCard(Color color) => BoxDecoration(
    gradient: LinearGradient(
      colors: [ColorsManager.headerStart, ColorsManager.headerEnd],
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
    ),
    borderRadius: BorderRadius.circular(20),
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
