import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/models/book_chapters_args.dart';

/// Cover, title, author and size of the book being browsed.
class BookHeader extends StatelessWidget {
  const BookHeader({super.key, required this.book});

  final BookChaptersArgs book;

  @override
  Widget build(BuildContext context) {
    final writer = book.writerName;
    final chapters = book.chaptersCount;
    final hadiths = book.hadithsCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Cover(imagePath: book.coverImage),
        SizedBox(width: 16.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    book.bookName,
                    style: TextStyles.screenTitle.copyWith(fontSize: 24.sp),
                  ),
                ),
                if (writer != null && writer.isNotEmpty)
                  Text(writer, style: TextStyles.caption.copyWith(fontSize: 13.sp)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    if (chapters != null && chapters > 1)
                      AppBadge(
                        label: arabicCount(chapters, ArabicNoun.chapter),
                        icon: Icons.folder_rounded,
                        background: ColorsManager.primarySoft,
                        foreground: ColorsManager.purpleText,
                      ),
                    if (hadiths != null && hadiths > 0)
                      AppBadge(
                        label: arabicCount(hadiths, ArabicNoun.hadith),
                        icon: Icons.auto_stories_rounded,
                        background: ColorsManager.goldSoft,
                        foreground: ColorsManager.hadithGood,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final imagePath = this.imagePath;
    return Container(
      width: 96.w,
      height: 132.w,
      decoration: BoxDecoration(
        color: ColorsManager.primarySoft,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.coverShadow,
            offset: const Offset(0, 12),
            blurRadius: 22,
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
