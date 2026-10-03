import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/hadith_decorations.dart';

class IslamicSeparator extends StatelessWidget {
  const IslamicSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2.h,
              decoration: HadithDecorations.separatorLine(),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.all(8.w),
            decoration: HadithDecorations.quoteChip(),
            child: Icon(
              Icons.format_quote,
              color: ColorsManager.primaryPurple,
              size: 20.r,
            ),
          ),
          Expanded(
            child: Container(
              height: 2.h,
              decoration: HadithDecorations.separatorLine(reverse: true),
            ),
          ),
        ],
      ),
    );
  }
}
