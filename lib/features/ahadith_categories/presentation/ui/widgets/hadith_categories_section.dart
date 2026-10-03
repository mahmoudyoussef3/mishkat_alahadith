import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/category_entity.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/section_card.dart';

class HadithCategoriesSection extends StatelessWidget {
  final List<String> categoryIds;
  final List<CategoryEntity> categories;

  const HadithCategoriesSection({
    super.key,
    required this.categoryIds,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final categoryById = {
      for (final category in categories) category.id: category,
    };
    final matchedCategories =
        categoryIds
            .map(
              (id) =>
                  categoryById[id] ??
            CategoryEntity(id: id, title: 'تصنيف مرتبط', hadeethsCount: 0),
            )
            .toList();

    if (matchedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sell_rounded,
                color: ColorsManager.primaryPurple,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'التصنيفات المرتبطة:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                matchedCategories
                    .map(
                      (category) => _CategoryChip(
                        title: category.title,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            Routes.ahadithListScreen,
                            arguments: {
                              'categoryId': category.id,
                              'categoryTitle': category.title,
                            },
                          );
                        },
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: ColorsManager.primaryPurple.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: ColorsManager.primaryPurple.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sell_rounded,
                size: 14.sp,
                color: ColorsManager.primaryPurple.withOpacity(0.7),
              ),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}