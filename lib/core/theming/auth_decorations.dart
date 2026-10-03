import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class AuthDecorations {
  AuthDecorations._();

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

  static ShapeDecoration socialCardShape() => ShapeDecoration(
    color: ColorsManager.cardBackground,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
  );

  static BoxDecoration suffixIconChip(Color accent) => BoxDecoration(
    color: ColorsManager.lightGray,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: accent.withOpacity(0.2)),
  );
}
