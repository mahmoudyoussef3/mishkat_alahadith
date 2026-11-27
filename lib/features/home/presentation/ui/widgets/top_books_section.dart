import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/networking/api_constants.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/section_header.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_book.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_statistics.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_statistics/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/library/presentation/ui/widgets/book_cover_tile.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/logic/main_navigation_cubit.dart';
import 'package:shimmer/shimmer.dart';

/// Horizontal shelf of the most-read books.
class TopBooksSection extends StatelessWidget {
  const TopBooksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<GetLibraryStatisticsCubit, GetLibraryStatisticsState>(
        buildWhen:
            (previous, current) =>
                current is! GetLivraryStatisticsSuccess ||
                previous is! GetLivraryStatisticsSuccess ||
                previous.statistics != current.statistics,
        builder: (context, state) {
          final Widget shelf;
          switch (state) {
            case GetLivraryStatisticsSuccess(:final statistics)
                when statistics.topBooks.isNotEmpty:
              shelf = _Shelf(books: statistics.topBooks);
            case GetLivraryStatisticsLoading() || GetLibraryStatisticsInitial():
              shelf = const _ShelfShimmer();
            default:
              // Nothing useful to show; the library tab reports the error.
              return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: 'الكتب الأكثر رواجاً',
                actionLabel: 'عرض الكل',
                onAction:
                    () => context.read<MainNavigationCubit>().select(
                      MainTab.library,
                    ),
              ),
              shelf,
            ],
          );
        },
      ),
    );
  }
}

/// Shelf height: padding, cover and gap, plus the title and meta lines at
/// the user's text size.
double _shelfHeight(BuildContext context) =>
    12.h + 176.h + 8.h + MediaQuery.textScalerOf(context).scale(44.sp);

class _Shelf extends StatelessWidget {
  const _Shelf({required this.books});

  final List<TopBookStatistics> books;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _shelfHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
        itemCount: books.length,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          final book = books[index];
          return SizedBox(
            width: 128.w,
            child: BookCoverTile(
              showAuthor: false,
              coverHeight: 176.h,
              book: LibraryBook(
                bookName: book.name,
                bookSlug: booksMap[bookNamesArabic[book.name]] ?? '',
                chaptersCount: book.chapters,
                hadithsCount: book.hadiths,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShelfShimmer extends StatelessWidget {
  const _ShelfShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _shelfHeight(context),
      child: Shimmer.fromColors(
        baseColor: ColorsManager.shimmerBase,
        highlightColor: ColorsManager.shimmerHighlight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
          itemCount: 4,
          separatorBuilder: (_, __) => SizedBox(width: 14.w),
          itemBuilder:
              (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 128.w,
                    height: 176.h,
                    decoration: BoxDecoration(
                      color: ColorsManager.shimmerBase,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 96.w,
                    height: 12.h,
                    color: ColorsManager.shimmerBase,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 70.w,
                    height: 10.h,
                    color: ColorsManager.shimmerBase,
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
