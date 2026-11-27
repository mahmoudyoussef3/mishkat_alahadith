import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/category_style.dart';

/// "التصنيفات": the topics a hadith belongs to, each opening its list.
class HadithCategoriesSection extends StatelessWidget {
  const HadithCategoriesSection({super.key, required this.categories});

  /// The hadith's topics, already matched to their titles.
  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التصنيفات',
          style: TextStyles.caption.copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            for (final category in categories)
              Semantics(
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap:
                      () => Navigator.of(context).pushNamed(
                        Routes.ahadithListScreen,
                        arguments: CategoryHadithsArgs(
                          categoryId: category.id,
                          title: category.title,
                          hadithsCount:
                              category.hadeethsCount > 0
                                  ? category.hadeethsCount
                                  : null,
                        ),
                      ),
                  child: AppBadge(
                    label: category.title,
                    icon: Icons.sell_rounded,
                    background: ColorsManager.primarySoft,
                    foreground: ColorsManager.purpleText,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
