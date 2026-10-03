import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/hadith_entity.dart';

class HadithCategoryCard extends StatelessWidget {
  final HadithEntity hadith;
  final int index;

  const HadithCategoryCard({
    super.key,
    required this.hadith,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ColorsManager.secondaryBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: ColorsManager.primaryPurple.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withOpacity(0.04),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                border: Border(
                  bottom: BorderSide(
                    color: ColorsManager.primaryPurple.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _IndexBadge(index: index),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: ColorsManager.primaryGold.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 14.sp,
                          color: ColorsManager.primaryGold,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'حديث',
                          style: TextStyles.labelSmall.copyWith(
                            color: ColorsManager.primaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Text Content Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text(
                hadith.title,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.start,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.hadithText.copyWith(
                  fontSize: 16.sp,
                  height: 1.8,
                  color: ColorsManager.primaryText,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),

      
          ],
        ),
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  final int index;

  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorsManager.primaryPurple,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryPurple.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(Icons.tag_rounded, size: 14.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            convertToArabicNumber(index),
            style: TextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
