// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/hadith_decorations.dart';
import 'package:mishkat_almasabih/core/theming/hadith_styles.dart';

class ChapterAhadithCard extends StatelessWidget {
  const ChapterAhadithCard({
    super.key,
    required this.number,
    required this.text,
    this.narrator,
    this.grade,
    this.reference,
    this.bookName,
    this.hadithCategory,
  });

  final String number;
  final String text;
  final String? narrator;
  final String? grade;
  final String? reference;
  final String? bookName;
  final String? hadithCategory;

  @override
  Widget build(BuildContext context) {
    final gradeColor = getGradeColor(grade);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: HadithDecorations.chapterCard(gradeColor),
      child: Stack(
        children: [
          // Islamic pattern overlay
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: HadithDecorations.patternOverlay(gradeColor, 40),
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
                    Expanded(
                      // ✅ Added
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: HadithDecorations.headerIcon(
                              gradeColor,
                            ),
                            child: Icon(
                              Icons.menu_book,
                              color: gradeColor,
                              size: 20.r,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              hadithCategory == null
                                  ? 'نص الحديث'
                                  : hadithCategory!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: HadithTextStyles.headerCategoryTitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (grade != null && grade!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: HadithDecorations.gradeBadge(gradeColor),
                        child: Text(
                          grade!,
                          style: HadithTextStyles.gradeLabel(gradeColor),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Enhanced hadith text
                if (text.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: HadithDecorations.hadithTextContainer(
                      gradeColor,
                    ),
                    child: Text(
                      text,
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
                    if (reference != null && reference!.isNotEmpty)
                      Flexible(
                        child: _buildGradientPill(
                          text: reference!,
                          colors: [
                            gradeColor.withOpacity(0.8),
                            gradeColor.withOpacity(0.6),
                          ],
                          textColor: ColorsManager.white,
                        ),
                      ),
                    SizedBox(width: 12.w),
                    if (bookName != null && bookName!.isNotEmpty)
                      Flexible(
                        child: _buildGradientPill(
                          text: bookName!,
                          colors: [
                            ColorsManager.primaryPurple.withOpacity(0.8),
                            ColorsManager.primaryPurple.withOpacity(0.6),
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
                  decoration: HadithDecorations.bottomLine(gradeColor),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: HadithTextStyles.pillLabel(textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
