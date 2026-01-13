import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

/// Decorations provides reusable BoxDecoration, Gradients, and BorderRadius
/// patterns consistent with the app's Islamic-themed design.
class Decorations {
  Decorations._();

  /// Primary diagonal gradient used for prominent section backgrounds.
  /// Uses themed purples to align with the app color palette.
  static const LinearGradient primaryDiagonalGradient = LinearGradient(
    colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Info/Card container decoration used for descriptive sections.
  /// White card surface, subtle border, and soft shadow.
  static BoxDecoration infoCard = BoxDecoration(
    color: ColorsManager.cardBackground,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: ColorsManager.mediumGray, width: 1),
    boxShadow: [
      BoxShadow(
        color: ColorsManager.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Circular white surface with pronounced drop shadow.
  /// Suitable for avatars or circular logos.
  static BoxDecoration circleWhiteShadow = BoxDecoration(
    shape: BoxShape.circle,
    color: ColorsManager.white,
    boxShadow: [
      BoxShadow(
        color: ColorsManager.black.withOpacity(0.2),
        blurRadius: 30,
        spreadRadius: 5,
        offset: const Offset(0, 15),
      ),
    ],
  );

  /// Convenience builder for vertical top rounded border radius.
  static BorderRadius verticalTop(double radius) =>
      BorderRadius.vertical(top: Radius.circular(radius));
}
