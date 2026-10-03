import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/home/data/models/search_history_models.dart';

class HistoryListItem extends StatelessWidget {
  final SearchHistoryItem item;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const HistoryListItem({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onTap,
  });

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date); // or 'd MMM yyyy' for nice style
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(item.date);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: ColorsManager.mediumGray.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Search icon
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: ColorsManager.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.search,
                color: ColorsManager.primaryGreen,
                size: 18.r,
              ),
            ),
            SizedBox(width: 12.w),

            // Title & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorsManager.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${item.time}  |  $formattedDate",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Colors.grey[400],
                size: 18.r,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
