import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Top-right corner cell (RTL pinned header intersection).
///
/// Sits on the solid-purple header row, so text is white.
class GridCornerCell extends StatelessWidget {
  const GridCornerCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'اليوم',
        style: TextStyles.bodySmall.copyWith(
          fontSize: 12.sp,
          color: ColorsManager.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
