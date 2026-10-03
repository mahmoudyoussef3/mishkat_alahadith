import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mishkat_almasabih/core/theming/chapters_decorations.dart';

class ChapterCardShimmer extends StatelessWidget {
  const ChapterCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: ChaptersDecorations.shimmerCard(),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: ChaptersDecorations.shimmerBox(),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16.h,
                    width: double.infinity,
                    decoration: ChaptersDecorations.shimmerLine(),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 14.h,
                    width: 100.w,
                    decoration: ChaptersDecorations.shimmerLine(),
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
