import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';
import 'package:mishkat_almasabih/core/widgets/screen_title_header.dart';
import 'package:mishkat_almasabih/core/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_state.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/category_style.dart';
import 'package:shimmer/shimmer.dart';

/// Hadiths by topic: the largest topic featured, the rest in a grid sized
/// by how many hadiths each holds.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _open(CategoryEntity category, CategoriesLoaded state) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.pushNamed(
      Routes.ahadithListScreen,
      arguments: CategoryHadithsArgs(
        categoryId: category.id,
        title: category.title,
        hadithsCount: category.hadeethsCount,
        subcategories: state.childrenOf(category.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state) {
              final roots =
                  state is CategoriesLoaded
                      ? state.roots
                      : const <CategoryEntity>[];
              final total = state is CategoriesLoaded ? state.totalHadiths : 0;

              return CustomScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: ScreenTitleHeader(
                      title: 'تصنيفات الأحاديث',
                      subtitle:
                          roots.isEmpty
                              ? 'استكشف الأحاديث حسب الموضوع'
                              : '${arabicCount(roots.length, _category)} · '
                                  '${arabicCount(total, ArabicNoun.hadith)} حسب الموضوع',
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
                    sliver: switch (state) {
                      CategoriesLoaded() => _content(state, roots, total),
                      CategoriesError(:final message) => SliverToBoxAdapter(
                        child: StateMessage.error(
                          message: message,
                          onRetry: context.read<CategoriesCubit>().getCategories,
                        ),
                      ),
                      _ => const SliverToBoxAdapter(child: _CategoriesLoading()),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _content(
    CategoriesLoaded state,
    List<CategoryEntity> roots,
    int total,
  ) {
    final query = normalizeArabic(_query);
    final searching = query.isNotEmpty;
    final matches =
        searching
            ? roots.where((c) => normalizeArabic(c.title).contains(query)).toList()
            : roots;
    final featured = !searching && roots.isNotEmpty ? roots.first : null;
    final grid = featured == null ? matches : matches.skip(1).toList();
    // Guards the bar ratio against topics that all report no hadiths.
    final largest = roots.isEmpty ? 1 : max(1, roots.first.hadeethsCount);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SearchBarWidget(
            controller: _searchController,
            hintText: 'ابحث باسم التصنيف…',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 14.h)),
        if (featured != null) ...[
          SliverToBoxAdapter(
            child: _FeaturedCategory(
              category: featured,
              share: total == 0 ? 0 : featured.hadeethsCount / total,
              onTap: () => _open(featured, state),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 14.h)),
        ],
        if (matches.isEmpty)
          SliverToBoxAdapter(
            child:
                searching
                    ? const StateMessage(
                      icon: Icons.search_off_rounded,
                      title: 'لا يوجد تصنيف بهذا الاسم',
                      subtitle: 'جرّب كلمة أخرى',
                    )
                    : const StateMessage(
                      icon: Icons.category_outlined,
                      title: 'لا توجد تصنيفات متاحة حالياً',
                    ),
          )
        else
          SliverGrid.builder(
            itemCount: grid.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              mainAxisExtent: 140.h,
            ),
            itemBuilder:
                (context, index) => _CategoryTile(
                  category: grid[index],
                  share: grid[index].hadeethsCount / largest,
                  onTap: () => _open(grid[index], state),
                ),
          ),
      ],
    );
  }

  static const _category = ArabicNoun(
    singular: 'تصنيف',
    dual: 'تصنيفان',
    plural: 'تصنيفات',
    accusative: 'تصنيفاً',
  );
}

class _FeaturedCategory extends StatelessWidget {
  const _FeaturedCategory({
    required this.category,
    required this.share,
    required this.onTap,
  });

  final CategoryEntity category;

  /// Fraction of all hadiths that are in this category.
  final double share;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(category.title);
    final muted = ColorsManager.white.withValues(alpha: 0.78);

    return HeroSurface(
      scrim: HeroScrim.horizontal,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: ColorsManager.goldBright,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(style.icon, size: 26.r, color: ColorsManager.onGoldBright),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأكبر',
                  style: TextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.goldBright,
                  ),
                ),
                Text(
                  category.title,
                  style: TextStyles.sectionTitle.copyWith(
                    fontSize: 19.sp,
                    color: ColorsManager.white,
                  ),
                ),
                Text(
                  '${arabicCount(category.hadeethsCount, ArabicNoun.hadith)} · '
                  '${toArabicDigits('${(share * 100).round()}')}٪ من المجموع',
                  style: TextStyles.caption.copyWith(color: muted),
                ),
              ],
            ),
          ),
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: ColorsManager.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: ColorsManager.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.share,
    required this.onTap,
  });

  final CategoryEntity category;

  /// Size relative to the largest category, for the bar.
  final double share;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(category.title);
    return Material(
      color: ColorsManager.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(style.icon, size: 22.r, color: style.foreground),
                ),
              ),
              const Spacer(),
              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              Text(
                arabicCount(category.hadeethsCount, ArabicNoun.hadith),
                style: TextStyles.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: LinearProgressIndicator(
                  value: share.clamp(0.03, 1.0),
                  minHeight: 4.h,
                  color: style.foreground,
                  backgroundColor: ColorsManager.lightGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesLoading extends StatelessWidget {
  const _CategoriesLoading();

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double radius = 20}) => Container(
      height: height,
      decoration: BoxDecoration(
        color: ColorsManager.shimmerBase,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );

    return Shimmer.fromColors(
      baseColor: ColorsManager.shimmerBase,
      highlightColor: ColorsManager.shimmerHighlight,
      child: Column(
        children: [
          block(52.h, radius: 16),
          SizedBox(height: 14.h),
          block(92.h, radius: 24),
          SizedBox(height: 14.h),
          for (var row = 0; row < 3; row++) ...[
            Row(
              children: [
                Expanded(child: block(140.h)),
                SizedBox(width: 10.w),
                Expanded(child: block(140.h)),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}
