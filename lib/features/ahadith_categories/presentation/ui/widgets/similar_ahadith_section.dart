import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/hadith_by_category_cubit/ahadith_by_category_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/hadith_by_category_cubit/ahadith_by_category_state.dart';

class SimilarAhadithSection extends StatelessWidget {
  final List<String> categoryIds;
  final List<CategoryEntity> categories;

  const SimilarAhadithSection({
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
            .map((id) => categoryById[id])
            .whereType<CategoryEntity>()
            .toList();

    if (matchedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          matchedCategories
              .map(
                (category) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _CategorySimilarAhadith(category: category),
                ),
              )
              .toList(),
    );
  }
}

class _CategorySimilarAhadith extends StatefulWidget {
  final CategoryEntity category;

  const _CategorySimilarAhadith({required this.category});

  @override
  State<_CategorySimilarAhadith> createState() =>
      _CategorySimilarAhadithState();
}

class _CategorySimilarAhadithState extends State<_CategorySimilarAhadith> {
  late final HadithByCategoryCubit _cubit;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _cubit =
        getIt<HadithByCategoryCubit>()
          ..getAhadithByCategory(widget.category.id);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<HadithByCategoryCubit, HadithByCategoryState>(
        builder: (context, state) {
          if (state is HadithByCategoryLoading ||
              state is HadithByCategoryInitial) {
            return const SizedBox.shrink();
          }

          if (state is HadithByCategoryError) {
            return const SizedBox.shrink();
          }

          if (state is HadithByCategoryLoaded) {
            if (state.ahadith.isEmpty) return const SizedBox.shrink();

            final ahadithToShow = state.ahadith.take(3).toList();

            return Container(
              decoration: BoxDecoration(
                color: ColorsManager.secondaryBackground,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color:
                      _isExpanded
                          ? ColorsManager.primaryPurple.withOpacity(0.3)
                          : ColorsManager.primaryPurple.withOpacity(0.1),
                  width: _isExpanded ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  onExpansionChanged: (expanded) {
                    setState(() => _isExpanded = expanded);
                  },
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  childrenPadding: EdgeInsets.zero,
                  iconColor: ColorsManager.primaryPurple,
                  collapsedIconColor: ColorsManager.secondaryText,
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.folder_special_rounded,
                      size: 20.sp,
                      color: ColorsManager.primaryPurple,
                    ),
                  ),
                  title: Text(
                    'أحاديث مشابهة في التصنيف',
                    style: TextStyles.labelSmall.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      widget.category.title,
                      style: TextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.primaryText,
                      ),
                    ),
                  ),
                  children: [
                    Container(
                      color: ColorsManager.primaryBackground.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        children: [
                          ...ahadithToShow.asMap().entries.map((entry) {
                            final hadith = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Material(
                                color: ColorsManager.white,
                                borderRadius: BorderRadius.circular(12.r),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.shareHadithLink,
                                      arguments: hadith.id,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 14.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: ColorsManager.mediumGray
                                            .withOpacity(0.4),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.menu_book_rounded,
                                          size: 18.sp,
                                          color: ColorsManager.primaryGold,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            hadith.title,
                                            textDirection: TextDirection.rtl,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyles.bodyMedium
                                                .copyWith(
                                                  height: 1.6,
                                                  color: ColorsManager
                                                      .primaryText
                                                      .withOpacity(0.9),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: 4.h),
                          Material(
                            color: ColorsManager.primaryPurple.withOpacity(
                              0.08,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.ahadithListScreen,
                                  arguments: {
                                    'categoryId': widget.category.id,
                                    'categoryTitle': widget.category.title,
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'عرض المزيد من الأحاديث',
                                      style: TextStyles.labelLarge.copyWith(
                                        color: ColorsManager.primaryPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14.sp,
                                      color: ColorsManager.primaryPurple,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
