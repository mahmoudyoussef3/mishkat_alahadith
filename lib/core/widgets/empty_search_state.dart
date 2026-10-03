import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class EmptySliverState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData icon;

  const EmptySliverState({
    super.key,
    this.title = 'لا توجد نتائج',
    this.subtitle = 'حاول تغيير كلمات البحث أو إزالة الفلاتر لعرض المزيد.',
    this.buttonText,
    this.onButtonPressed,
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                color: ColorsManager.offWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, size: 56.r, color: ColorsManager.primaryPurple),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: ColorsManager.primaryText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onButtonPressed != null) ...[
              SizedBox(height: 18.h),
              SizedBox(
                height: 44.h,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primaryPurple,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    buttonText ?? 'إعادة المحاولة',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData icon;

  const EmptyState({
    super.key,
    this.title = 'لا توجد نتائج',
    this.subtitle = 'حاول تغيير كلمات البحث أو إزالة الفلاتر لعرض المزيد.',
    this.buttonText,
    this.onButtonPressed,
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              color: ColorsManager.offWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: 56.r, color: ColorsManager.primaryPurple),
          ),
          SizedBox(height: 18.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: ColorsManager.primaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.secondaryText,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (onButtonPressed != null) ...[
            SizedBox(height: 18.h),
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryPurple,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  buttonText ?? 'إعادة المحاولة',
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
