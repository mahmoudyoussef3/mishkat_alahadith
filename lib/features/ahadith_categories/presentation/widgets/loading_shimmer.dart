import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesShimmer extends StatelessWidget {
  final int itemCount;

  const CategoriesShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxExtent = width < 600 ? 180.w : width < 900 ? 240.w : 280.w;
    final mainExtent = width < 600 ? 230.h : width < 900 ? 220.h : 210.h;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
        mainAxisExtent: mainExtent,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: itemCount,
      itemBuilder: (context, index) => _ShimmerCard(),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Icon placeholder
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            SizedBox(height: 8.h),
            // Title placeholder
            Container(
              width: double.infinity,
              height: 10.h,
              color: Colors.grey[300],
            ),
            SizedBox(height: 6.h),
            Container(
              width: 100.w,
              height: 10.h,
              color: Colors.grey[300],
            ),
            const Spacer(),
            // Button placeholders
            Container(
              width: double.infinity,
              height: 34.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              height: 34.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
