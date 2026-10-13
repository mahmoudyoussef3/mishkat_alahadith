import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/filter_pill.dart';
import 'package:mishkat_almasabih/core/widgets/screen_title_header.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_book.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_statistics.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_books/library_books_cubit.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_statistics/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/library/presentation/ui/widgets/book_cover_tile.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/logic/main_navigation_cubit.dart';
import 'package:shimmer/shimmer.dart';

/// The library: every book as a cover grid, filterable by category.
///
/// Reads [GetLibraryStatisticsCubit] (for the categories and totals) and
/// [LibraryBooksCubit] (for the books) from above.
class LibraryBooksScreen extends StatefulWidget {
  const LibraryBooksScreen({super.key});

  @override
  State<LibraryBooksScreen> createState() => _LibraryBooksScreenState();
}

class _LibraryBooksScreenState extends State<LibraryBooksScreen> {
  /// Search is a tab in the app shell; outside it, open the search screen.
  void _openSearch(BuildContext context) {
    final navigation = context.read<MainNavigationCubit?>();
    if (navigation != null) {
      navigation.select(MainTab.search);
    } else {
      context.pushNamed(Routes.searchScreen);
    }
  }

  /// Selected category id; null shows every category.
  String? _category;

  @override
  void initState() {
    super.initState();
    final statistics = context.read<GetLibraryStatisticsCubit>();
    switch (statistics.state) {
      case GetLivraryStatisticsSuccess(:final statistics):
        _loadBooks(statistics);
      case GetLibraryStatisticsInitial():
        statistics.emitGetStatisticsCubit();
      default:
        break;
    }
  }

  List<String> _categoryIds(LibraryStatistics statistics) {
    final category = _category;
    return category == null
        ? statistics.booksByCategory.keys.toList()
        : [category];
  }

  Future<void> _loadBooks(LibraryStatistics statistics) =>
      context.read<LibraryBooksCubit>().load(_categoryIds(statistics));

  void _select(String? category, LibraryStatistics statistics) {
    if (category == _category) return;
    setState(() => _category = category);
    _loadBooks(statistics);
  }

  Future<void> _refresh(LibraryStatistics statistics) async {
    await Future.wait([
      context.read<GetLibraryStatisticsCubit>().emitGetStatisticsCubit(),
      _loadBooks(statistics),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<
            GetLibraryStatisticsCubit,
            GetLibraryStatisticsState
          >(
            listenWhen:
                (previous, current) =>
                    current is GetLivraryStatisticsSuccess &&
                    previous is! GetLivraryStatisticsSuccess,
            listener:
                (context, state) => _loadBooks(
                  (state as GetLivraryStatisticsSuccess).statistics,
                ),
            builder:
                (context, state) => switch (state) {
                  GetLivraryStatisticsSuccess(:final statistics) =>
                    RefreshIndicator(
                      onRefresh: () => _refresh(statistics),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: ScreenTitleHeader(
                              title: 'المكتبة',
                              subtitle:
                                  '${arabicCount(statistics.totalBooks, ArabicNoun.book)}'
                                  ' · ${approximateHadithCount(statistics.totalHadiths)}',
                              trailing: AppIconButton(
                                tooltip: 'البحث في الأحاديث',
                                icon: Icons.search_rounded,
                                onPressed: () => _openSearch(context),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _CategoryFilter(
                              categories: statistics.booksByCategory,
                              selected: _category,
                              onSelected:
                                  (category) => _select(category, statistics),
                            ),
                          ),
                          _BooksGrid(onRetry: () => _loadBooks(statistics)),
                        ],
                      ),
                    ),
                  GetLivraryStatisticsError(:final errorMessage) => Column(
                    children: [
                      const ScreenTitleHeader(title: 'المكتبة'),
                      Expanded(
                        child: Center(
                          child: StateMessage.error(
                            message: errorMessage,
                            onRetry:
                                () =>
                                    context
                                        .read<GetLibraryStatisticsCubit>()
                                        .emitGetStatisticsCubit(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _ => const CustomScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: ScreenTitleHeader(title: 'المكتبة'),
                      ),
                      _GridShimmer(),
                    ],
                  ),
                },
          ),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final Map<String, CategoryStatistics> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = categories.entries.toList();
    return SizedBox(
      height: 56.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 4.h),
        itemCount: entries.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterPill(
              label: 'الكل',
              selected: selected == null,
              onTap: () => onSelected(null),
            );
          }
          final entry = entries[index - 1];
          return FilterPill(
            label: entry.value.name,
            selected: selected == entry.key,
            onTap: () => onSelected(entry.key),
          );
        },
      ),
    );
  }
}

/// Lays out book tiles in as many columns as fit, never fewer than two.
class _BookGridLayout {
  _BookGridLayout(BuildContext context, double width)
    : columns = (width / 200).floor().clamp(2, 5),
      _textHeight = MediaQuery.textScalerOf(context).scale(68.sp),
      _width = width;

  final int columns;
  final double _textHeight;
  final double _width;

  static double get padding => 20.w;
  static double get columnGap => 14.w;
  static double get rowGap => 18.h;

  double get _tileWidth =>
      (_width - padding * 2 - columnGap * (columns - 1)) / columns;

  double get coverHeight => _tileWidth * 1.25;

  SliverGridDelegate get delegate => SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    crossAxisSpacing: columnGap,
    mainAxisSpacing: rowGap,
    mainAxisExtent: coverHeight + 8.h + _textHeight,
  );

  EdgeInsets get insets => EdgeInsets.fromLTRB(padding, 16.h, padding, 24.h);
}

class _BooksGrid extends StatelessWidget {
  const _BooksGrid({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBooksCubit, LibraryBooksState>(
      builder:
          (context, state) => switch (state) {
            LibraryBooksLoaded(:final books) when books.isEmpty =>
              const SliverToBoxAdapter(
                child: StateMessage(
                  icon: Icons.local_library_outlined,
                  title: 'لا توجد كتب في هذا التصنيف',
                ),
              ),
            LibraryBooksLoaded(:final books) => _Grid(books: books),
            LibraryBooksError(:final message) => SliverToBoxAdapter(
              child: StateMessage.error(message: message, onRetry: onRetry),
            ),
            _ => const _GridShimmer(),
          },
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.books});

  final List<LibraryBook> books;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _BookGridLayout(context, constraints.crossAxisExtent);
        return SliverPadding(
          padding: layout.insets,
          sliver: SliverGrid.builder(
            gridDelegate: layout.delegate,
            itemCount: books.length,
            itemBuilder:
                (context, index) => BookCoverTile(
                  book: books[index],
                  coverHeight: layout.coverHeight,
                ),
          ),
        );
      },
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _BookGridLayout(context, constraints.crossAxisExtent);
        return SliverPadding(
          padding: layout.insets,
          sliver: SliverGrid.builder(
            gridDelegate: layout.delegate,
            itemCount: layout.columns * 2,
            itemBuilder:
                (_, __) => Shimmer.fromColors(
                  baseColor: ColorsManager.shimmerBase,
                  highlightColor: ColorsManager.shimmerHighlight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: layout.coverHeight,
                        decoration: BoxDecoration(
                          color: ColorsManager.shimmerBase,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: 110.w,
                        height: 12.h,
                        color: ColorsManager.shimmerBase,
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 80.w,
                        height: 10.h,
                        color: ColorsManager.shimmerBase,
                      ),
                    ],
                  ),
                ),
          ),
        );
      },
    );
  }
}
