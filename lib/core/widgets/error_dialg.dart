import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  
  const ErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.cardBackground,
            ColorsManager.offWhite.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: ColorsManager.hadithWeak.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.hadithWeak.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8.h),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 40.r,
              color: ColorsManager.primaryPurple.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'تنبيه',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: ColorsManager.primaryText,
              fontFamily: 'Amiri',
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.secondaryText,
              fontFamily: 'Amiri',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryPurple.withOpacity(0.1),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: ColorsManager.purpleText,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        color: ColorsManager.purpleText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
