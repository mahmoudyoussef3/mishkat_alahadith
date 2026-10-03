import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'bookmark_button.dart';

class ChapterAppBar extends StatelessWidget {
  final String arabicBookName;
  final String arabicChapterName;
  final String bookSlug;
  final int? chapterNumber;

  const ChapterAppBar({
    super.key,
    required this.arabicBookName,
    required this.arabicChapterName,
    required this.bookSlug,
    required this.chapterNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BuildHeaderAppBar(
      title: arabicBookName,
      description: arabicChapterName,
      actions: [
        BookmarkButton(
          bookSlug: bookSlug,
          arabicBookName: arabicBookName,
          arabicChapterName: arabicChapterName,
          chapterNumber: chapterNumber,
        ),
      ],
    );
  }
}
