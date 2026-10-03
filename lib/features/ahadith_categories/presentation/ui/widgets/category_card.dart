import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onExploreSubcategories;
  final VoidCallback onViewAllHadiths;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onExploreSubcategories,
    required this.onViewAllHadiths,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewAllHadiths,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: ColorsManager.secondaryBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: ColorsManager.primaryPurple.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorsManager.primaryPurple,
                      ColorsManager.primaryPurple.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: ColorsManager.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.titleLarge.copyWith(
                        color: ColorsManager.primaryText,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'اضغط لعرض الأحاديث المرتبطة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.bodySmall.copyWith(
                        color: ColorsManager.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              _HadithCountChip(count: category.hadeethsCount),
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_forward_ios_rounded, // Forward for RTL!
                color: ColorsManager.primaryPurple,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HadithCountChip extends StatelessWidget {
  final int count;

  const _HadithCountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 54.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: ColorsManager.primaryGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ColorsManager.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.titleMedium.copyWith(
              color: ColorsManager.primaryGold,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'حديث',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.labelSmall.copyWith(
              color: ColorsManager.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
