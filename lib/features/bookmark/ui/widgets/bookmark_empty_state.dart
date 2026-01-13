import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_styles.dart';

class BookmarkEmptyState extends StatelessWidget {
  const BookmarkEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 50.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 60.r,
            color: ColorsManager.secondaryText,
          ),
          SizedBox(height: 12.h),
          Text(
            "لا توجد علامات مرجعية في هذه المجموعة",
            style: BookmarkTextStyles.emptyStateText,
          ),
        ],
      ),
    );
  }
}
