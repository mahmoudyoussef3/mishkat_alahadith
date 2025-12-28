import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
        height: 2.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorsManager.primaryPurple.withOpacity(0.3),
              ColorsManager.primaryGold.withOpacity(0.6),
              ColorsManager.primaryPurple.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(1.r),
        ),
      ),
    );
  }
}
