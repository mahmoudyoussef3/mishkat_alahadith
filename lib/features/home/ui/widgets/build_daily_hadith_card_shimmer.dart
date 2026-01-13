import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mishkat_almasabih/core/theming/home_decorations.dart';

class BuildDailyHadithCardShimmer extends StatelessWidget {
  const BuildDailyHadithCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        height: 180.h,
        width: double.infinity,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(decoration: HomeDecorations.shimmerCardContainer()),
        ),
      ),
    );
  }
}
