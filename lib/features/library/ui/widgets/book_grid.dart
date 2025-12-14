import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';
import 'package:mishkat_almasabih/features/library/ui/widgets/book_card.dart';
import 'package:mishkat_almasabih/features/library/ui/widgets/book_card_shimmer.dart';

class BookGrid extends StatelessWidget {
  final List<Book>? books;
  final double aspectRatio;
  final bool isShimmer;

  const BookGrid._({
    this.books,
    required this.aspectRatio,
    required this.isShimmer,
  });

  factory BookGrid.shimmer({required double aspectRatio}) {
    return BookGrid._(aspectRatio: aspectRatio, isShimmer: true);
  }

  factory BookGrid.success({
    required List<Book> books,
    required double aspectRatio,
  }) {
    return BookGrid._(books: books, aspectRatio: aspectRatio, isShimmer: false);
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      sliver: SliverGrid(

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          
          mainAxisSpacing: 12.h,
          childAspectRatio: aspectRatio,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (isShimmer) {
            return const BookCardShimmer();
          } else {
            final book = books![index];
            return BookCard(book: book);
            //   .animate()
            //  .fadeIn(duration: 1.2.seconds)
            //   .scale(duration: 1.2.seconds, curve: Curves.easeOutBack);
          }
        }, childCount: isShimmer ? 6 : books!.length),
      ),
    );
  }
}
