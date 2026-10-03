import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/empty_search_state.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/hadith_by_category_cubit/ahadith_by_category_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/hadith_by_category_cubit/ahadith_by_category_state.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/hadith_details_cubit/cubit/hadith_by_category_details_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/hadith_category_card.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/widgets/error_widget.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';

class AhadithListScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryTitle;

  const AhadithListScreen({
    super.key,
    required this.categoryId,
    this.categoryTitle,
  });

  @override
  State<AhadithListScreen> createState() => _AhadithListScreenState();
}

class _AhadithListScreenState extends State<AhadithListScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_searchQuery.trim().isNotEmpty) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 320) {
      context.read<HadithByCategoryCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => getIt<HadithByCategoryDetailsCubit>(),
        child: BlocListener<
          HadithByCategoryDetailsCubit,
          HadithByCategoryDetailsState
        >(
          listener: (context, state) {
            if (state is HadithByCategoryDetailsLoaded) {
              Navigator.pushNamed(
                context,
                Routes.hadithOfTheDay,
                arguments: {
                  'model': state.dailyHadithModel,
                  'title':
                      widget.categoryTitle?.isNotEmpty == true
                          ? widget.categoryTitle
                          : 'تفاصيل الحديث',
                  'description': 'نص حديث نبوي شريف مع شرحه',
                },
              );
            } else if (state is HadithByCategoryDetailsError) {
              showErrorSnackbar(context, state.message);
            }
          },
          child: Scaffold(
            backgroundColor: ColorsManager.primaryBackground,
            body: SafeArea(
              child: RefreshIndicator(
                color: ColorsManager.primaryPurple,
                onRefresh: () async {
                  await context
                      .read<HadithByCategoryCubit>()
                      .getAhadithByCategory(widget.categoryId, refresh: true);
                },
                child:
                    BlocBuilder<HadithByCategoryCubit, HadithByCategoryState>(
                      builder: (context, state) {
                        return CustomScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            BuildHeaderAppBar(
                              title:
                                  widget.categoryTitle?.isNotEmpty == true
                                      ? widget.categoryTitle!
                                      : 'أحاديث التصنيف',
                              description:
                                  'تصفح الأحاديث المتعلقة بهذا التصنيف',
                              pinned: true,
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                            SliverToBoxAdapter(
                              child: _AhadithSearchField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() => _searchQuery = value);
                                },
                                onClear: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                            ..._buildContentSlivers(context, state),
                            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                          ],
                        );
                      },
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(
    BuildContext context,
    HadithByCategoryState state,
  ) {
    return switch (state) {
      HadithByCategoryInitial() ||
      HadithByCategoryLoading() => _buildLoadingSlivers(),
      HadithByCategoryLoaded() => _buildLoadedSlivers(state),
      HadithByCategoryError(message: final message) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: CategoriesErrorWidget(
            message: message,
            onRetry:
                () => context
                    .read<HadithByCategoryCubit>()
                    .getAhadithByCategory(widget.categoryId),
          ),
        ),
      ],
    };
  }

  List<Widget> _buildLoadingSlivers() {
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: const HadithCardShimmer(),
            ),
            childCount: 6,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildLoadedSlivers(HadithByCategoryLoaded state) {
    final query = _searchQuery.trim();
    final visibleAhadith =
        query.isEmpty
            ? state.ahadith
            : state.ahadith
                .where((hadith) => hadith.title.contains(query))
                .toList();

    if (visibleAhadith.isEmpty) {
      return [
        EmptySliverState(
          title:
              query.isEmpty
                  ? 'لا توجد أحاديث في هذا التصنيف'
                  : 'لا توجد نتائج مطابقة',
          subtitle:
              query.isEmpty
                  ? 'جرّب تصنيفاً آخر أو أعد المحاولة لاحقاً.'
                  : 'جرّب كلمات أخرى داخل أحاديث هذا التصنيف.',
          icon: query.isEmpty ? Icons.menu_book_outlined : Icons.search_off,
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: _CategoryResultSummary(
          totalItems: state.meta.totalItems,
          currentCount: visibleAhadith.length,
          currentPage: state.meta.currentPage,
          lastPage: state.meta.lastPage,
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 16.h)),
      SliverPadding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final hadith = visibleAhadith[index];
            return Column(
              children: [
                GestureDetector(
                  onTap:
                      () => navigateToHadithDetailsScreen(context, hadith.id),
                  child: HadithCategoryCard(hadith: hadith, index: index + 1),
                ),
                if (index != visibleAhadith.length - 1) SizedBox(height: 14.h),
              ],
            );
          }, childCount: visibleAhadith.length),
        ),
      ),
      if (query.isEmpty) _buildPaginationFooter(state),
    ];
  }

  Widget _buildPaginationFooter(HadithByCategoryLoaded state) {
    if (state.isLoadingMore) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: const Center(
            child: CircularProgressIndicator(
              color: ColorsManager.primaryPurple,
            ),
          ),
        ),
      );
    }

    if (state.paginationError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: ColorsManager.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: ColorsManager.error.withOpacity(0.25)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.error_outline,
                  color: ColorsManager.error,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    state.paginationError ?? 'حدث خطأ ما',
                    style: TextStyles.bodySmall.copyWith(
                      color: ColorsManager.error,
                      height: 1.4,
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      () => context.read<HadithByCategoryCubit>().loadMore(),
                  child: Text(
                    'إعادة المحاولة',
                    style: TextStyles.labelMedium.copyWith(
                      color: ColorsManager.primaryPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!state.hasMore) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'تم عرض جميع الأحاديث',
                style: TextStyles.labelMedium.copyWith(
                  color: ColorsManager.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Future<void> navigateToHadithDetailsScreen(
    BuildContext context,
    String hadithId,
  ) async {
    await context.read<HadithByCategoryDetailsCubit>().fetchById(hadithId);
  }
}

class _AhadithSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _AhadithSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

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
          controller: controller,
          onChanged: onChanged,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'ابحث داخل أحاديث التصنيف...',
            hintStyle: TextStyles.bodyMedium.copyWith(
              color: ColorsManager.secondaryText,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: ColorsManager.primaryPurple,
            ),
            suffixIcon:
                controller.text.isEmpty
                    ? null
                    : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                      color: ColorsManager.secondaryText,
                      tooltip: 'مسح البحث',
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

class _CategoryResultSummary extends StatelessWidget {
  final int totalItems;
  final int currentCount;
  final int currentPage;
  final int lastPage;

  const _CategoryResultSummary({
    required this.totalItems,
    required this.currentCount,
    required this.currentPage,
    required this.lastPage,
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
            _SummaryItem(
              icon: Icons.format_list_numbered_rtl_rounded,
              label: 'المعروض',
              value: convertToArabicNumber(currentCount),
              color: ColorsManager.primaryPurple,
            ),
            Container(
              height: 40.h,
              width: 1.w,
              color: ColorsManager.mediumGray.withOpacity(0.5),
            ),
            SizedBox(width: 16.w),
            _SummaryItem(
              icon: Icons.library_books_rounded,
              label: 'الإجمالي',
              value: convertToArabicNumber(totalItems),
              color: ColorsManager.primaryGold,
            ),
            Container(
              height: 40.h,
              width: 1.w,
              color: ColorsManager.mediumGray.withOpacity(0.5),
            ),
            SizedBox(width: 16.w),
            _SummaryItem(
              icon: Icons.layers_rounded,
              label: 'الصفحة',
              value:
                  '${convertToArabicNumber(currentPage)}/${convertToArabicNumber(lastPage)}',
              color: ColorsManager.hadithAuthentic,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
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
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.titleMedium.copyWith(
                    color: ColorsManager.primaryText,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.labelSmall.copyWith(
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
