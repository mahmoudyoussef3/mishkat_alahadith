import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/networking/api_constants.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';
import 'package:mishkat_almasabih/features/library/ui/widgets/book_stat.dart';

class BookCard extends StatelessWidget {
  final Book book;

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
                "noOfChapters": book.chapters_count.toString(),
                "noOfHadith": book.hadiths_count.toString(),
              },
            ],
          ),
      child: Card(
        color: ColorsManager.secondaryBackground,
        elevation: 2,child:  Container(
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(20.r),
  
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  image: DecorationImage(
                    image: AssetImage(bookImages[book.bookName!] ?? ''),
                    fit: BoxFit.cover,
                  ),
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
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.primaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    bookWriters[book.bookName] ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ColorsManager.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BookStat(
                        value: '${book.chapters_count} باب',
                        color: ColorsManager.accentPurple,
                      ),
                      BookStat(
                        
                        value: '${book.hadiths_count} حديث',
                        color: ColorsManager.hadithAuthentic,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
         )   ),
    );
  }
}