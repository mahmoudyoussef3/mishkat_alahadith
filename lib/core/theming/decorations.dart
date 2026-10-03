import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class Decorations {
  Decorations._();

  static LinearGradient get primaryDiagonalGradient => LinearGradient(
    colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration get infoCard => BoxDecoration(
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

  static BoxDecoration get circleWhiteShadow => BoxDecoration(
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

  static BorderRadius verticalTop(double radius) =>
      BorderRadius.vertical(top: Radius.circular(radius));
}
