import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesShimmer extends StatelessWidget {
  final int itemCount;

  const CategoriesShimmer({super.key, this.itemCount = 7});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _ShimmerBox(height: 74.h),
          SizedBox(height: 12.h),
          _ShimmerBox(height: 50.h),
          SizedBox(height: 12.h),
          ...List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _ShimmerBox(height: 82.h),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;

  const _ShimmerBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorsManager.mediumGray,
      highlightColor: ColorsManager.lightGray,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: ColorsManager.secondaryBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
