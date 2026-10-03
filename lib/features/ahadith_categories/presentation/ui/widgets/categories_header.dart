import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 10.h, 20.w, 16.h),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.category_rounded,
              color: ColorsManager.primaryPurple,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'التصنيفات الرئيسية',
                  style: TextStyles.font24BlueBold.copyWith(
                    color: ColorsManager.primaryPurple,
                    fontSize: 20.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'اختر تصنيفاً لاستكشاف الأحاديث',
                  style: TextStyles.font14GrayRegular.copyWith(
                    color: ColorsManager.secondaryText,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
