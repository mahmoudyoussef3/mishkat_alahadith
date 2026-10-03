import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mishkat_almasabih/core/theming/library_decorations.dart';

class BookCardShimmer extends StatelessWidget {
  const BookCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LibraryDecorations.shimmerCard(),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: LibraryDecorations.shimmerBox(radius: 20.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14.h,
                    width: double.infinity,
                    decoration: LibraryDecorations.shimmerBox(),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 12.h,
                    width: 80.w,
                    decoration: LibraryDecorations.shimmerBox(),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 14.h,
                        width: 50.w,
                        decoration: LibraryDecorations.shimmerBox(),
                      ),
                      Container(
                        height: 14.h,
                        width: 50.w,
                        decoration: LibraryDecorations.shimmerBox(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
