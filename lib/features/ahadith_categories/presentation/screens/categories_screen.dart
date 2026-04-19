import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/categories_cubit/categories_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/categories_cubit/categories_state.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/categories_header.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/category_card.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/error_widget.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/loading_shimmer.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/search_bar.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: CategoriesSearchBar(
                  onSearch: (query) {
                    if (query.trim().isEmpty) return;
                    _showActionSnackBar('البحث عن: $query');
                  },
                ),
              ),

              // Header
              SliverToBoxAdapter(child: CategoriesHeader()),

              // Content
              BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  return switch (state) {
                    CategoriesInitial() || CategoriesLoading() =>
                      SliverToBoxAdapter(child: CategoriesShimmer()),
                    CategoriesLoaded(categories: final categories) =>
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: _getMaxCrossAxisExtent(context),
                            mainAxisExtent: _getMainAxisExtent(context),
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 16.h,
                            childAspectRatio: 0.6,
                          ),
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final category = categories[index];
                            return CategoryCard(
                              category: category,
                              onExploreSubcategories: () {
                                _navigateToSubcategoriesScreen(category.id);
                              },
                              onViewAllHadiths: () {
                                _navigateToHadithListScreen(
                                  categoryId: category.id,
                                  categoryTitle: category.title,
                                );
                              },
                            );
                          }, childCount: categories.length),
                        ),
                      ),
                    CategoriesError(message: final message) =>
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 360.h,
                          child: CategoriesErrorWidget(
                            message: message,
                            onRetry:
                                () => context.read<CategoriesCubit>().getCategories(),
                          ),
                        ),
                      ),
                  };
                },
              ),

              // Bottom Spacing
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          ),
        ),
      ),
    );
  }

  double _getMaxCrossAxisExtent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 180.w;
    } else if (width < 900) {
      return 240.w;
    } else {
      return 280.w;
    }
  }

  double _getMainAxisExtent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 230.h;
    } else if (width < 900) {
      return 220.h;
    } else {
      return 210.h;
    }
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: ColorsManager.primaryPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSubcategoriesScreen(String categoryId) {
    _showActionSnackBar('استكشاف الفئات الفرعية قريباً');
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
