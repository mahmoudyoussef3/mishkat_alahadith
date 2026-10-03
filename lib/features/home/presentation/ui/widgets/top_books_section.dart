import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/networking/api_constants.dart';
import 'package:mishkat_almasabih/core/theming/home_styles.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/library/ui/widgets/book_card.dart';
import 'package:mishkat_almasabih/features/library/ui/widgets/book_card_shimmer.dart';

class TopBooksSection extends StatelessWidget {
  const TopBooksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<GetLibraryStatisticsCubit, GetLibraryStatisticsState>(
        builder: (context, state) {
          if (state is GetLivraryStatisticsLoading) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: SizedBox(
                height: 240.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 140.w,
                      child: const BookCardShimmer(),
                    );
                  },
                ),
              ),
            );
          } else if (state is GetLivraryStatisticsSuccess) {
            final books = state.statisticsResponse.statistics.topBooks;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الكتب الأكثر رواجا',
                    style: HomeTextStyles.sectionHeader,
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 240.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      separatorBuilder:
                          (context, index) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return SizedBox(
                          width: 170.w,
                          child: BookCard(
                            book: Book(
                              bookName: book.name,
                              bookSlug:
                                  booksMap[bookNamesArabic[book.name]] ?? '',
                              writerName: book.name,
                              chapters_count: book.chapters,
                              hadiths_count: book.hadiths,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
