import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/networking/api_constants.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/models/book_chapters_args.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_book.dart';

/// A book as its cover with the title, author and size beneath. Opens the
/// book's chapters.
class BookCoverTile extends StatelessWidget {
  const BookCoverTile({
    super.key,
    required this.book,
    required this.coverHeight,
    this.showAuthor = true,
  });

  final LibraryBook book;
  final double coverHeight;
  final bool showAuthor;

  String get _title => bookNamesArabic[book.bookName] ?? book.bookName ?? '';

  String? get _author => bookWriters[book.bookName];

  String get _meta => [
    if (book.hadithsCount case final hadiths?)
      arabicCount(hadiths, ArabicNoun.hadith),
    if (book.chaptersCount case final chapters? when chapters > 1)
      arabicCount(chapters, ArabicNoun.chapter),
  ].join(' · ');

  void _open(BuildContext context) {
    context.pushNamed(
      Routes.bookChaptersScreen,
      arguments: BookChaptersArgs(
        bookSlug: book.bookSlug ?? '',
        bookName: _title,
        writerName: _author,
        chaptersCount: book.chaptersCount,
        hadithsCount: book.hadithsCount,
        coverImage: bookImages[book.bookName],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final author = _author;
    final meta = _meta;

    return Semantics(
      button: true,
      label: _title,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cover(imagePath: bookImages[book.bookName], height: coverHeight),
            SizedBox(height: 8.h),
            Text(
              _title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
            if (showAuthor && author != null)
              Text(
                author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.caption.copyWith(height: 1.5),
              ),
            if (meta.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: showAuthor ? 2.h : 0),
                child: Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.caption.copyWith(
                    fontSize: 11.sp,
                    height: 1.5,
                    fontWeight: showAuthor ? FontWeight.w600 : FontWeight.w500,
                    color:
                        showAuthor
                            ? ColorsManager.gray
                            : ColorsManager.secondaryText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.imagePath, required this.height});

  final String? imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    final imagePath = this.imagePath;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsManager.primarySoft,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.coverShadow,
            offset: const Offset(0, 10),
            blurRadius: 20,
            spreadRadius: -10,
          ),
        ],
        image:
            imagePath == null
                ? null
                : DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
      ),
      child:
          imagePath == null
              ? Icon(
                Icons.menu_book_rounded,
                size: 36.r,
                color: ColorsManager.purpleText,
              )
              : null,
    );
  }
}
