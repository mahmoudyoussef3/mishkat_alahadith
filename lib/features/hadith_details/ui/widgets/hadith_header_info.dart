import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class HadithHeaderInfo extends StatelessWidget {
  final String hadithId;
  final String? bookName;

  const HadithHeaderInfo({
    super.key,
    required this.hadithId,
    required this.bookName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorsManager.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            color: ColorsManager.primaryGreen,
            size: 28.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حديث رقم $hadithId',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.primaryText,
                  ),
                ),
                if (bookName != null && bookName!.trim().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(endIndent: 60.w),
                      Text(
                        'من ${bookName!}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: ColorsManager.secondaryText,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
