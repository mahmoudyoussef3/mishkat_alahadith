import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/ui/widgets/hadith_rich_text.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_decorations.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_styles.dart';

class HadithContentCard extends StatelessWidget {
  final ExplainedHadith data;
  const HadithContentCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DailyHadithDecorations.contentCard(),
      child: Stack(
        children: [
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

          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 50.w,
              height: 50.h,
              decoration: DailyHadithDecorations.cornerQuote(),
              child: Icon(
                Icons.format_quote,
                color: ColorsManager.primaryPurple.withOpacity(0.6),
                size: 24.sp,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(22.w, 22.w, 22.w, 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorsManager.primaryPurple.withOpacity(0.14),
                            ColorsManager.secondaryPurple.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: ColorsManager.primaryPurple,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نص الحديث',
                            style: DailyHadithTextStyles.labelChip.copyWith(
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'اقرأ الحديث كاملًا مع خيارات النسخ والمشاركة',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: ColorsManager.secondaryText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                HadithRichText(hadith: data.hadeeth ?? ""),
                SizedBox(height: 14.h),

                Align(
                  alignment: Alignment.bottomLeft,
                  child: Wrap(
                    spacing: 10.w,
                    children: [
                      _buildActionIcon(
                        context,
                        icon: Icons.copy_rounded,
                        color: ColorsManager.primaryPurple,
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
                        color: ColorsManager.primaryGreen,
                        tooltip: "مشاركة الحديث",

                        onTap:
                            () => shareHadithAsImage(
                              context,
                              text: data.hadeeth ?? '',
                            ),
                      ),
                      _buildActionIcon(
                        context,
                        icon: Icons.link_rounded,
                        color: ColorsManager.primaryGreen,
                        tooltip: "مشاركة كرابط",
                        onTap: () => shareHadithLink(
                          context,
                          hadithId: data.id?.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
          decoration: DailyHadithDecorations.actionIcon(color),
          child: Icon(icon, color: color, size: 20.sp),
        ),
      ),
    );
  }
}
