import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/filter_pill.dart';
import 'package:mishkat_almasabih/core/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/chapter_hadith_tile.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_by_category/ahadith_by_category_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_by_category/ahadith_by_category_state.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_details/hadith_by_category_details_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/category_style.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_text.dart';

/// The hadiths of one topic, narrowed by sub-topic or by words, opening
/// each with its explanation.
class AhadithListScreen extends StatefulWidget {
  const AhadithListScreen({super.key, required this.args});

  final CategoryHadithsArgs args;

  @override
  State<AhadithListScreen> createState() => _AhadithListScreenState();
}

class _AhadithListScreenState extends State<AhadithListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late String _selectedId = widget.args.categoryId;
  String _query = '';

  /// The hadith whose explanation is being fetched.
  String? _openingId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_query.isNotEmpty || !_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 400) {
      context.read<HadithByCategoryCubit>().loadMore();
    }
  }

  void _select(String categoryId) {
    if (categoryId == _selectedId) return;
    setState(() => _selectedId = categoryId);
    context.read<HadithByCategoryCubit>().getAhadithByCategory(categoryId);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final style = CategoryStyle.of(args.title);

    return BlocProvider(
      create: (_) => getIt<HadithByCategoryDetailsCubit>(),
      child: BlocListener<HadithByCategoryDetailsCubit, HadithByCategoryDetailsState>(
        listener: (context, state) {
          if (state is HadithByCategoryDetailsLoaded) {
            setState(() => _openingId = null);
            Navigator.pushNamed(
              context,
              Routes.hadithOfTheDay,
              arguments: {
                'model': state.dailyHadithModel,
                'title': args.title,
                'description': 'نص حديث نبوي شريف مع شرحه',
              },
            );
          } else if (state is HadithByCategoryDetailsError) {
            setState(() => _openingId = null);
            showErrorSnackbar(context, state.message);
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: ColorsManager.secondaryBackground,
            body: SafeArea(
              bottom: false,
              child: BlocBuilder<HadithByCategoryCubit, HadithByCategoryState>(
                builder: (context, state) {
                  final total =
                      state is HadithByCategoryLoaded
                          ? state.meta.totalItems
                          : args.hadithsCount;
                  return Column(
                    children: [
                      DetailHeader(
                        title: args.title,
                        subtitle:
                            total == null
                                ? null
                                : arabicCount(total, ArabicNoun.hadith),
                        leading: Container(
                          width: 42.r,
                          height: 42.r,
                          decoration: BoxDecoration(
                            color: style.background,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(style.icon, size: 22.r, color: style.foreground),
                        ),
                        bottom: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SearchBarWidget(
                              controller: _searchController,
                              hintText: 'ابحث داخل ${args.title}…',
                              onChanged:
                                  (value) => setState(
                                    () => _query = normalizeArabic(value),
                                  ),
                            ),
                            if (args.subcategories.isNotEmpty) ...[
                              SizedBox(height: 12.h),
                              _SubcategoryChips(
                                parent: args,
                                selectedId: _selectedId,
                                onSelected: _select,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh:
                              () => context
                                  .read<HadithByCategoryCubit>()
                                  .getAhadithByCategory(_selectedId, refresh: true),
                          child: CustomScrollView(
                            controller: _scrollController,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                              ..._body(context, state),
                              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, HadithByCategoryState state) {
    final cubit = context.read<HadithByCategoryCubit>();
    switch (state) {
      case HadithByCategoryError(:final message):
        return [
          SliverToBoxAdapter(
            child: StateMessage.error(
              message: message,
              onRetry: () => cubit.getAhadithByCategory(_selectedId, refresh: true),
            ),
          ),
        ];
      case HadithByCategoryLoaded():
        final visible =
            _query.isEmpty
                ? state.ahadith
                : state.ahadith
                    .where((h) => normalizeArabic(h.title).contains(_query))
                    .toList();
        if (visible.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: StateMessage(
                icon:
                    _query.isEmpty
                        ? Icons.menu_book_outlined
                        : Icons.search_off_rounded,
                title:
                    _query.isEmpty
                        ? 'لا توجد أحاديث في هذا التصنيف'
                        : 'لا توجد نتائج مطابقة',
                subtitle:
                    _query.isEmpty
                        ? 'جرّب تصنيفاً آخر'
                        : 'البحث يشمل الأحاديث المحمّلة فقط؛ حمّل المزيد أو جرّب كلمة أخرى.',
              ),
            ),
            if (_query.isNotEmpty && state.hasMore)
              SliverToBoxAdapter(child: _Footer(state: state, onLoadMore: cubit.loadMore)),
          ];
        }
        return [
          SliverList.builder(
            itemCount: visible.length,
            itemBuilder:
                (context, index) => _CategoryHadithTile(
                  hadith: visible[index],
                  number: index + 1,
                  opening: _openingId == visible[index].id,
                  onTap:
                      _openingId != null
                          ? null
                          : () {
                            setState(() => _openingId = visible[index].id);
                            context
                                .read<HadithByCategoryDetailsCubit>()
                                .fetchById(visible[index].id);
                          },
                ),
          ),
          SliverToBoxAdapter(child: _Footer(state: state, onLoadMore: cubit.loadMore)),
        ];
      default:
        return [
          SliverList.builder(
            itemCount: 4,
            itemBuilder: (_, _) => const ChapterHadithTileShimmer(),
          ),
        ];
    }
  }
}

class _SubcategoryChips extends StatelessWidget {
  const _SubcategoryChips({
    required this.parent,
    required this.selectedId,
    required this.onSelected,
  });

  final CategoryHadithsArgs parent;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterPill(
            label: 'الكل',
            selected: selectedId == parent.categoryId,
            onTap: () => onSelected(parent.categoryId),
          ),
          for (final child in parent.subcategories)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 6.w),
              child: FilterPill(
                label: child.title,
                selected: selectedId == child.id,
                onTap: () => onSelected(child.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryHadithTile extends StatelessWidget {
  const _CategoryHadithTile({
    required this.hadith,
    required this.number,
    required this.opening,
    required this.onTap,
  });

  final HadithEntity hadith;
  final int number;
  final bool opening;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      child: Material(
        color: ColorsManager.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: ColorsManager.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(minWidth: 30.r),
                  height: 30.r,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: BoxDecoration(
                    color: ColorsManager.primarySoft,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      toArabicDigits('$number'),
                      style: TextStyles.chipLabel.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: ColorsManager.purpleText,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HadithText(
                        hadith.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.readingMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (opening)
                            SizedBox.square(
                              dimension: 16.r,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          else ...[
                            Text('اقرأ مع الشرح', style: TextStyles.actionLabel),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18.r,
                              color: ColorsManager.purpleText,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// How much of the topic is listed, with loading of the next page.
class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onLoadMore});

  final HadithByCategoryLoaded state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final shown = state.ahadith.length;
    final total = state.meta.totalItems;
    final error = state.paginationError;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      child: Column(
        children: [
          Text(
            toArabicDigits('عرض $shown من $total'),
            style: TextStyles.caption,
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: LinearProgressIndicator(
              value: total == 0 ? 1 : (shown / total).clamp(0.0, 1.0),
              minHeight: 4.h,
              backgroundColor: ColorsManager.lightGray,
            ),
          ),
          SizedBox(height: 12.h),
          if (state.isLoadingMore)
            const CircularProgressIndicator()
          else if (error != null)
            TextButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تعذر التحميل، أعد المحاولة'),
            )
          else if (state.hasMore)
            OutlinedButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.expand_more_rounded),
              label: const Text('تحميل المزيد'),
            )
          else
            Text(
              'تم عرض جميع الأحاديث',
              style: TextStyles.caption.copyWith(color: ColorsManager.gray),
            ),
        ],
      ),
    );
  }
}
