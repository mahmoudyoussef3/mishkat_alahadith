import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/empty_search_state.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/separator.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/hadith_by_category_cubit/ahadith_by_category_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/cubit/hadith_by_category_cubit/ahadith_by_category_state.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 320) {
      context.read<HadithByCategoryCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.primaryBackground,
        body: SafeArea(
          child: RefreshIndicator(
            color: ColorsManager.primaryPurple,
            onRefresh: () async {
              await context.read<HadithByCategoryCubit>().getAhadithByCategory(
                widget.categoryId,
                refresh: true,
              );
            },
            child: BlocBuilder<HadithByCategoryCubit, HadithByCategoryState>(
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
                      description: _buildDescription(state),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 6.h)),
                    ..._buildContentSlivers(context, state),
                    SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String? _buildDescription(HadithByCategoryState state) {
    return switch (state) {
      HadithByCategoryLoaded(ahadith: final ahadith, meta: final meta) =>
        'عدد الأحاديث: ${convertToArabicNumber(ahadith.length)} • صفحة ${convertToArabicNumber(meta.currentPage)} من ${convertToArabicNumber(meta.lastPage)}',
      HadithByCategoryLoading() => 'جارٍ تحميل الأحاديث...',
      HadithByCategoryError() => 'تعذر تحميل الأحاديث',
      _ => null,
    };
  }

  List<Widget> _buildContentSlivers(
    BuildContext context,
    HadithByCategoryState state,
  ) {
    return switch (state) {
      HadithByCategoryInitial() ||
      HadithByCategoryLoading() => _buildLoadingSlivers(),
      HadithByCategoryLoaded() =>
        _buildLoadedSlivers(state as HadithByCategoryLoaded),
      HadithByCategoryError(message: final message) => [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 360.h,
            child: CategoriesErrorWidget(
              message: message,
              onRetry:
                  () => context
                      .read<HadithByCategoryCubit>()
                      .getAhadithByCategory(widget.categoryId),
            ),
          ),
        ),
      ],
    };
  }

  List<Widget> _buildLoadingSlivers() {
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const HadithCardShimmer(),
          childCount: 6,
        ),
      ),
    ];
  }

  List<Widget> _buildLoadedSlivers(HadithByCategoryLoaded state) {
    if (state.ahadith.isEmpty) {
      return [
        const EmptySliverState(
          title: 'لا توجد أحاديث في هذا التصنيف',
          subtitle: 'جرّب تصنيفاً آخر أو أعد المحاولة لاحقاً.',
          icon: Icons.menu_book_outlined,
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final hadith = state.ahadith[index];
            return Column(
              children: [
                HadithCategoryCard(hadith: hadith, index: index + 1),
                if (index != state.ahadith.length - 1)
                  const IslamicSeparator(),
              ],
            );
          }, childCount: state.ahadith.length),
        ),
      ),
      _buildPaginationFooter(state),
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
              color: ColorsManager.error.withAlpha(16),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: ColorsManager.error.withAlpha(60),
              ),
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
                    style: TextStyle(
                      fontSize: 13.sp,
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
                    style: TextStyle(
                      fontSize: 12.sp,
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withAlpha(14),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'تم عرض جميع الأحاديث',
                style: TextStyle(
                  fontSize: 12.sp,
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
}
