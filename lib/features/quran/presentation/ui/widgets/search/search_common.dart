import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:shimmer/shimmer.dart';

/// A state message that stays reachable above the keyboard.
class QuranSearchCentered extends StatelessWidget {
  final Widget child;

  const QuranSearchCentered({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(top: 24.h),
      children: [child],
    );
  }
}

/// Placeholder cards while results load.
class QuranSearchResultsShimmer extends StatelessWidget {
  const QuranSearchResultsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final block = ColorsManager.shimmerBase;
    return Shimmer.fromColors(
      baseColor: ColorsManager.shimmerBase,
      highlightColor: ColorsManager.shimmerHighlight,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder:
            (context, index) => Container(
              height: 128.h,
              decoration: BoxDecoration(
                color: block,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
      ),
    );
  }
}
