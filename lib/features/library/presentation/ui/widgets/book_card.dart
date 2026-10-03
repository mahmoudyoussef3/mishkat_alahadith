import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/networking/api_constants.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_book.dart';
import 'package:mishkat_almasabih/features/library/presentation/ui/widgets/book_stat.dart';
import 'package:mishkat_almasabih/core/theming/library_decorations.dart';
import 'package:mishkat_almasabih/core/theming/library_styles.dart';

class BookCard extends StatelessWidget {
  final LibraryBook book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => context.pushNamed(
            Routes.bookChaptersScreen,
            arguments: [
              book.bookSlug!,
              {
                "bookName": bookNamesArabic[book.bookName],
                "writerName": bookWriters[book.bookName],
                "noOfChapters": book.chaptersCount.toString(),
                "noOfHadith": book.hadithsCount.toString(),
              },
            ],
          ),
      child: Card(
        color: ColorsManager.secondaryBackground,
        elevation: 2,
        child: Container(
          decoration: LibraryDecorations.bookCardContainer(),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: LibraryDecorations.bookImageBox(
                    bookImages[book.bookName!] ?? '',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookNamesArabic[book.bookName] ?? '',
                      style: LibraryTextStyles.bookTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      bookWriters[book.bookName] ?? '',
                      style: LibraryTextStyles.bookWriter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BookStat(
                          value: '${book.chaptersCount} باب',
                          color: ColorsManager.accentPurple,
                        ),
                        BookStat(
                          value: '${book.hadithsCount} حديث',
                          color: ColorsManager.hadithAuthentic,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
