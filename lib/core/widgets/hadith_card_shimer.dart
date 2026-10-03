import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class HadithCardShimmer extends StatelessWidget {
  const HadithCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorsManager.shimmerBase,
      highlightColor: ColorsManager.shimmerHighlight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: ColorsManager.disabledText,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                Container(
                  width: 60.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: ColorsManager.disabledText,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Container(
              width: double.infinity,
              height: 14.h,
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: ColorsManager.disabledText,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            Container(
              width: double.infinity,
              height: 14.h,
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: ColorsManager.disabledText,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            Container(
              width: 200.w,
              height: 14.h,
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: ColorsManager.disabledText,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),

            SizedBox(height: 16.h),

            Row(
              children: [
                Container(
                  width: 100.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: ColorsManager.disabledText,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 120.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: ColorsManager.disabledText,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
