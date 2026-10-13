import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/book_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/last_read_chapter.dart';

/// Reopens the chapter the reader was last in, showing how far through
/// the book it is.
class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({
    super.key,
    required this.lastRead,
    required this.chapters,
    required this.onTap,
  });

  final LastReadChapter lastRead;
  final List<BookChapter> chapters;
  final ValueChanged<BookChapter> onTap;

  @override
  Widget build(BuildContext context) {
    final index = chapters.indexWhere(
      (chapter) => chapter.chapterNumber == lastRead.chapterNumber,
    );
    final chapter =
        index >= 0
            ? chapters[index]
            : BookChapter(
              chapterNumber: lastRead.chapterNumber,
              chapterArabic: lastRead.title,
            );
    final position = index + 1;
    final total = chapters.length;
    final muted = ColorsManager.white.withValues(alpha: 0.78);

    return Semantics(
      button: true,
      label: 'تابع القراءة: ${lastRead.title}',
      excludeSemantics: true,
      child: HeroSurface(
        showImage: false,
        radius: 18.r,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        onTap: () => onTap(chapter),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: ColorsManager.goldBright,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 24.r,
                color: ColorsManager.onGoldBright,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'تابع القراءة · ${lastRead.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ColorsManager.white,
                          ),
                        ),
                      ),
                      if (index >= 0) ...[
                        SizedBox(width: 8.w),
                        Text(
                          toArabicDigits('$position / $total'),
                          style: TextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (index >= 0) ...[
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: position / total,
                        minHeight: 4.h,
                        color: ColorsManager.goldBright,
                        backgroundColor: ColorsManager.white.withValues(
                          alpha: 0.18,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
