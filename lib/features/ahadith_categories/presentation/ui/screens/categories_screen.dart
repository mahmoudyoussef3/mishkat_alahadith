import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/categories_cubit/categories_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/categories_cubit/categories_state.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/category_card.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/error_widget.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/loading_shimmer.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.primaryBackground,
        body: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const BuildHeaderAppBar(
                title: 'تصنيفات الأحاديث',
                description: 'استكشف الأحاديث حسب الموضوع',
                pinned: true,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 14.h)),
              BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  return switch (state) {
                    CategoriesInitial() || CategoriesLoading() =>
                      const SliverToBoxAdapter(child: CategoriesShimmer()),
                    CategoriesLoaded(categories: final categories) =>
                      _buildLoadedContent(categories),
                    CategoriesError(message: final message) =>
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: CategoriesErrorWidget(
                          message: message,
                          onRetry:
                              () =>
                                  context
                                      .read<CategoriesCubit>()
                                      .getCategories(),
                        ),
                      ),
                  };
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(List<CategoryEntity> categories) {
    final rootCategories =
        categories.where(_isRootCategory).toList()
          ..sort((a, b) => b.hadeethsCount.compareTo(a.hadeethsCount));
    final query = _query.trim();
    final visibleCategories =
        query.isEmpty
            ? rootCategories
            : rootCategories
                .where((category) => category.title.contains(query))
                .toList();

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: _CategoriesOverview(
            categoriesCount: rootCategories.length,
            hadithsCount: rootCategories.fold<int>(
              0,
              (sum, category) => sum + category.hadeethsCount,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        SliverToBoxAdapter(
          child: _CategoriesSearchField(
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        if (visibleCategories.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyCategoriesState(
              message:
                  query.isEmpty
                      ? 'لا توجد تصنيفات متاحة حالياً'
                      : 'لا توجد نتائج مطابقة للبحث',
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index.isOdd) {
                  return SizedBox(height: 10.h);
                }

                final category = visibleCategories[index ~/ 2];
                return CategoryCard(
                  category: category,
                  onExploreSubcategories: () {},
                  onViewAllHadiths: () {
                    _navigateToHadithListScreen(
                      categoryId: category.id,
                      categoryTitle: category.title,
                    );
                  },
                );
              }, childCount: visibleCategories.length * 2 - 1),
            ),
          ),
      ],
    );
  }

  bool _isRootCategory(CategoryEntity category) {
    return category.parentId == null ||
        category.parentId == '0' ||
        category.parentId == '';
  }

  void _navigateToHadithListScreen({
    required String categoryId,
    required String categoryTitle,
  }) {
    context.pushNamed(
      Routes.ahadithListScreen,
      arguments: {'categoryId': categoryId, 'categoryTitle': categoryTitle},
    );
  }
}

class _CategoriesOverview extends StatelessWidget {
  final int categoriesCount;
  final int hadithsCount;

  const _CategoriesOverview({
    required this.categoriesCount,
    required this.hadithsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: ColorsManager.secondaryBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _OverviewItem(
              icon: Icons.category_rounded,
              label: 'تصنيف',
              value: '$categoriesCount',
              color: ColorsManager.primaryPurple,
            ),
            Container(
              height: 40.h,
              width: 1.w,
              color: ColorsManager.mediumGray.withOpacity(0.5),
            ),
            SizedBox(width: 16.w),
            _OverviewItem(
              icon: Icons.auto_stories_rounded,
              label: 'حديث',
              value: '$hadithsCount',
              color: ColorsManager.primaryGold,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.headlineSmall.copyWith(
                    color: ColorsManager.primaryText,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.bodyMedium.copyWith(
                    color: ColorsManager.secondaryText,
                    fontWeight: FontWeight.w600,
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

class _CategoriesSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _CategoriesSearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'ابحث باسم التصنيف...',
            hintStyle: TextStyles.bodyMedium.copyWith(
              color: ColorsManager.secondaryText,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: ColorsManager.primaryPurple,
            ),
            filled: true,
            fillColor: ColorsManager.secondaryBackground,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: ColorsManager.primaryPurple.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: ColorsManager.primaryPurple,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCategoriesState extends StatelessWidget {
  final String message;

  const _EmptyCategoriesState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: ColorsManager.secondaryText,
            size: 42.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyles.bodyLarge.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
