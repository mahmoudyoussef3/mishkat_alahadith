import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.secondaryBackground,
            ColorsManager.offWhite,
            ColorsManager.lightGray.withOpacity(0.3),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: Colors.green.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Islamic pattern overlay
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.03),
                borderRadius: BorderRadius.circular(40.r),
              ),
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
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.1),
                                Colors.green.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.menu_book,
                            color: Colors.green,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'نص الحديث',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: ColorsManager.primaryText,
                            fontFamily: 'Amiri',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Enhanced hadith text
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorsManager.white.withOpacity(0.8),
                        ColorsManager.offWhite.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hadith.arabic ?? '',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      color: ColorsManager.primaryText,
                      fontSize: 17.sp,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
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
                          Colors.green.withOpacity(0.8),
                          Colors.green.withOpacity(0.6),
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.4),
                        Colors.green.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1.r),
                  ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
          fontFamily: 'Amiri',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
