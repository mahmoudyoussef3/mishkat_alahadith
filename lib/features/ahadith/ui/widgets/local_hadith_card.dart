import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';
import 'package:mishkat_almasabih/core/theming/hadith_decorations.dart';
import 'package:mishkat_almasabih/core/theming/hadith_styles.dart';

class LocalHadithCard extends StatelessWidget {
  const LocalHadithCard({
    super.key,
    required this.hadith,
    required this.bookName,
    required this.chapterName,
  });

  final LocalHadith hadith;
  final String bookName;
  final String chapterName;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: HadithDecorations.chapterCard(ColorsManager.hadithAuthentic),
      child: Stack(
        children: [
          // Islamic pattern overlay
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration:
                  HadithDecorations.patternOverlay(ColorsManager.hadithAuthentic, 40),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Enhanced header with Islamic design
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration:
                              HadithDecorations.headerIcon(ColorsManager.hadithAuthentic),
                          child: Icon(
                            Icons.menu_book,
                            color: ColorsManager.hadithAuthentic,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'نص الحديث',
                          style: HadithTextStyles.headerCategoryTitle,
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Enhanced hadith text
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration:
                      HadithDecorations.hadithTextContainer(ColorsManager.hadithAuthentic),
                  child: Text(
                    hadith.arabic ?? '',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: HadithTextStyles.hadithArabic,
                  ),
                ),

                SizedBox(height: 18.h),

                // Enhanced book and chapter pills
                Row(
                  children: [
                    Flexible(
                      child: _buildGradientPill(
                        text: bookName,
                        colors: [
                          ColorsManager.primaryPurple.withOpacity(0.8),
                          ColorsManager.primaryPurple.withOpacity(0.6),
                        ],
                        textColor: ColorsManager.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // TODO: replace with chapter name when available
                    Flexible(
                      child: _buildGradientPill(
                        text: bookName,
                        colors: [
                          ColorsManager.hadithAuthentic.withOpacity(0.8),
                          ColorsManager.hadithAuthentic.withOpacity(0.6),
                        ],
                        textColor: ColorsManager.white,
                      ),
                    ),
                  ],
                ),

                // Decorative bottom line
                SizedBox(height: 16.h),
                Container(
                  height: 2.h,
                  decoration:
                      HadithDecorations.bottomLine(ColorsManager.hadithAuthentic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientPill({
    required String text,
    required List<Color> colors,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: HadithDecorations.pill(colors),
      child: Text(
        text,
        style: HadithTextStyles.pillLabel(textColor, fontSize: 14.sp),
        textAlign: TextAlign.center,
      ),
    );
  }
}
