import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_decorations.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_styles.dart';
import 'package:mishkat_almasabih/features/hadith_daily/ui/widgets/hadith_rich_text.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';

class ResultHadithContentCard extends StatelessWidget {
  final EnhancedHadithModel data;
  const ResultHadithContentCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: EnhancedSearchDecorations.hadithContentCard(),
      child: Stack(
        children: [
          // Islamic pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.0005,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.asset(
                  'assets/images/islamic_pattern.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Decorative corner elements
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
              ),
              child: Icon(
                Icons.format_quote,
                color: ColorsManager.primaryPurple.withOpacity(0.6),
                size: 24.sp,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hadith content label
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: EnhancedSearchDecorations.hadithLabel(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: EnhancedSearchDecorations.labelIconColor,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "نص الحديث",
                        style: EnhancedSearchTextStyles.hadithLabelText,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Hadith content
                HadithRichText(hadith: data.hadeeth ?? ""),
                SizedBox(height: 10.h),

                /// أيقونات النسخ والمشاركة والإضافة للمفضلة
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Wrap(
                    spacing: 10.w,
                    children: [
                      _buildActionIcon(
                        context,
                        icon: Icons.copy_rounded,
                        color: EnhancedSearchDecorations.copyIconColor,
                        tooltip: "نسخ الحديث",
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: data.hadeeth ?? ""),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text("تم نسخ الحديث"),
                            ),
                          );
                        },
                      ),
                      _buildActionIcon(
                        context,
                        icon: Icons.share_rounded,
                        color: EnhancedSearchDecorations.shareIconColor,
                        tooltip: "مشاركة الحديث",
                        onTap:
                            () => shareHadithAsImage(
                              context,
                              text: data.hadeeth ?? "",
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom decorative element
          /*      Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: ColorsManager.primaryGold.withOpacity(0.08),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
              ),
              child: Icon(
                Icons.star,
                color: ColorsManager.primaryGold.withOpacity(0.4),
                size: 28.sp,
              ),
            ),
          ),
          */
        ],
      ),
    );
  }

  Widget _buildActionIcon(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 36.w,
          height: 36.h,
          decoration: EnhancedSearchDecorations.actionIconContainer(color),
          child: Icon(icon, color: color, size: 20.sp),
        ),
      ),
    );
  }
}
