import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

/// AuthDecorations centralizes BoxDecorations for Authentication flows.
class AuthDecorations {
  AuthDecorations._();

  /// Circular logo avatar with themed shadow.
  static BoxDecoration logoCircle() => BoxDecoration(
    shape: BoxShape.circle,
    color: ColorsManager.primaryPurple,
    boxShadow: [
      BoxShadow(
        color: ColorsManager.primaryPurple.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 5,
        offset: const Offset(0, 10),
      ),
    ],
  );

  /// Card style for social login or guest buttons.
  static ShapeDecoration socialCardShape() => ShapeDecoration(
    color: ColorsManager.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
  );

  /// Chip-style container for input suffix icons.
  static BoxDecoration suffixIconChip(Color accent) => BoxDecoration(
    color: ColorsManager.lightGray,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: accent.withOpacity(0.2)),
  );
}
