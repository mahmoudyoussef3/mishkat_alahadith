import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/book_chapter.dart';
import 'package:shimmer/shimmer.dart';

/// "الكتب والأبواب" with how many chapters are listed.
class ChapterListHeader extends StatelessWidget {
  const ChapterListHeader({super.key, required this.shown, required this.total});

  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    final count =
        shown == total
            ? toArabicDigits('$total')
            : toArabicDigits('$shown من $total');

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'الكتب والأبواب',
                  style: TextStyles.sectionTitle.copyWith(fontSize: 16.sp),
                ),
              ),
            ),
            Text(
              count,
              style: TextStyles.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chapters as rows of one card. The chapter last read is marked in gold.
class ChapterList extends StatelessWidget {
  const ChapterList({
    super.key,
    required this.chapters,
    required this.onTap,
    this.lastReadNumber,
  });

  final List<BookChapter> chapters;
  final ValueChanged<BookChapter> onTap;
  final int? lastReadNumber;

  @override
  Widget build(BuildContext context) {
    return _CardSliver(
      sliver: SliverList.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return _ChapterRow(
            chapter: chapter,
            isFirst: index == 0,
            isLast: index == chapters.length - 1,
            isLastRead:
                lastReadNumber != null &&
                chapter.chapterNumber == lastReadNumber,
            onTap: () => onTap(chapter),
          );
        },
      ),
    );
  }
}

/// Placeholder rows while the chapters load.
class ChapterListShimmer extends StatelessWidget {
  const ChapterListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final block = ColorsManager.shimmerBase;
    return _CardSliver(
      sliver: SliverList.builder(
        itemCount: 8,
        itemBuilder:
            (context, index) => Shimmer.fromColors(
              baseColor: ColorsManager.shimmerBase,
              highlightColor: ColorsManager.shimmerHighlight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: block,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 150.w, height: 14.h, color: block),
                          SizedBox(height: 8.h),
                          Container(width: 70.w, height: 10.h, color: block),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

/// Paints one bordered card behind a list sliver.
class _CardSliver extends StatelessWidget {
  const _CardSliver({required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: DecoratedSliver(
        decoration: BoxDecoration(
          color: ColorsManager.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: ColorsManager.border),
        ),
        sliver: sliver,
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.chapter,
    required this.isFirst,
    required this.isLast,
    required this.isLastRead,
    required this.onTap,
  });

  final BookChapter chapter;
  final bool isFirst;
  final bool isLast;
  final bool isLastRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(20.r);
    final count = chapter.hadithsCount;
    final number = chapter.chapterNumber;
    final title = chapter.chapterArabic ?? '';

    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: ColorsManager.lightGray),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? radius : Radius.zero,
              bottom: isLast ? radius : Radius.zero,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isLastRead
                              ? ColorsManager.goldBright
                              : ColorsManager.primarySoft,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          number == null ? '' : toArabicDigits('$number'),
                          style: TextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color:
                                isLastRead
                                    ? ColorsManager.onGoldBright
                                    : ColorsManager.purpleText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                        if (count != null && count > 0)
                          Text(
                            isLastRead
                                ? '${arabicCount(count, ArabicNoun.hadith)} · آخر ما قرأت'
                                : arabicCount(count, ArabicNoun.hadith),
                            style: TextStyles.caption,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.r,
                    color: ColorsManager.gray,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
