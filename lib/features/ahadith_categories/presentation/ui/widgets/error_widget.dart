import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

class CategoriesErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CategoriesErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: ColorsManager.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 30.sp,
              color: ColorsManager.error,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'تعذر تحميل التصنيفات',
            textAlign: TextAlign.center,
            style: TextStyles.titleLarge.copyWith(
              color: ColorsManager.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyles.bodyMedium.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: 20.sp),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryPurple,
              foregroundColor: ColorsManager.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }
}
