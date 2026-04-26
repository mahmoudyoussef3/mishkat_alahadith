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
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48.sp,
                    color: Colors.red[400],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'حدث خطأ ما',
                textDirection: TextDirection.rtl,
                style: TextStyles.font24BlueBold.copyWith(
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyles.font14GrayRegular.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh_rounded, size: 20.sp),
                  label: Text('حاول مجددا'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
