import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/chapters_decorations.dart';
import 'package:mishkat_almasabih/core/theming/chapters_styles.dart';

class ChapterCard extends StatelessWidget {
  const ChapterCard({
    super.key,
    required this.chapterNumber,
    required this.ar,
    required this.primaryPurple,
  });
  final int? chapterNumber;
  final String? ar;

  final Color primaryPurple;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ChaptersDecorations.chapterCard(primaryPurple),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: ChaptersDecorations.numberChip(primaryPurple),
            child: Center(
              child: Text(
                ("$chapterNumber").toString(),
                style: ChaptersTextStyles.numberLabel,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    ar!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: ChaptersTextStyles.chapterTitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
