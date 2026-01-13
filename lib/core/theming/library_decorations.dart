import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class LibraryDecorations {
  // Book card outer container
  static BoxDecoration bookCardContainer() {
    return BoxDecoration(
      color: ColorsManager.white,
      borderRadius: BorderRadius.circular(20.r),
    );
  }

  // Book image box with rounded top corners
  static BoxDecoration bookImageBox(String assetPath) {
    return BoxDecoration(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.r),
      ),
      image: DecorationImage(
        image: AssetImage(assetPath),
        fit: BoxFit.cover,
      ),
    );
  }

  // Shimmer card container used in grid placeholders
  static BoxDecoration shimmerCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8.r,
          offset: Offset(0, 4.h),
        ),
      ],
    );
  }

  // Generic shimmer box for inner lines/rects
  static BoxDecoration shimmerBox({bool circular = false, double? radius}) {
    return BoxDecoration(
      color: Colors.grey[300],
      borderRadius:
          circular ? BorderRadius.circular(50) : BorderRadius.circular(radius ?? 8.r),
    );
  }
}
