import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'استعرض التصنيفات',
            textDirection: TextDirection.rtl,
            style: TextStyles.font24BlueBold.copyWith(
              color: ColorsManager.primaryPurple,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'اختر من التصنيفات التالية لاستكشاف الأحاديث الشريفة',
            textDirection: TextDirection.rtl,
            style: TextStyles.font14GrayRegular.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
